import 'package:flutter/material.dart';
import 'screens/welcome_page.dart'; // Mengarah ke halaman WelcomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perbandingan HP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      // Halaman pertama yang dibuka adalah WelcomePage
      home: const WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
