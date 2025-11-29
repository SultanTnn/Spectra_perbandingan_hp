import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/crud/edit_phone_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../utils/session.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatefulWidget {
  final String brand;
  final String id;
  final VoidCallback? refreshCallback;

  const DetailScreen({
    super.key,
    required this.brand,
    required this.id,
    this.refreshCallback,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Map<String, dynamic>? data;
  bool loading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchDetail();
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuka tautan pembelian: $url')),
      );
      print('Gagal membuka tautan: $url');
    }
  }

  Future<void> fetchDetail() async {
    final url = Uri.parse(
      'http://192.168.0.2/api_hp/get_detail.php?brand=${widget.brand}&id=${widget.id}',
    );

    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        if (!mounted) return;

        var fetchedData = j as Map<String, dynamic>;

        if (!fetchedData.containsKey('purchase_url')) {
          fetchedData['purchase_url'] = '';
        }

        setState(() {
          data = fetchedData;
          loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Gagal memuat data. Status: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Terjadi kesalahan koneksi: $e';
        loading = false;
      });
    }
  }

  Future<void> _deletePhone() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final url = Uri.parse('http://192.168.1.18/api_hp/delete_phone.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'brand': widget.brand, 'id': widget.id}),
      );

      if (!mounted) return;
      final data = json.decode(response.body);

      Navigator.pop(context);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
        widget.refreshCallback?.call();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${data['message']}')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error koneksi: $e')));
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus data ${data?['nama_model']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _deletePhone();
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _goToEditScreen() {
    if (data == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return EditPhoneScreen(brand: widget.brand, initialData: data!);
        },
      ),
    ).then((result) {
      if (result == true) {
        widget.refreshCallback?.call();
        fetchDetail();
      }
    });
  }

  Widget _buildDetailRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(value.toString(), style: const TextStyle(fontSize: 15)),
          const Divider(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;
    final secondaryColor = Colors.blue.shade300;

    final String purchaseUrlRaw = data?['purchase_url'] ?? '';
    final String cleanedPurchaseUrl = purchaseUrlRaw.trim();

    print('Purchase URL (Raw): $purchaseUrlRaw');
    print('Purchase URL (Cleaned): $cleanedPurchaseUrl');
    print(
      'Apakah Tombol Keranjang Muncul? ${data != null && cleanedPurchaseUrl.isNotEmpty}',
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          data?['nama_model'] ?? 'Detail',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (data != null && cleanedPurchaseUrl.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.red),
              onPressed: () => _launchUrl(cleanedPurchaseUrl),
              tooltip: 'Beli Sekarang',
            ),
          if (UserSession.role == 'admin') ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: data != null ? _goToEditScreen : null,
              tooltip: 'Edit Data',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: data != null ? () => _showDeleteDialog(context) : null,
              tooltip: 'Hapus Data',
            ),
          ],
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [secondaryColor, primaryColor],
          ),
        ),
        child: loading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : errorMessage.isNotEmpty
            ? Center(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.only(
                  top: 100,
                  left: 24,
                  right: 24,
                  bottom: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 15,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data?['nama_model'] ?? 'Nama tidak ada',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Brand: ${widget.brand}',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Divider(height: 30, thickness: 2),
                          _buildDetailRow('Harga', data?['price'] ?? '-'),
                          _buildDetailRow('Body', data?['body'] ?? '-'),
                          _buildDetailRow('Display', data?['display'] ?? '-'),
                          _buildDetailRow('Platform', data?['platform'] ?? '-'),
                          _buildDetailRow('Memory', data?['memory'] ?? '-'),
                          _buildDetailRow(
                            'Main Camera',
                            data?['main_camera'] ?? '-',
                          ),
                          _buildDetailRow(
                            'Selfie Camera',
                            data?['selfie_camera'] ?? '-',
                          ),
                          _buildDetailRow('Comms', data?['comms'] ?? '-'),
                          _buildDetailRow('Features', data?['features'] ?? '-'),
                          _buildDetailRow('Battery', data?['battery'] ?? '-'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
