import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/screen/smartphone.dart';
import 'dart:io' show Platform; // Diperlukan untuk mendeteksi Platform

class ApiService {

  // ======================================================
  // 1. KONFIGURASI IP LOKAL (WAJIB DIGANTI)
  // ======================================================
  
  // 💡 GANTI dengan IP Lokal PC Anda (Contoh: 192.168.1.18)
  static const String _localHostIp = "YOUR_PC_LOCAL_IP_ADDRESS"; 
  
  // URL untuk Android Emulator (IP Khusus)
  static const String _emulatorUrl = "http://10.0.2.2/api_hp/";

  // URL menggunakan IP Lokal PC (untuk Perangkat Fisik/iOS Simulator)
  static String get _localUrl => "http://$_localHostIp/api_hp/";

  // ======================================================
  // 2. LOGIKA PENENTUAN BASE URL
  // ======================================================

  static String get baseUrl {
    // 1. Lingkungan Web (Browser)
    if (kIsWeb) {
      return "http://localhost/api_hp/";
    } 
    
    // 2. Lingkungan Mobile/Desktop
    try {
      // Cek apakah platform adalah Android
      if (Platform.isAndroid) {
        // Pilihan A: Prioritaskan Android Emulator (paling umum di development)
        return _emulatorUrl;
        
        // Pilihan B: Prioritaskan Perangkat Fisik (uncomment baris di bawah)
        // return _localUrl; 
      } 
      
      // 3. iOS Simulator / Desktop / Perangkat Fisik non-Android
      return _localUrl;

    } catch (e) {
      // Fallback jika terjadi error platform detection
      return _localUrl;
    }
  }

  // ======================================================
  // 3. DEFINISI ENDPOINT API
  // ======================================================

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
    print("Fetching data from: $url"); // Debugging

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);

      // ❗ Pengecekan Error API: Jika API mengirim Map (error JSON), return list kosong
      if (decoded is Map && decoded.containsKey('error')) {
        print("API Error: ${decoded['error']}");
        return []; 
      }
      
      // Jika API sukses mengirim List → lanjut ke parsing
      if (decoded is List) {
        return decoded.map<Smartphone>((item) {
          // Pengecekan agar image_url tidak null atau kosong
          if (item['image_url'] == null || item['image_url'].toString().isEmpty) {
            item['image_url'] = ""; 
          }
          return Smartphone.fromJson(item, brand);
        }).toList();
      }

      // Jika format lain → kembalikan list kosong
      print("API response format unexpected: $decoded");
      return [];

    } else {
      // Jika status code bukan 200 (misalnya 404, 500)
      throw Exception("Gagal mengambil data HP: HTTP Status ${response.statusCode}");
    }
  }
}