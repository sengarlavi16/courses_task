import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/course.dart';

class LocalDB {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _initDB('courses.db');
    return _db!;
  }

  static Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE courses(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT,
          description TEXT,
          categoryId INTEGER,
          categoryName TEXT,
          lessons INTEGER,
          score INTEGER
        )
      ''');

        await db.execute('''
        CREATE TABLE categories_cache(
          id INTEGER PRIMARY KEY,
          name TEXT
        )
      ''');
      },
    );
  }

  // CRUD for courses
  static Future<int> insertCourse(Course c) async {
    final db = await instance;
    return await db.insert('courses', c.toMap());
  }

  static Future<int> updateCourse(Course c) async {
    final db = await instance;
    return await db.update(
      'courses',
      c.toMap(),
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  static Future<int> deleteCourse(int id) async {
    final db = await instance;
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Course>> getAllCourses() async {
    final db = await instance;
    final rows = await db.query('courses', orderBy: 'id DESC');
    return rows.map((r) => Course.fromMap(r)).toList();
  }

  // categories cache
  static Future<void> cacheCategories(List<Map<String, dynamic>> cats) async {
    final db = await instance;
    final batch = db.batch();
    await db.delete('categories_cache');
    for (var c in cats) {
      batch.insert('categories_cache', {'id': c['id'], 'name': c['name']});
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getCachedCategories() async {
    final db = await instance;
    final rows = await db.query('categories_cache');
    return rows;
  }
}
