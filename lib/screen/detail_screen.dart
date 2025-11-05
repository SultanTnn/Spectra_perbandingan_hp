// detail_screen.dart (Modifikasi)

import 'package:flutter/material.dart';
import 'package:flutter_application_1/edit_phone_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session.dart';
import 'edit_phone_screen.dart'; // <-- BARU: Import EditScreen

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
    // Fungsi fetchDetail tetap sama
    final url = Uri.parse(
      'http://localhost/api_hp/get_detail.php?brand=${widget.brand}&id=${widget.id}',
    );
    try {
      // ... (kode fetchDetail)
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
    // ... (kode _deletePhone tetap sama)
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
    // ... (kode _showDeleteDialog tetap sama)
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

  // --- FUNGSI BARU UNTUK EDIT DATA ---
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
  // --- AKHIR FUNGSI BARU UNTUK EDIT DATA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(data?['nama_model'] ?? 'Detail'),

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
              onPressed: data != null ? () => _showDeleteDialog(context) : null,
              tooltip: 'Hapus Data',
            ),
          ],
        ],
      ),
      body: loading
          // ... (Widget body detail tetap sama)
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(errorMessage),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data?['nama_model'] ?? 'Nama tidak ada',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Price: ${data?['price'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Body:\n${data?['body'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Display:\n${data?['display'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Platform:\n${data?['platform'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Memory:\n${data?['memory'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Main Camera:\n${data?['main_camera'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Selfie Camera:\n${data?['selfie_camera'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Comms:\n${data?['comms'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Features:\n${data?['features'] ?? '-'}'),
                  const SizedBox(height: 12),
                  Text('Battery:\n${data?['battery'] ?? '-'}'),
                ],
              ),
            ),
    );
  }
}
