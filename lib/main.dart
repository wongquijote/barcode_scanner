import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Uncomment this line
import 'camera_page.dart';

void main() {
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
  bool isScanning = false;
  String scannedCode = '';

  void startScanning() {
    setState(() {
      isScanning = true;
    });
  }

  void stopScanning() {
    setState(() {
      isScanning = false;
    });
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
                isScanning
                    ? MobileScanner(
                        allowDuplicates: false,
                        onDetect: (barcode, args) {
                          if (barcode.rawValue != null) {
                            setState(() {
                              scannedCode = barcode.rawValue!;
                              isScanning = false;
                            });
                            // TODO: Communicate the identity of the product to the state machine
                          }
                        },
                      )
                    : Center(child: Text('Press the button to start scanning')),
                if (isScanning)
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
              child: Text('Scanned Code: $scannedCode'),
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
