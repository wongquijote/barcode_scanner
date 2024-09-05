import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
// import 'product.dart';

import 'dart:typed_data';

class Product {
  final String id;
  final String name;
  final String? image;
  final double price;
  final double weight;
  final double? rating;
  final Uint8List? nutritionImage;
  final Uint8List? locationImage;
  final bool active;

  Product({
    required this.id,
    required this.name,
    this.image,
    required this.price,
    required this.weight,
    this.rating,
    this.nutritionImage,
    this.locationImage,
    required this.active,
  });

  // Factory constructor to create a Product from a Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      price: map['price'],
      weight: map['weight'],
      rating: map['rating'],
      nutritionImage: map['nutrition_image'],
      locationImage: map['location_image'],
      active: map['active'] == 1,  // SQLite stores booleans as integers (0 or 1)
    );
  }

  // Method to convert a Product to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'weight': weight,
      'rating': rating,
      'nutrition_image': nutritionImage,
      'location_image': locationImage,
      'active': active ? 1 : 0,  // Convert boolean to integer (1 or 0)
    };
  }
}


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
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "smartcart_ws.db");

    // Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}
        
      // Copy from asset
      ByteData data = await rootBundle.load('assets/smartcart_ws.db');
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      
      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);

    } else {
      print("Opening existing database");
    }

    // open the database
    var db = await openDatabase(path, readOnly: true);
    return db;
  }

  // Future<Database> _initDatabase() async {
  //   // Directory documentsDirectory = await getApplicationDocumentsDirectory();
  //   // String path = join(documentsDirectory.path, "smartcart_ws.db");

  //   // Open the database
  //   // return await openDatabase(path, 
  //   // onCreate: (db, version) {
  //   //     return db.execute('''
  //   //       CREATE TABLE product (
  //   //         id TEXT PRIMARY KEY,
  //   //         name TEXT NOT NULL,
  //   //         image TEXT,
  //   //         price REAL NOT NULL,
  //   //         weight REAL NOT NULL,
  //   //         rating REAL,
  //   //         nutrition_image BLOB,
  //   //         location_image BLOB,
  //   //         active INTEGER NOT NULL DEFAULT 0
  //   //       )
  //   //     ''');
  //   //   },
  //   //   version: 1,
  //   // );
  //   return await copyDatabase();
  // }

  Future<void> insert(Product product) async {
    final Database db = await database;
    await db.insert(
      'product',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('product');

    return List.generate(maps.length, (i) {
      return Product.fromMap(maps[i]);
    });
  }

  // Query a specific item by ID
  Future<Map<String, dynamic>?> queryItemById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> results = await db.query(
      'product',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }

}
