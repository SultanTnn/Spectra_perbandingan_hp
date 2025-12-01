import '../service/api_service.dart';

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
  final String? purchaseUrl; 
  final String? shopeeUrl; 
  final String? tokopediaUrl; 

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
    this.purchaseUrl,
    this.shopeeUrl,
    this.tokopediaUrl,
  });

  factory Smartphone.fromJson(Map<String, dynamic> json, [String brand = '']) {
    String rawImagePath = json['image_url'] ?? '';
    String finalImageUrl = '';
    const String pathMarker = '/api_hp/images/';
    int startIndex = rawImagePath.indexOf(pathMarker);
    if (startIndex != -1) {
      String correctRelativePath = rawImagePath.substring(startIndex);
      finalImageUrl = "${ApiService.baseIp}$correctRelativePath";
    } else {
      final String brandName = (json['brand'] ?? brand)
          .toString()
          .toLowerCase();
      final String normalizedBrandFolder = brandName.isNotEmpty
          ? brandName.substring(0, 1).toUpperCase() + brandName.substring(1)
          : 'Unknown';
      finalImageUrl =
          "${ApiService.baseImageUrl}$normalizedBrandFolder/$rawImagePath";
    }
    // Decode first to ensure we don't double encode if the DB already has %20
    final String encodedUrl = Uri.encodeFull(Uri.decodeFull(finalImageUrl));
    String modelName = json['nama_model'] ?? '';
    String searchShopee =
        "https://shopee.co.id/search?keyword=$modelName $brand";
    String searchTokopedia =
        "https://www.tokopedia.com/search?st=product&q=$modelName $brand";

    return Smartphone(
      id: json['id'].toString(),
      namaModel: modelName,
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
      brand: json['brand'] ?? brand,
      imageUrl: encodedUrl,
      purchaseUrl: json['purchase_url'],
      shopeeUrl: json['shopee_url'] ?? searchShopee,
      tokopediaUrl: json['tokopedia_url'] ?? searchTokopedia,
    );
  }
}
