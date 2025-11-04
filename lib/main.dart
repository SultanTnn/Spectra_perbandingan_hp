import 'package:flutter/material.dart';
// Import halaman home Anda yang sudah kita perbaiki
import 'screen/screen_home.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perbandingan HP', // Judul aplikasi Anda
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Atur HomeScreen sebagai halaman utama
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false, // Menghilangkan banner "DEBUG"
    );
  }
}