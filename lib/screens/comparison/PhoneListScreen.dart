import 'package:flutter/material.dart';
import '../../service/api_service.dart';
import '../../models/smartphone.dart';

class PhoneListScreen extends StatefulWidget {
  final String brand;
  const PhoneListScreen({Key? key, required this.brand}) : super(key: key);

  @override
  State<PhoneListScreen> createState() => _PhoneListScreenState();
}

class _PhoneListScreenState extends State<PhoneListScreen> {
  late Future<List<Smartphone>> _phonesFuture;

  @override
  void initState() {
    super.initState();
    _phonesFuture = ApiService().fetchPhonesByBrand(widget.brand);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('HP ${widget.brand.toUpperCase()}')),
      body: FutureBuilder<List<Smartphone>>(
        future: _phonesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada data HP ditemukan.'));
          }

          final phones = snapshot.data!;

          return ListView.builder(
            itemCount: phones.length,
            itemBuilder: (context, index) {
              final phone = phones[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  leading: SizedBox(
                    width: 80,
                    height: 80,
                    child: phone.imageUrl.isNotEmpty
                        ? Image.network(
                            phone.imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.broken_image, color: Colors.red, size: 40);
                            },
                          )
                        : const Icon(Icons.phone_android, size: 40, color: Colors.grey),
                  ),
                  title: Text(phone.namaModel, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Harga: ${phone.price}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
