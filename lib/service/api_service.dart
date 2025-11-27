import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/models/smartphone.dart';
import 'dart:io' show Platform;

class ApiService {
  // ======================================================
  // 1. KONFIGURASI IP LOKAL
  // ======================================================

  // 💡 IP PC Anda (Host)
  static const String _localHostIp = "http://192.168.1.4";

  static const String _apiFolder = "/api_hp/";

  // URL untuk Android Emulator (IP Khusus)
  static const String _emulatorUrl = "http://10.0.2.2$_apiFolder";

  // URL menggunakan IP Lokal PC
  static String get _localUrl => "$_localHostIp$_apiFolder";

  // ======================================================
  // 2. LOGIKA PENENTUAN BASE URL
  // ======================================================

  static String get baseUrl {
    // 1. Lingkungan Web: Paksa menggunakan IP Lokal PC Anda
    if (kIsWeb) {
      return _localUrl;
    }

    // 2. Lingkungan Mobile/Desktop
    try {
      if (Platform.isAndroid) {
        // Prioritaskan Android Emulator (10.0.2.2)
        return _emulatorUrl;
      }

      // 3. iOS Simulator / Perangkat Fisik non-Android / Desktop
      return _localUrl;
    } catch (e) {
      // Fallback jika 'dart:io' tidak tersedia (walaupun harusnya aman di Flutter)
      return _localUrl;
    }
  }

  // ======================================================
  // 3. DEFINISI ENDPOINT API & BASE URL GAMBAR
  // ======================================================

  // Base URL Dinamis untuk Gambar (Base URL API + folder 'images/')
  static String get baseImageUrl {
    // Contoh: http://192.168.1.32/api_hp/images/
    return "${baseUrl}images/";
  }

  /// Ensures we return a fully-qualified image URL.
  /// If the server returns a path like 'uploads/profile.jpg' or '/images/profile.jpg'
  /// this function will normalize it to: 'http://<host>/api_hp/images/...'
  static String normalizeImageUrl(String path) {
    if (path.startsWith('http')) return path;
    // Remove leading slashes
    var p = path.replaceFirst(RegExp(r'^/+'), '');
    // If the path already contains 'images/' or 'api_hp', attach to baseUrl
    if (p.startsWith('images/') || p.contains('/images/')) {
      return '${baseUrl}$p';
    }
    return '${baseImageUrl}$p';
  }

  // Properti untuk mendapatkan IP murni (digunakan di Smartphone.fromJson)
  static String get baseIp => _localHostIp; // <-- KOREKSI DILAKUKAN DI SINI

  static String get login => "${baseUrl}login.php";
  static String get register => "${baseUrl}register.php";
  static String get getPhoneDetail => "${baseUrl}get_phone_detail.php";
  static String get updatePhone => "${baseUrl}update_phone.php";
  static String get getPhonesByBrand => "${baseUrl}get_phones_by_brand.php";
  static String get createPhone => "${baseUrl}create_phone.php";

  // ======================================================
  // 4. FUNGSI FETCH DATA
  // ======================================================

  Future<List<Smartphone>> fetchPhonesByBrand(String brand) async {
    final url = Uri.parse("$getPhonesByBrand?brand=$brand");
    print("Fetching data from: $url");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      if (decoded is Map && decoded.containsKey('error')) {
        print("API Error: ${decoded['error']}");
        return [];
      }

      if (decoded is List) {
        // Map data ke List<Smartphone> menggunakan Smartphone.fromJson
        return decoded.map<Smartphone>((item) {
          // Meneruskan 'brand' sangat penting untuk konstruksi URL gambar yang benar
          return Smartphone.fromJson(item, brand);
        }).toList();
      }

      print("API response format unexpected: $decoded");
      return [];
    } else {
      throw Exception(
        "Gagal mengambil data HP: HTTP Status ${response.statusCode}",
      );
    }
  }
}
