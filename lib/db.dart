import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;
  static const String tableName = 'product';

  Future<Database> get database async {
    if (_database != null) return _database!;

    // If _database is null we instantiate it
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    // Get a location using path_provider
    String path = join(await getDatabasesPath(), 'smartcart_ws.db');

    // Open/create the database at a given path
    return await openDatabase(path, version: 1, onCreate: _createDatabase);
  }

  void _createDatabase(Database db, int version) async {
    // You might not need to recreate tables if they already exist
    // Example: await db.execute('CREATE TABLE IF NOT EXISTS your_table (id INTEGER PRIMARY KEY, name TEXT)');
  }

  Future<List<Map<String, dynamic>>> query(String sql) async {
    Database db = await database;
    return await db.rawQuery(sql);
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    Database db = await database;
    return await db.insert(table, data);
  }

  // Add more methods as needed (update, delete, etc.)
}
