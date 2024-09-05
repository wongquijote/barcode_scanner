import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; 
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'db.dart';
// import 'product.dart';

Future<Database> copyDatabase() async {
  var databasesPath = await getDatabasesPath();
  var path = p.join(databasesPath, "smartcart_ws.db");

  // Check if the database exists
  var exists = await databaseExists(path);

  if (!exists) {
    // Should happen only the first time you launch your application
    print("Creating new copy from asset");

    // Make sure the parent directory exists
    try {
      await Directory(p.dirname(path)).create(recursive: true);
    } catch (_) {}
      
    // Copy from asset
    ByteData data = await rootBundle.load(p.url.join("assets", "example.db"));
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

// Future<List<Map<String, dynamic>>> queryTable(String tableName) async {
//   final db = await openDatabase('path_to_your_database.db');
  
//   // Query the table
//   List<Map<String, dynamic>> results = await db.query(tableName);

//   return results;
// }

void main() async {
  runApp(CameraApp());
}

class CameraApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode Scanner App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BarcodeScannerScreen(), // Changed to BarcodeScannerScreen()
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  @override
  _BarcodeScannerScreenState createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  List<Product> _products = [];
  bool isScanning = true;
  String scannedCode = '';
  String productName = '';
  bool isLoading = false;


  @override
  void initState() {
    super.initState();
    // var db = await copyDatabase();
  }

  Future<void> _loadDatabase() async {
    // _products = await DatabaseHelper().getAllProducts();
    // setState(() {});  // Update the UI with the loaded products
    // print(_products);
    await DatabaseHelper().database;
  }

  Future<void> _fetchItem(String id) async {
    final db = await DatabaseHelper().database;
    // var p1 = Product(
    //   id: '044000030490',
    //   name: 'Chicken in a Biskit Original Baked Snack Crackers, 7.5 Oz',
    //   price: 1,
    //   weight: 2,
    //   active: true,

    // );
    // await DatabaseHelper().insert(p1);
    if (id.length == 12) {
      id = '0' + id;
    }
    final List<Map<String, dynamic>> result = await db.query(
      'product',
      where: 'id = ?',
      whereArgs: [id],
    );

    setState(() {
      if (result.isNotEmpty) {
        productName = result.first['name'];
      } else {
        productName = 'Item not found in the database';
      }
    });
  }

  void startScanning() {
    setState(() {
      isLoading = false;
      isScanning = true;
      scannedCode = '';
      productName = 'butt';
    });
  }

  void stopScanning() {
    setState(() {
      isLoading = false;
      isScanning = false;
    });
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Barcode Scan Result"),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onBarcodeDetected(Barcode barcode, MobileScannerArguments? args) async {
    if (barcode.rawValue != null) {
      String code = barcode.rawValue!;
      setState(() {
        scannedCode = code;
        isScanning = false;
        isLoading = true;
      });

      // Fetch the item asynchronously and wait until it finishes
      await _fetchItem(scannedCode);

      // Stop loading after query completes
      setState(() {
        isLoading = false;
      });

      // Show dialog after productName is updated
      _showDialog('$productName');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Scanner'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                if (isLoading)
                  Center(child: CircularProgressIndicator()) // Show loading spinner
                else
                  isScanning
                      ? MobileScanner(
                          allowDuplicates: false,
                          onDetect: onBarcodeDetected,
                        )
                      : Center(child: Text('Press the button to start scanning')),
                if (isScanning && !isLoading)
                  Center(
                    child: Container(
                      width: 300, // Adjust the width of the rectangle
                      height: 200, // Adjust the height of the rectangle
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.red, // Color of the border
                          width: 2, // Width of the border
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (scannedCode.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                productName.isNotEmpty
                    ? 'Product: $productName\nBarcode: $scannedCode'
                    : 'Scanned Code: $scannedCode',
                textAlign: TextAlign.center,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startScanning,
                  child: Text('Start Scanning'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: stopScanning,
                  child: Text('Stop Scanning'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
