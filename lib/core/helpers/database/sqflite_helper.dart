// import 'package:path/path.dart';
// import 'package:sqflite/sqflite.dart';

// class SqfliteHelper<T> {
//   static const _databaseName = 'habit.db';
//   static const _databaseVersion = 1;

//   // Singleton Pattern
//   SqfliteHelper._();
//   static final SqfliteHelper shared = SqfliteHelper._();

//   Database? _database;

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     var dbPath = await getDatabasesPath();
//     String path = join(dbPath, _databaseName);
//     return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     // Bu metod, veritabanı şeması için özelleştirilebilir
//     // Her tabloyu burada oluşturan SQL komutlarını yazabilirsiniz
//     // Örnek bir tablo:
//     await db.execute('''
//       CREATE TABLE tasks (
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         name TEXT NOT NULL,
//         status TEXT NOT NULL
//       )
//     ''');
//   }

//   // Generic insert method
//   Future<int> insert<T>(String table, Map<String, dynamic> values) async {
//     Database db = await database;
//     return await db.insert(
//       table,
//       values,
//       conflictAlgorithm: ConflictAlgorithm.replace,
//     );
//   }

//   // Generic get all items method
//   Future<List<Map<String, dynamic>>> getAll<T>(String table) async {
//     Database db = await database;
//     return await db.query(table);
//   }

//   // Generic update method
//   Future<int> update<T>(String table, Map<String, dynamic> values, int id) async {
//     Database db = await database;
//     return await db.update(
//       table,
//       values,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }

//   // Generic delete method
//   Future<int> delete<T>(String table, int id) async {
//     Database db = await database;
//     return await db.delete(
//       table,
//       where: 'id = ?',
//       whereArgs: [id],
//     );
//   }
// }
