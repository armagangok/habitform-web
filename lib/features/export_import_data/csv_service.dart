import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../reminder/models/days/days_enum.dart';
import '../reminder/models/reminder/reminder_model.dart';
import '../../models/completion_entry/completion_entry.dart';
import '../../models/habit/habit_model.dart';
import '../../models/habit/habit_status.dart';
import '../../services/habit_service/habit_service_interface.dart';

class CSVService {
  CSVService._();
  static final CSVService _instance = CSVService._();
  static CSVService get instance => _instance;

  final _habitService = habitService;
  final _uuid = Uuid();

  // Export habits to CSV
  Future<String> exportHabitsToCSV() async {
    try {
      // Get all habits
      final habits = await _habitService.getAllHabits();

      // Create CSV header
      List<List<dynamic>> rows = [];
      rows.add(['id', 'name', 'description', 'emoji', 'color_code', 'status', 'archive_date', 'completion_dates', 'reminder_time', 'reminder_days']);

      // Add habit data
      for (var habit in habits) {
        debugPrint('Exporting habit: ${habit.habitName}, emoji: ${habit.emoji}');

        // Convert completion dates to string format
        List<String> completionDates = [];
        habit.completions.forEach((key, entry) {
          if (entry.isCompleted) {
            completionDates.add(entry.date.toIso8601String());
          }
        });

        // Get reminder data
        String reminderTime = '';
        String reminderDays = '';

        if (habit.reminderModel != null) {
          if (habit.reminderModel!.reminderTime != null) {
            reminderTime = habit.reminderModel!.reminderTime!.toIso8601String();
          }

          if (habit.reminderModel!.days != null && habit.reminderModel!.days!.isNotEmpty) {
            reminderDays = habit.reminderModel!.days!.map((day) => day.index).join(',');
          }
        }

        // Emoji'yi Base64 ile kodla (cross-platform uyumluluk için)
        String encodedEmoji = '';
        if (habit.emoji != null && habit.emoji!.isNotEmpty) {
          try {
            final emojiBytes = utf8.encode(habit.emoji!);
            encodedEmoji = base64Encode(emojiBytes);
            debugPrint('Emoji encoded as base64: $encodedEmoji');
          } catch (e) {
            debugPrint('Error encoding emoji: $e');
            encodedEmoji = '';
          }
        }

        rows.add([
          habit.id,
          habit.habitName,
          habit.habitDescription ?? '',
          encodedEmoji, // Base64 kodlanmış emoji
          habit.colorCode,
          habit.status.toString(),
          habit.archiveDate?.toIso8601String() ?? '',
          completionDates.join('|'),
          reminderTime,
          reminderDays,
        ]);
      }

      // Convert to CSV with proper text delimiters
      String csv = const ListToCsvConverter(
        textDelimiter: '"',
        textEndDelimiter: '"',
        fieldDelimiter: ',',
        eol: '\n',
      ).convert(rows);

      // Dosya adını oluştur
      final now = DateTime.now();
      final formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}-${now.minute.toString().padLeft(2, '0')}";
      final filename = 'HabitRise_export_$formattedDate.csv';
      debugPrint('Generated file name: $filename');

      // Dosyayı Documents klasörüne kaydet
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsString(csv);
      debugPrint('File saved to: $filePath');

      // Kaydedilen dosyayı paylaş
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        subject: 'HabitRise Export',
      );

      return filePath;
    } catch (e) {
      debugPrint('Error exporting habits: $e');
      rethrow;
    }
  }

  // Share CSV file
  Future<void> shareCSVFile(String filePath) async {
    try {
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        subject: 'HabitRise Export',
      );
    } catch (e) {
      debugPrint('Error sharing CSV file: $e');
      rethrow;
    }
  }

  // Import habits from CSV
  Future<int> importHabitsFromCSV() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // CSV yerine herhangi bir dosya türünü kabul et
        allowMultiple: false,
        withData: true,
        dialogTitle: 'Select CSV File',
      );

      if (result == null || result.files.isEmpty) {
        debugPrint('No file selected');
        return 0;
      }

      String csvContent;

      if (Platform.isIOS) {
        // iOS specific handling
        final bytes = result.files.first.bytes;
        if (bytes == null) {
          debugPrint('Could not read file bytes');
          throw Exception('Could not read file');
        }

        // Dosya adını kontrol et
        final fileName = result.files.first.name.toLowerCase();
        debugPrint('Selected file name: $fileName');

        // CSV dosyası değilse uyarı ver
        if (!fileName.endsWith('.csv')) {
          debugPrint('Selected file is not a CSV file');
          throw Exception('Please select a CSV file');
        }

        csvContent = String.fromCharCodes(bytes);

        // Debug information
        debugPrint('iOS CSV file size: ${bytes.length} bytes');
        if (bytes.isNotEmpty) {
          debugPrint('iOS CSV file content (first 100 chars): ${csvContent.substring(0, csvContent.length > 100 ? 100 : csvContent.length)}');
        } else {
          debugPrint('iOS CSV file is empty');
        }
      } else {
        // Android and other platforms
        final filePath = result.files.single.path;
        if (filePath == null) {
          debugPrint('Could not get file path');
          throw Exception('Could not get file path');
        }

        // Dosya adını kontrol et
        final fileName = result.files.first.name.toLowerCase();
        debugPrint('Selected file name: $fileName');

        // CSV dosyası değilse uyarı ver
        if (!fileName.endsWith('.csv')) {
          debugPrint('Selected file is not a CSV file');
          throw Exception('Please select a CSV file');
        }

        final file = File(filePath);
        csvContent = await file.readAsString();
        debugPrint('Android CSV file size: ${csvContent.length} chars');
        if (csvContent.isNotEmpty) {
          debugPrint('Android CSV file content (first 100 chars): ${csvContent.substring(0, csvContent.length > 100 ? 100 : csvContent.length)}');
        }
      }

      // Check if content is empty
      if (csvContent.trim().isEmpty) {
        debugPrint('CSV file is empty');
        throw Exception('CSV file is empty');
      }

      // Parse CSV with error handling
      List<List<dynamic>> rowsAsListOfValues;
      try {
        // Use more flexible CSV parsing options
        rowsAsListOfValues = const CsvToListConverter(
          shouldParseNumbers: false,
          fieldDelimiter: ',',
          eol: '\n',
          textDelimiter: '"',
          textEndDelimiter: '"',
        ).convert(csvContent);

        debugPrint('CSV parsed successfully. Rows: ${rowsAsListOfValues.length}');
        if (rowsAsListOfValues.isNotEmpty) {
          debugPrint('Header: ${rowsAsListOfValues[0]}');
        }
      } catch (e) {
        debugPrint('Error parsing CSV: $e');
        throw Exception('Invalid CSV format: $e');
      }

      // Skip header
      if (rowsAsListOfValues.isEmpty) {
        debugPrint('CSV has no rows');
        return 0;
      }

      // Get header row to determine column indices
      final headerRow = rowsAsListOfValues[0];
      final Map<String, int> columnIndices = {};

      // Define expected columns
      final expectedColumns = ['id', 'name', 'description', 'emoji', 'color_code', 'status', 'archive_date', 'completion_dates', 'reminder_time', 'reminder_days'];

      // Map column indices
      for (int i = 0; i < headerRow.length; i++) {
        final columnName = headerRow[i].toString().toLowerCase();
        if (expectedColumns.contains(columnName)) {
          columnIndices[columnName] = i;
        }
      }

      // Check for required columns
      if (!columnIndices.containsKey('id') || !columnIndices.containsKey('name')) {
        throw Exception('CSV file is missing required columns (id, name)');
      }

      // Process data
      int importedCount = 0;
      for (int i = 1; i < rowsAsListOfValues.length; i++) {
        final row = rowsAsListOfValues[i];
        if (row.length < 2) {
          debugPrint('Skipping row $i: insufficient columns (${row.length})');
          continue;
        }

        try {
          // Extract data using column indices (with fallbacks for backward compatibility)
          final id = _getColumnValue(row, columnIndices, 'id', 0);
          final name = _getColumnValue(row, columnIndices, 'name', 1);

          if (id.isEmpty || name.isEmpty) {
            debugPrint('Skipping row $i: missing id or name');
            continue;
          }

          final description = _getColumnValue(row, columnIndices, 'description', 2);
          String encodedEmoji = _getColumnValue(row, columnIndices, 'emoji', 3);

          // Base64 encoded emoji'yi decode et
          String emoji = '';
          if (encodedEmoji.isNotEmpty) {
            try {
              // Çift tırnak ve boşlukları temizle
              encodedEmoji = encodedEmoji.replaceAll('"', '').trim();
              debugPrint('Processing encoded emoji: "$encodedEmoji"');

              // Base64 olarak çözümle
              try {
                final emojiBytes = base64Decode(encodedEmoji);
                emoji = utf8.decode(emojiBytes);
                debugPrint('Decoded emoji: "$emoji"');
              } catch (e) {
                // Eğer base64 olarak çözümlenemezse, doğrudan kullan
                // Eski versiyonlarla uyumluluk için
                debugPrint('Not a valid base64 string, using directly: $e');
                emoji = encodedEmoji;
              }
            } catch (e) {
              debugPrint('Error processing emoji: $e, using empty string');
              emoji = '';
            }
          }

          // Handle color code parsing more carefully
          int colorCode;
          try {
            colorCode = int.parse(_getColumnValue(row, columnIndices, 'color_code', 4));
          } catch (e) {
            debugPrint('Error parsing color code: ${_getColumnValue(row, columnIndices, 'color_code', 4)}. Using default.');
            colorCode = 0xFF000000; // Default black color
          }

          final statusStr = _getColumnValue(row, columnIndices, 'status', 5);
          final archiveDateStr = _getColumnValue(row, columnIndices, 'archive_date', 6);
          final completionDatesStr = _getColumnValue(row, columnIndices, 'completion_dates', 7);

          // Get additional fields
          final reminderTimeStr = _getColumnValue(row, columnIndices, 'reminder_time', -1);
          final reminderDaysStr = _getColumnValue(row, columnIndices, 'reminder_days', -1);

          // Parse status
          HabitStatus status = HabitStatus.active;
          if (statusStr.toLowerCase().contains('archived')) {
            status = HabitStatus.archived;
          }

          // Parse archive date
          DateTime? archiveDate;
          if (archiveDateStr.isNotEmpty) {
            try {
              archiveDate = DateTime.parse(archiveDateStr);
            } catch (e) {
              debugPrint('Error parsing archive date: $e');
              // Try alternative date formats if standard ISO format fails
              try {
                // Try different date formats if needed
                final parts = archiveDateStr.split('-');
                if (parts.length == 3) {
                  archiveDate = DateTime(
                    int.parse(parts[0]), // year
                    int.parse(parts[1]), // month
                    int.parse(parts[2].split('T')[0]), // day
                  );
                }
              } catch (e2) {
                debugPrint('Alternative archive date parsing failed: $e2');
              }
            }
          }

          // Parse completion dates
          Map<String, CompletionEntry> completions = {};
          if (completionDatesStr.isNotEmpty) {
            debugPrint('Parsing completion dates: $completionDatesStr');
            final dateStrings = completionDatesStr.split('|');
            for (var dateStr in dateStrings) {
              try {
                final date = DateTime.parse(dateStr);
                final dateKey = date.toIso8601String().split('T')[0];
                completions[dateKey] = CompletionEntry(
                  id: _uuid.v4(),
                  date: date,
                  isCompleted: true,
                );
                debugPrint('Successfully parsed completion date: $dateStr -> $dateKey');
              } catch (e) {
                debugPrint('Error parsing completion date: $dateStr - $e');
                // Try alternative date formats if standard ISO format fails
                try {
                  // Try different date formats if needed
                  final parts = dateStr.split('-');
                  if (parts.length == 3) {
                    final datePart = parts[2].contains('T') ? parts[2].split('T')[0] : parts[2];
                    final date = DateTime(
                      int.parse(parts[0]), // year
                      int.parse(parts[1]), // month
                      int.parse(datePart), // day
                    );
                    final dateKey = date.toIso8601String().split('T')[0];
                    completions[dateKey] = CompletionEntry(
                      id: _uuid.v4(),
                      date: date,
                      isCompleted: true,
                    );
                    debugPrint('Alternative parsing successful for: $dateStr -> $dateKey');
                  }
                } catch (e2) {
                  debugPrint('Alternative completion date parsing failed: $e2');
                }
              }
            }
          }

          // Parse reminder model
          ReminderModel? reminderModel;

          // Parse reminder time
          DateTime? reminderTime;
          if (reminderTimeStr.isNotEmpty) {
            try {
              reminderTime = DateTime.parse(reminderTimeStr);
              debugPrint('Successfully parsed reminder time: $reminderTimeStr');
            } catch (e) {
              debugPrint('Error parsing reminder time: $reminderTimeStr - $e');
            }
          }

          // Parse reminder days
          List<Days>? reminderDays;
          if (reminderDaysStr.isNotEmpty) {
            try {
              final dayIndices = reminderDaysStr.split(',').map((e) => int.parse(e)).toList();
              reminderDays = dayIndices.map((index) {
                if (index >= 0 && index < Days.values.length) {
                  return Days.values[index];
                } else {
                  throw Exception('Invalid day index: $index');
                }
              }).toList();
              debugPrint('Successfully parsed reminder days: $reminderDaysStr -> $reminderDays');
            } catch (e) {
              debugPrint('Error parsing reminder days: $reminderDaysStr - $e');
            }
          }

          // Create reminder model if we have either time or days
          if (reminderTime != null || (reminderDays != null && reminderDays.isNotEmpty)) {
            reminderModel = ReminderModel(
              id: int.parse(id.hashCode.toString().substring(0, 5).replaceAll('-', '1')),
              reminderTime: reminderTime,
              days: reminderDays,
            );
          }

          debugPrint('Creating habit: $name with ${completions.length} completions');

          // Create habit
          final habit = Habit(
            id: id,
            habitName: name,
            habitDescription: description.isEmpty ? null : description,
            emoji: emoji.isEmpty ? null : emoji.trim(),
            colorCode: colorCode,
            completions: completions,
            archiveDate: archiveDate,
            status: status,
            reminderModel: reminderModel,
          );

          // Check if habit already exists
          final existingHabit = await _habitService.getHabit(id);
          if (existingHabit != null) {
            // Update existing habit
            debugPrint('Updating existing habit: $name');
            await _habitService.updateHabit(habit);
          } else {
            // Create new habit
            debugPrint('Creating new habit: $name');
            await _habitService.createHabit(habit);
          }

          importedCount++;
        } catch (e) {
          debugPrint('Error processing row $i: $e');
          // Continue with next row
        }
      }

      debugPrint('Import completed. Imported $importedCount habits.');
      return importedCount;
    } catch (e) {
      debugPrint('Error importing habits: $e');
      rethrow;
    }
  }

  // Helper method to get column value by name or index
  String _getColumnValue(List<dynamic> row, Map<String, int> columnIndices, String columnName, int fallbackIndex) {
    if (columnIndices.containsKey(columnName) && columnIndices[columnName]! < row.length) {
      return row[columnIndices[columnName]!].toString();
    } else if (fallbackIndex >= 0 && fallbackIndex < row.length) {
      return row[fallbackIndex].toString();
    }
    return '';
  }
}
