import 'package:flutter/material.dart';

import 'scan_screen.dart';
import 'text_input_screen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Translator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Language Translator App ( Jenish Parmar )"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.translate, size: 100, color: Colors.blue),
            SizedBox(height: 40),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text("Scan Text from Image"),
              onPressed: () {
                // TODO: Go to scan screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.edit),
              label: Text("Type Text Manually"),
              onPressed: () {
                // TODO: Go to type screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TextInputScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
