import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart'; // 1. Import paket sizer
import 'screens/user/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Bungkus MaterialApp dengan widget Sizer
    return Sizer(
      builder: (context, orientation, deviceType) {
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
      },
    );
  }
}
