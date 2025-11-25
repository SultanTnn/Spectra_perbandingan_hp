import 'package:flutter_application_1/service/api_service.dart';
import 'dart:core';

class Smartphone {
  final String id;
  final String namaModel;
  final String body;
  final String display;
  final String platform;
  final String memory;
  final String mainCamera;
  final String selfieCamera;
  final String comms;
  final String features;
  final String battery;
  final String price;
  final String brand;
  final String imageUrl;
  final String? purchaseUrl; // <-- PENAMBAHAN PROPERTI BARU

  Smartphone({
    required this.id,
    required this.namaModel,
    required this.body,
    required this.display,
    required this.platform,
    required this.memory,
    required this.mainCamera,
    required this.selfieCamera,
    required this.comms,
    required this.features,
    required this.battery,
    required this.price,
    required this.brand,
    required this.imageUrl,
    this.purchaseUrl, // <-- PENAMBAHAN DI KONSTRUKTOR
  });

  /// Factory Constructor untuk parsing JSON
  factory Smartphone.fromJson(Map<String, dynamic> json, String brand) {
    
    // Ambil URL mentah dari JSON
    String rawImagePath = json['image_url'] ?? '';
    String finalImageUrl = '';
    
    // --- Logika Perbaikan URL (TIDAK ADA PERUBAHAN) ---
    
    // Marker yang menandakan dimulainya path gambar yang benar: /api_hp/images/
    const String pathMarker = '/api_hp/images/';
    
    // Cari posisi marker di dalam URL mentah (rawImagePath)
    int startIndex = rawImagePath.indexOf(pathMarker);

    if (startIndex != -1) {
      // KASUS 1: URL mentah mengandung path yang benar (meski mungkin diapit path yang salah)
      
      // Ambil path relatif yang benar (e.g., /api_hp/images/tecno/Tecno+Spark+20+Pro.jpg)
      String correctRelativePath = rawImagePath.substring(startIndex);
      
      // Gabungkan Base IP (dari ApiService) dengan path relatif yang sudah benar.
      finalImageUrl = "${ApiService.baseIp}$correctRelativePath";
    } else {
      // KASUS 2: URL mentah diasumsikan hanya nama file, atau struktur path benar-benar berbeda.
      
      // Buat nama folder Brand dengan casing yang benar (Apple, Vivo, dll.)
      final String brandName = brand.toLowerCase();
      final String normalizedBrandFolder = brandName.substring(0, 1).toUpperCase() + brandName.substring(1);
      
      // Gabungkan Base Image URL lengkap (dari ApiService) dengan Brand Folder dan nama file.
      finalImageUrl = "${ApiService.baseImageUrl}$normalizedBrandFolder/$rawImagePath";
    }

    // Lakukan encoding URL secara penuh untuk menangani spasi (menjadi %20)
    final String encodedUrl = Uri.encodeFull(finalImageUrl);

    print("Final Image URL: $encodedUrl");
    
    // --- PENGAMBILAN DATA purchaseUrl BARU ---
    final String? purchaseUrl = json['purchase_url']; 
    // Jika kolom 'purchase_url' tidak ada di JSON, nilai ini akan null secara aman.
    
    return Smartphone(
      id: json['id'].toString(),
      namaModel: json['nama_model'] ?? 'N/A',
      body: json['body'] ?? 'N/A',
      display: json['display'] ?? 'N/A',
      platform: json['platform'] ?? 'N/A',
      memory: json['memory'] ?? 'N/A',
      mainCamera: json['main_camera'] ?? 'N/A',
      selfieCamera: json['selfie_camera'] ?? 'N/A',
      comms: json['comms'] ?? 'N/A',
      features: json['features'] ?? 'N/A',
      battery: json['battery'] ?? 'N/A',
      price: json['price'] ?? 'N/A',
      brand: brand,
      imageUrl: encodedUrl,
      purchaseUrl: purchaseUrl, // <-- SET NILAI BARU
    );
  }
}