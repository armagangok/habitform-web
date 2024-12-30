import 'package:sqflite/sqflite.dart';

import '../../core/core.dart';
import '../../models/models.dart';
import 'i_single_habit_service.dart';

const _habitTableName = 'singleHabit';

class SingleHabitService extends IHabitService {
  static final shared = SingleHabitService._();
  SingleHabitService._() {
    getDatabase();
  }

  late Database _database;

  Future<void> getDatabase() async {
    try {
      String path = await getDatabasesPath(); // Get the database directory path
      print(path);

      String dbPath = '$path/SingleHabits.db'; // Define the database file path
      print(dbPath);

      _database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) {
          db.execute('''
          CREATE TABLE IF NOT EXISTS $_habitTableName (
            id TEXT PRIMARY KEY,
            habitName TEXT NOT NULL,
            habitDescription TEXT,
            completeTime INTEGER NOT NULL,
            icon TEXT,
            isCompletedToday INTEGER DEFAULT 0,
            completionDates TEXT,
            reminderModel TEXT
          )
        ''');
        },
      );
    } catch (e) {
      LogHelper.shared.debugPrint('$e'); // Log any errors
    }
  }
  // Future<void> initializePathAndDatabaseObject() async {
  //   final databaseDirectoryPath = await getDatabasesPath();
  //   final databasePath = join(databaseDirectoryPath, "SingleHabit.gb");
  //   LogHelper.shared.debugPrint(databasePath);
  //   _database = await openDatabase(databasePath);
  // }

  @override
  Future<int> insertHabit(Habit habit) async {
    return await _database.insert(
      _habitTableName,
      habit.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Habit>> getAllHabits() async {
    final List<Map<String, Object?>> maps = await _database.query(_habitTableName);

    LogHelper.shared.debugPrint('$maps');
    LogHelper.shared.debugPrint('${maps.runtimeType}');

    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  @override
  Future<Habit?> getHabitById(String id) async {
    final List<Map<String, dynamic>> maps = await _database.query(
      _habitTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Habit.fromMap(maps.first);
    }
    return null;
  }

  @override
  Future<int> updateHabit(Habit habit) async {
    return await _database.update(
      _habitTableName,
      habit.toMap(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  @override
  Future<int> deleteHabit(String id) async {
    return await _database.delete(
      _habitTableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> markHabitAsCompleted(String id) async {
    // Günün tarihini al ve completionDates'e ekle
    // final habit = await getHabitById(id);
    // if (habit != null) {
    //   final Set<Days> updatedDates = habit.reminderModel?.days ?? {};
    //   updatedDates.add(DateTime.now());

    //   final updatedHabit = habit.copyWith(
    //     isCompletedToday: true,
    //     completionDates: updatedDates,
    //   );

    //   await updateHabit(updatedHabit);
    // }
  }

  @override
  Future<List<Habit>> getCompletedHabits() async {
    final List<Map<String, dynamic>> maps = await _database.query(
      _habitTableName,
      where: 'isCompletedToday = ?',
      whereArgs: [1],
    );
    return maps.map((map) => Habit.fromMap(map)).toList();
  }

  @override
  Future<void> resetDailyCompletion() async {
    await _database.update(
      _habitTableName,
      {'isCompletedToday': 0},
    );
  }

  @override
  Future<List<Habit>> getHabitsByCompletionDate(DateTime date) async {
    // final List<Map<String, dynamic>> maps = await _database.query(_habitTableName);

    // final List<Habit> allHabits = maps.map((map) => Habit.fromMap(map)).toList();
    // final List<Habit> filteredHabits = allHabits.where((habit) {
    //   final completionDates = habit.completionDates ?? [];
    //   return completionDates.any((d) => d.year == date.year && d.month == date.month && d.day == date.day);
    // }).toList();

    return [];
  }
}
