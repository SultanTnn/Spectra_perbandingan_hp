import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppFont {
  static const String keyFontFamily = 'app_font_family';
  static const String keyFontSize = 'app_font_size';

  // Default values
  static const double defaultFontSize = 16.0;
  static const String defaultFontFamily = 'Roboto';

  // Notifiers untuk UI listener
  static ValueNotifier<String> fontNotifier = ValueNotifier(defaultFontFamily);
  static ValueNotifier<double> fontSizeNotifier = ValueNotifier(defaultFontSize);

  // Daftar Font
  static final List<String> availableFonts = [
    'Roboto',
    'Montserrat',
    'Poppins',
    'Lato',
    'Open Sans',
    'Oswald',
    'Merriweather',
  ];

  // Load data dari penyimpanan lokal
  static Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Font Family
    String? savedFont = prefs.getString(keyFontFamily);
    if (savedFont != null && availableFonts.contains(savedFont)) {
      fontNotifier.value = savedFont;
    }

    // Load Font Size
    double? savedSize = prefs.getDouble(keyFontSize);
    if (savedSize != null) {
      fontSizeNotifier.value = savedSize;
    }
  }

  // Ganti Font Family
  static Future<void> changeFontFamily(String fontName) async {
    fontNotifier.value = fontName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyFontFamily, fontName);
  }

  // Ganti Font Size
  static Future<void> changeFontSize(double size) async {
    fontSizeNotifier.value = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(keyFontSize, size);
  }

  // Reset ke Default
  static Future<void> resetSettings() async {
    await changeFontFamily(defaultFontFamily);
    await changeFontSize(defaultFontSize);
  }
}