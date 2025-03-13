import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../models/completion_entry/completion_entry.dart';
import '../../models/habit/habit_model.dart';
import '../../models/habit/habit_status.dart';
import '../habit_service/habit_service_interface.dart';

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
      rows.add(['id', 'name', 'description', 'emoji', 'color_code', 'status', 'archive_date', 'completion_dates']);

      // Add habit data
      for (var habit in habits) {
        // Convert completion dates to string format
        List<String> completionDates = [];
        habit.completions.forEach((key, entry) {
          if (entry.isCompleted) {
            completionDates.add(entry.date.toIso8601String());
          }
        });

        rows.add([habit.id, habit.habitName, habit.habitDescription ?? '', habit.emoji ?? '', habit.colorCode, habit.status.toString(), habit.archiveDate?.toIso8601String() ?? '', completionDates.join('|')]);
      }

      // Convert to CSV
      String csv = const ListToCsvConverter().convert(rows);

      // Save to temporary file
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/habitrise_export_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      return path;
    } catch (e) {
      debugPrint('Error exporting habits: $e');
      rethrow;
    }
  }

  // Share CSV file
  Future<void> shareCSVFile(String filePath) async {
    try {
      final file = XFile(filePath);
      await Share.shareXFiles([file], text: 'HabitRise Data Export');
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
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null) {
        return 0;
      }

      // Read file
      final file = File(result.files.single.path!);
      final contents = await file.readAsString();

      // Parse CSV
      List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(contents);

      // Skip header
      if (rowsAsListOfValues.isEmpty) {
        return 0;
      }

      // Process data
      int importedCount = 0;
      for (int i = 1; i < rowsAsListOfValues.length; i++) {
        final row = rowsAsListOfValues[i];
        if (row.length < 8) continue;

        // Extract data
        final id = row[0].toString();
        final name = row[1].toString();
        final description = row[2].toString();
        final emoji = row[3].toString();
        final colorCode = int.tryParse(row[4].toString()) ?? 0xFF000000;
        final statusStr = row[5].toString();
        final archiveDateStr = row[6].toString();
        final completionDatesStr = row[7].toString();

        // Parse status
        HabitStatus status = HabitStatus.active;
        if (statusStr.contains('archived')) {
          status = HabitStatus.archived;
        }

        // Parse archive date
        DateTime? archiveDate;
        if (archiveDateStr.isNotEmpty) {
          try {
            archiveDate = DateTime.parse(archiveDateStr);
          } catch (e) {
            // Ignore parsing errors
          }
        }

        // Parse completion dates
        Map<String, CompletionEntry> completions = {};
        if (completionDatesStr.isNotEmpty) {
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
            } catch (e) {
              // Ignore parsing errors
            }
          }
        }

        // Create habit
        final habit = Habit(
          id: id,
          habitName: name,
          habitDescription: description.isEmpty ? null : description,
          emoji: emoji.isEmpty ? null : emoji,
          colorCode: colorCode,
          completions: completions,
          archiveDate: archiveDate,
          status: status,
        );

        // Check if habit already exists
        final existingHabit = await _habitService.getHabit(id);
        if (existingHabit != null) {
          // Update existing habit
          await _habitService.updateHabit(habit);
        } else {
          // Create new habit
          await _habitService.createHabit(habit);
        }

        importedCount++;
      }

      return importedCount;
    } catch (e) {
      debugPrint('Error importing habits: $e');
      rethrow;
    }
  }
}
