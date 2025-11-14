// detail_screen.dart (Modifikasi dengan Desain Baru)

import 'package:flutter/material.dart';
import 'package:flutter_application_1/edit_phone_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session.dart';


class DetailScreen extends StatefulWidget {
  final String brand;
  final String id;
  // Callback untuk me-refresh list di BrandScreen
  final VoidCallback? refreshCallback;

  const DetailScreen({
    super.key,
    required this.brand,
    required this.id,
    this.refreshCallback, // Tambahkan parameter baru
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

  Future<void> fetchDetail() async {
    final url = Uri.parse(
      'http://localhost/api_hp/get_detail.php?brand=${widget.brand}&id=${widget.id}',
    );
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        if (!mounted) return;
        setState(() {
          data = j as Map<String, dynamic>;
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
      final url = Uri.parse('http://localhost/api_hp/delete_phone.php');
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
        // Panggil callback refresh list di BrandScreen
        widget.refreshCallback?.call();
        Navigator.pop(context); // Kembali ke halaman sebelumnya
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

    // Navigasi ke EditPhoneScreen dengan mengirim data HP saat ini
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditPhoneScreen(brand: widget.brand, initialData: data!),
      ),
    ).then((result) {
      // Jika hasil dari EditScreen adalah 'true', berarti data berhasil diubah/dihapus
      if (result == true) {
        // Panggil callback refresh list di BrandScreen
        widget.refreshCallback?.call();
        // Lakukan fetch detail lagi untuk menampilkan data terbaru di halaman ini
        fetchDetail();
      }
    });
  }

  // Helper untuk membuat baris detail yang seragam
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
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 15,
            ),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue.shade700;
    final secondaryColor = Colors.blue.shade300;

    return Scaffold(
      extendBodyBehindAppBar: true, // Agar body bisa di belakang AppBar
      appBar: AppBar(
        title: Text(
          data?['nama_model'] ?? 'Detail',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent, // Transparan agar gradient terlihat
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),

        actions: [
          if (UserSession.role == 'admin') ...[
            // Tombol EDIT
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: data != null ? _goToEditScreen : null,
              tooltip: 'Edit Data',
            ),
            // Tombol Hapus
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed:
                  data != null ? () => _showDeleteDialog(context) : null,
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
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : errorMessage.isNotEmpty
                ? Center(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 100, left: 24, right: 24, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Card Utama untuk Detail
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
                              _buildDetailRow('Main Camera', data?['main_camera'] ?? '-'),
                              _buildDetailRow('Selfie Camera', data?['selfie_camera'] ?? '-'),
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