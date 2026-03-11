import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/course.dart';
import '../models/task.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'timetable.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        teacher TEXT DEFAULT '',
        classroom TEXT DEFAULT '',
        dayOfWeek INTEGER NOT NULL,
        sectionIndex INTEGER NOT NULL,
        sectionName TEXT DEFAULT '',
        weeks TEXT DEFAULT ''
      )
    ''');
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE memos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseName TEXT NOT NULL,
        content TEXT NOT NULL,
        deadline TEXT,
        isDone INTEGER DEFAULT 0
      )
    ''');
    await _createTasksTable(db);
  }

  Future<void> _createTasksTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        linkedCourse TEXT,
        type TEXT NOT NULL DEFAULT 'other',
        priority TEXT NOT NULL DEFAULT 'medium',
        deadline TEXT,
        remindAt TEXT,
        isDone INTEGER NOT NULL DEFAULT 0,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS courses');
      await db.execute('''
        CREATE TABLE courses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          teacher TEXT DEFAULT '',
          classroom TEXT DEFAULT '',
          dayOfWeek INTEGER NOT NULL,
          sectionIndex INTEGER NOT NULL,
          sectionName TEXT DEFAULT '',
          weeks TEXT DEFAULT ''
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS memos (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          courseName TEXT NOT NULL,
          content TEXT NOT NULL,
          deadline TEXT,
          isDone INTEGER DEFAULT 0
        )
      ''');
    }
    if (oldVersion < 4) {
      await _createTasksTable(db);
      // 迁移 memos → tasks
      await _migrateMemos(db);
    }
  }

  Future<void> _migrateMemos(Database db) async {
    final memos = await db.query('memos');
    final now = DateTime.now().toIso8601String();
    final batch = db.batch();
    for (final m in memos) {
      batch.insert('tasks', {
        'title': m['content'] as String,
        'description': '',
        'linkedCourse': m['courseName'] as String,
        'type': 'other',
        'priority': 'medium',
        'deadline': m['deadline'],
        'remindAt': null,
        'isDone': m['isDone'] ?? 0,
        'createdAt': now,
        'updatedAt': now,
      });
    }
    await batch.commit(noResult: true);
  }

  // --- 课程 CRUD ---

  Future<int> insertCourse(Course course) async {
    final db = await database;
    return await db.insert('courses', course.toMap());
  }

  Future<void> insertCourses(List<Course> courses) async {
    final db = await database;
    final batch = db.batch();
    for (final course in courses) {
      batch.insert('courses', course.toMap());
    }
    await batch.commit(noResult: true);
  }

  Future<List<Course>> getAllCourses() async {
    final db = await database;
    final maps = await db.query('courses');
    return maps.map((m) => Course.fromMap(m)).toList();
  }

  Future<int> deleteCourse(int id) async {
    final db = await database;
    return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllCourses() async {
    final db = await database;
    await db.delete('courses');
  }

  // --- 任务 CRUD ---

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    return await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      orderBy: 'isDone ASC, deadline ASC, priority DESC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getPendingTasks() async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'isDone = 0',
      orderBy: '''
        CASE priority WHEN 'high' THEN 0 WHEN 'medium' THEN 1 ELSE 2 END ASC,
        deadline ASC
      ''',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'isDone = 1',
      orderBy: 'updatedAt DESC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<Task>> getTasksByCourse(String courseName) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'linkedCourse = ?',
      whereArgs: [courseName],
      orderBy: 'isDone ASC, deadline ASC',
    );
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  Future<List<String>> getDistinctCourseNames() async {
    final db = await database;
    final maps = await db.rawQuery(
      'SELECT DISTINCT name FROM courses ORDER BY name',
    );
    return maps.map((m) => m['name'] as String).toList();
  }

  // --- 设置 ---

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }
}
