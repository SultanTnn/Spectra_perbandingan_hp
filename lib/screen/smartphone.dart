// Lokasi: lib/models/smartphone.dart

class Smartphone {
  final String id;
  final String brand;
  final String namaModel;
  final String body;
  final String display;
  final String platform;
  final String memory;
  final String mainCamera;
  final String selfieCamera;
  final String comms;    // <-- FIELD BARU
  final String features; // <-- FIELD BARU
  final String battery;
  final String price;
  final String imageUrl; // <-- FIELD WAJIB UNTUK GAMBAR

  Smartphone({
    required this.id,
    required this.brand,
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
    required this.imageUrl, // <-- Wajib di constructor
  });

  factory Smartphone.fromJson(Map<String, dynamic> json, String brand) {
    // Brand diambil dari parameter karena tidak selalu ada di JSON
    // Pastikan semua kunci yang diakses ada di database Anda
    return Smartphone(
      id: json['id'].toString(),
      brand: brand,
      namaModel: json['nama_model'] ?? 'N/A',
      body: json['body'] ?? 'N/A',
      display: json['display'] ?? 'N/A',
      platform: json['platform'] ?? 'N/A',
      memory: json['memory'] ?? 'N/A',
      mainCamera: json['main_camera'] ?? 'N/A',
      selfieCamera: json['selfie_camera'] ?? 'N/A',
      comms: json['comms'] ?? 'N/A',      // <-- Parsing data comms
      features: json['features'] ?? 'N/A',  // <-- Parsing data features
      battery: json['battery'] ?? 'N/A',
      price: json['price'] ?? 'N/A',
      imageUrl: json['image_url'] ?? '', // <-- WAJIB: Parsing URL gambar dari PHP
    );
  }
}