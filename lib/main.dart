import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'screens/user/welcome_page.dart';
import 'screens/home/settings/app_font.dart'; 
import 'screens/home/settings/app_language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppFont.loadSettings(); 
  await AppLanguage.loadLanguage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sizer tetap di paling luar
    return Sizer(
      builder: (context, orientation, deviceType) {
        
        //  Listener 1: Mendengarkan perubahan JENIS FONT
        return ValueListenableBuilder<String>(
          valueListenable: AppFont.fontNotifier,
          builder: (context, fontName, _) {
            
            //  Listener 2: Mendengarkan perubahan UKURAN FONT
            return ValueListenableBuilder<double>(
              valueListenable: AppFont.fontSizeNotifier,
              builder: (context, fontSize, _) {
                
                // Menghitung skala font 
                final double textScale = fontSize / 16.0;

                return MaterialApp(
                  title: 'Perbandingan HP',
                  debugShowCheckedModeBanner: false,
                  
                  //  Terapkan Tema dengan Font yang dipilih
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    useMaterial3: true,
                    // Mengganti font default aplikasi secara global
                    textTheme: GoogleFonts.getTextTheme(
                      fontName, 
                      ThemeData.light().textTheme,
                    ),
                  ),

                  //  Terapkan Skala Ukuran Font Global
                  builder: (context, child) {
                    // MediaQuery ini memaksa seluruh teks di child mengikuti skala kita
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        // Gunakan TextScaler.linear untuk Flutter versi terbaru
                        textScaler: TextScaler.linear(textScale),
                      ),
                      child: child!,
                    );
                  },

                  home: const WelcomePage(),
                );
              },
            );
          },
        );
      },
    );
  }
}