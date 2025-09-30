import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/core.dart';
import '../../features/reminder/service/reminder_service.dart';
import '../../models/completion_entry/completion_entry.dart';
import '../../models/habit/habit_difficulty.dart';
import '../../models/habit/habit_model.dart';
import '../../models/habit/habit_status.dart';
import '../../services/habit_service/habit_service_interface.dart';
import '../reminder/models/days/days_enum.dart';
import '../reminder/models/multiple_reminder/multiple_reminder_model.dart';
import '../reminder/models/reminder/reminder_model.dart';

class CSVService {
  CSVService._();
  static final CSVService _instance = CSVService._();
  static CSVService get instance => _instance;

  final _habitService = habitService;
  final _uuid = Uuid();

  // Export habits to CSV
  Future<String> exportHabitsToCSV() async {
    try {
      debugPrint('Starting CSV export process...');
      final stopwatch = Stopwatch()..start();

      // Get all habits
      final habits = await _habitService.getAllHabits();
      debugPrint('Retrieved ${habits.length} habits for export');

      // Create CSV header with all current fields
      List<List<dynamic>> rows = [];
      rows.add(['id', 'name', 'description', 'emoji', 'color_code', 'status', 'archive_date', 'completion_dates', 'completion_counts', 'daily_target', 'difficulty', 'category_ids', 'reminder_time', 'reminder_days', 'multiple_reminder_times', 'multiple_reminder_days']);

      // Add habit data
      for (var habit in habits) {
        debugPrint('Exporting habit: ${habit.habitName}, emoji: ${habit.emoji}');

        // Convert completion dates and counts to string format
        List<String> completionDates = [];
        List<String> completionCounts = [];
        habit.completions.forEach((key, entry) {
          if (entry.isCompleted) {
            completionDates.add(entry.date.toIso8601String());
            completionCounts.add(entry.count.toString());
          }
        });

        // Get reminder data
        String reminderTime = '';
        String reminderDays = '';
        String multipleReminderTimes = '';
        String multipleReminderDays = '';

        if (habit.reminderModel != null) {
          debugPrint('Processing reminder for habit: ${habit.habitName}');
          debugPrint('  - hasMultipleReminders: ${habit.reminderModel!.hasMultipleReminders}');
          debugPrint('  - hasSingleReminder: ${habit.reminderModel!.hasSingleReminder}');
          debugPrint('  - reminderTime: ${habit.reminderModel!.reminderTime}');
          debugPrint('  - multipleReminders: ${habit.reminderModel!.multipleReminders}');

          // Check if this is a multiple reminder setup
          if (habit.reminderModel!.hasMultipleReminders) {
            // Multiple reminders - use multiple reminder fields
            multipleReminderTimes = habit.reminderModel!.multipleReminders!.reminderTimes.map((time) => time.toIso8601String()).join('|');

            if (habit.reminderModel!.multipleReminders!.days != null && habit.reminderModel!.multipleReminders!.days!.isNotEmpty) {
              multipleReminderDays = habit.reminderModel!.multipleReminders!.days!.map((day) => day.index).join(',');
            }
            debugPrint('  - Exported as multiple reminder: $multipleReminderTimes');
          } else if (habit.reminderModel!.hasSingleReminder) {
            // Single reminder - use single reminder fields
            reminderTime = habit.reminderModel!.reminderTime!.toIso8601String();

            if (habit.reminderModel!.days != null && habit.reminderModel!.days!.isNotEmpty) {
              reminderDays = habit.reminderModel!.days!.map((day) => day.index).join(',');
            }
            debugPrint('  - Exported as single reminder: $reminderTime');
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
          encodedEmoji, // Base64 encoded emoji
          habit.colorCode,
          habit.status.toString(),
          habit.archiveDate?.toIso8601String() ?? '',
          completionDates.join('|'),
          completionCounts.join('|'),
          habit.dailyTarget,
          habit.difficulty.index,
          habit.categoryIds.join(','),
          reminderTime,
          reminderDays,
          multipleReminderTimes,
          multipleReminderDays,
        ]);

        debugPrint('Final export data for ${habit.habitName}:');
        debugPrint('  - reminderTime: $reminderTime');
        debugPrint('  - reminderDays: $reminderDays');
        debugPrint('  - multipleReminderTimes: $multipleReminderTimes');
        debugPrint('  - multipleReminderDays: $multipleReminderDays');
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
      final filename = 'HabitForm_export_$formattedDate.csv';
      debugPrint('Generated file name: $filename');

      // Dosyayı Documents klasörüne kaydet
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$filename';
      final file = File(filePath);
      await file.writeAsString(csv);

      stopwatch.stop();
      debugPrint('File saved to: $filePath');
      debugPrint('Export completed in ${stopwatch.elapsedMilliseconds}ms');

      // Kaydedilen dosyayı paylaş
      final xFile = XFile(filePath);
      await Share.shareXFiles(
        [xFile],
        subject: LocaleKeys.csv_service_export_subject.tr(),
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100), // iOS için gerekli
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
        subject: LocaleKeys.csv_service_export_subject.tr(),
        sharePositionOrigin: const Rect.fromLTWH(0, 0, 100, 100), // iOS için gerekli
      );
    } catch (e) {
      debugPrint('Error sharing CSV file: $e');
      rethrow;
    }
  }

  // Import habits from CSV
  Future<int> importHabitsFromCSV() async {
    try {
      debugPrint('Starting CSV import process...');
      final stopwatch = Stopwatch()..start();

      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // CSV yerine herhangi bir dosya türünü kabul et
        allowMultiple: false,
        withData: true,
        dialogTitle: LocaleKeys.csv_service_select_csv_file.tr(),
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
          throw Exception(LocaleKeys.csv_service_could_not_read_file.tr());
        }

        // Dosya adını kontrol et
        final fileName = result.files.first.name.toLowerCase();
        debugPrint('Selected file name: $fileName');

        // CSV dosyası değilse uyarı ver
        if (!fileName.endsWith('.csv')) {
          debugPrint('Selected file is not a CSV file');
          throw Exception(LocaleKeys.csv_service_please_select_csv_file.tr());
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
          throw Exception(LocaleKeys.csv_service_please_select_csv_file.tr());
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
        throw Exception(LocaleKeys.csv_service_csv_file_is_empty.tr());
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
        throw Exception(LocaleKeys.csv_service_invalid_csv_format.tr(namedArgs: {'error': e.toString()}));
      }

      // Validate CSV data
      if (!_validateCSVData(rowsAsListOfValues)) {
        throw Exception(LocaleKeys.csv_service_invalid_csv_format.tr(namedArgs: {'error': 'Invalid CSV structure'}));
      }

      // Get CSV version for compatibility info
      final csvVersion = _getCSVVersion(rowsAsListOfValues[0].map((e) => e.toString()).toList());
      debugPrint('CSV version detected: $csvVersion');

      // Get header row to determine column indices
      final headerRow = rowsAsListOfValues[0];
      final Map<String, int> columnIndices = {};

      // Define expected columns (backward compatible)
      final expectedColumns = ['id', 'name', 'description', 'emoji', 'color_code', 'status', 'archive_date', 'completion_dates', 'completion_counts', 'daily_target', 'difficulty', 'category_ids', 'reminder_time', 'reminder_days', 'multiple_reminder_times', 'multiple_reminder_days'];

      // Map column indices
      for (int i = 0; i < headerRow.length; i++) {
        final columnName = headerRow[i].toString().toLowerCase();
        if (expectedColumns.contains(columnName)) {
          columnIndices[columnName] = i;
        }
      }

      // Check for required columns
      if (!columnIndices.containsKey('id') || !columnIndices.containsKey('name')) {
        throw Exception(LocaleKeys.csv_service_missing_required_columns.tr());
      }

      // Process data
      int importedCount = 0;
      int skippedCount = 0;
      int errorCount = 0;

      for (int i = 1; i < rowsAsListOfValues.length; i++) {
        final row = rowsAsListOfValues[i];
        if (row.length < 2) {
          debugPrint('Skipping row $i: insufficient columns (${row.length})');
          skippedCount++;
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
          final completionCountsStr = _getColumnValue(row, columnIndices, 'completion_counts', 8);

          // Get new fields with backward compatibility
          final dailyTargetStr = _getColumnValue(row, columnIndices, 'daily_target', 9);
          final difficultyStr = _getColumnValue(row, columnIndices, 'difficulty', 10);
          final categoryIdsStr = _getColumnValue(row, columnIndices, 'category_ids', 11);

          // Get reminder fields
          final reminderTimeStr = _getColumnValue(row, columnIndices, 'reminder_time', 12);
          final reminderDaysStr = _getColumnValue(row, columnIndices, 'reminder_days', 13);
          final multipleReminderTimesStr = _getColumnValue(row, columnIndices, 'multiple_reminder_times', 14);
          final multipleReminderDaysStr = _getColumnValue(row, columnIndices, 'multiple_reminder_days', 15);

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

          // Parse completion dates and counts
          Map<String, CompletionEntry> completions = {};
          if (completionDatesStr.isNotEmpty) {
            debugPrint('Parsing completion dates: $completionDatesStr');
            final dateStrings = completionDatesStr.split('|');
            final countStrings = completionCountsStr.isNotEmpty ? completionCountsStr.split('|') : <String>[];

            for (int i = 0; i < dateStrings.length; i++) {
              try {
                final date = DateTime.parse(dateStrings[i]);
                final dateKey = date.toIso8601String().split('T')[0];

                // Get count for this date (default to 1 if not available)
                int count = 1;
                if (i < countStrings.length && countStrings[i].isNotEmpty) {
                  try {
                    count = int.parse(countStrings[i]);
                    if (count < 1) count = 1; // Ensure minimum count of 1
                  } catch (e) {
                    debugPrint('Error parsing completion count: ${countStrings[i]}, using default 1');
                  }
                }

                completions[dateKey] = CompletionEntry(
                  id: _uuid.v4(),
                  date: date,
                  isCompleted: true,
                  count: count,
                );
                debugPrint('Successfully parsed completion date: ${dateStrings[i]} -> $dateKey (count: $count)');
              } catch (e) {
                debugPrint('Error parsing completion date: ${dateStrings[i]} - $e');
                // Try alternative date formats if standard ISO format fails
                try {
                  // Try different date formats if needed
                  final parts = dateStrings[i].split('-');
                  if (parts.length == 3) {
                    final datePart = parts[2].contains('T') ? parts[2].split('T')[0] : parts[2];
                    final date = DateTime(
                      int.parse(parts[0]), // year
                      int.parse(parts[1]), // month
                      int.parse(datePart), // day
                    );
                    final dateKey = date.toIso8601String().split('T')[0];

                    // Get count for this date (default to 1 if not available)
                    int count = 1;
                    if (i < countStrings.length && countStrings[i].isNotEmpty) {
                      try {
                        count = int.parse(countStrings[i]);
                        if (count < 1) count = 1;
                      } catch (e) {
                        debugPrint('Error parsing completion count: ${countStrings[i]}, using default 1');
                      }
                    }

                    completions[dateKey] = CompletionEntry(
                      id: _uuid.v4(),
                      date: date,
                      isCompleted: true,
                      count: count,
                    );
                    debugPrint('Alternative parsing successful for: ${dateStrings[i]} -> $dateKey (count: $count)');
                  }
                } catch (e2) {
                  debugPrint('Alternative completion date parsing failed: $e2');
                }
              }
            }
          }

          // Parse new fields
          int dailyTarget = 1;
          if (dailyTargetStr.isNotEmpty) {
            try {
              dailyTarget = int.parse(dailyTargetStr);
              if (dailyTarget < 1) dailyTarget = 1; // Ensure minimum of 1
            } catch (e) {
              debugPrint('Error parsing daily target: $dailyTargetStr, using default 1');
            }
          }

          HabitDifficulty difficulty = HabitDifficulty.moderate;
          if (difficultyStr.isNotEmpty) {
            try {
              final difficultyIndex = int.parse(difficultyStr);
              if (difficultyIndex >= 0 && difficultyIndex < HabitDifficulty.values.length) {
                difficulty = HabitDifficulty.values[difficultyIndex];
              }
            } catch (e) {
              debugPrint('Error parsing difficulty: $difficultyStr, using default moderate');
            }
          }

          List<String> categoryIds = [];
          if (categoryIdsStr.isNotEmpty) {
            categoryIds = categoryIdsStr.split(',').where((id) => id.trim().isNotEmpty).toList();
          }

          // Parse reminder model
          ReminderModel? reminderModel;

          // Parse single reminder
          DateTime? reminderTime;
          if (reminderTimeStr.isNotEmpty) {
            try {
              reminderTime = DateTime.parse(reminderTimeStr);
              debugPrint('Successfully parsed reminder time: $reminderTimeStr');
            } catch (e) {
              debugPrint('Error parsing reminder time: $reminderTimeStr - $e');
            }
          }

          List<Days>? reminderDays;
          if (reminderDaysStr.isNotEmpty) {
            try {
              final dayIndices = reminderDaysStr.split(',').map((e) => int.parse(e)).toList();
              reminderDays = dayIndices.map((index) {
                if (index >= 0 && index < Days.values.length) {
                  return Days.values[index];
                } else {
                  throw Exception(LocaleKeys.csv_service_invalid_day_index.tr(namedArgs: {'index': index.toString()}));
                }
              }).toList();
              debugPrint('Successfully parsed reminder days: $reminderDaysStr -> $reminderDays');
            } catch (e) {
              debugPrint('Error parsing reminder days: $reminderDaysStr - $e');
            }
          }

          // Parse multiple reminders
          MultipleReminderModel? multipleReminders;
          if (multipleReminderTimesStr.isNotEmpty) {
            try {
              final timeStrings = multipleReminderTimesStr.split('|');
              final reminderTimes = timeStrings.map((timeStr) => DateTime.parse(timeStr)).toList();

              List<Days>? multipleReminderDays;
              if (multipleReminderDaysStr.isNotEmpty) {
                try {
                  final dayIndices = multipleReminderDaysStr.split(',').map((e) => int.parse(e)).toList();
                  multipleReminderDays = dayIndices.map((index) {
                    if (index >= 0 && index < Days.values.length) {
                      return Days.values[index];
                    } else {
                      throw Exception(LocaleKeys.csv_service_invalid_day_index.tr(namedArgs: {'index': index.toString()}));
                    }
                  }).toList();
                } catch (e) {
                  debugPrint('Error parsing multiple reminder days: $multipleReminderDaysStr - $e');
                }
              }

              multipleReminders = MultipleReminderModel(
                id: int.parse(id.hashCode.toString().substring(0, 5).replaceAll('-', '1')),
                reminderTimes: reminderTimes,
                days: multipleReminderDays,
              );
              debugPrint('Successfully parsed multiple reminders: $multipleReminderTimesStr');
            } catch (e) {
              debugPrint('Error parsing multiple reminder times: $multipleReminderTimesStr - $e');
            }
          }

          // Create reminder model if we have any reminder data
          if (reminderTime != null || (reminderDays != null && reminderDays.isNotEmpty) || (multipleReminders != null && multipleReminders.isValid)) {
            reminderModel = ReminderModel(
              id: int.parse(id.hashCode.toString().substring(0, 5).replaceAll('-', '1')),
              reminderTime: reminderTime,
              days: reminderDays,
              multipleReminders: multipleReminders,
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
            dailyTarget: dailyTarget,
            difficulty: difficulty,
            categoryIds: categoryIds,
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

          // Eğer hatırlatıcı varsa, bildirimleri tekrar ayarla
          if (habit.reminderModel != null && habit.status == HabitStatus.active) {
            debugPrint('Setting up reminder notification for habit: ${habit.habitName}');
            try {
              await ReminderService.createReminderNotification(
                habit.reminderModel!,
                habit.habitName,
                LocaleKeys.habit_timeToCompleteYourHabit.tr(),
              );
            } catch (e) {
              debugPrint('Error setting up reminder notification: $e');
              // Continue with import even if reminder setup fails
            }
          }

          importedCount++;
        } catch (e) {
          debugPrint('Error processing row $i: $e');
          errorCount++;
          // Continue with next row
        }
      }

      stopwatch.stop();
      debugPrint('Import completed. Imported $importedCount habits, skipped $skippedCount rows, $errorCount errors in ${stopwatch.elapsedMilliseconds}ms.');
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

  // Validate CSV data before processing
  bool _validateCSVData(List<List<dynamic>> rows) {
    if (rows.isEmpty) {
      debugPrint('CSV validation failed: No rows found');
      return false;
    }

    if (rows.length < 2) {
      debugPrint('CSV validation failed: No data rows found (only header)');
      return false;
    }

    // Check if header has required columns
    final header = rows[0];
    if (!header.contains('id') || !header.contains('name')) {
      debugPrint('CSV validation failed: Missing required columns (id, name)');
      return false;
    }

    debugPrint('CSV validation passed: ${rows.length - 1} data rows found');
    return true;
  }

  // Get CSV version for backward compatibility
  String _getCSVVersion(List<String> header) {
    if (header.contains('multiple_reminder_times')) {
      return '2.0'; // Current version with all features
    } else if (header.contains('daily_target')) {
      return '1.1'; // Version with daily target and difficulty
    } else {
      return '1.0'; // Original version
    }
  }
}
