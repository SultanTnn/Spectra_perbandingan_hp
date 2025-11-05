// compare_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CompareScreen extends StatefulWidget {
  // Menerima daftar ID HP yang ingin dibandingkan
  final List<Map<String, String>> phonesToCompare;

  const CompareScreen({super.key, required this.phonesToCompare});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<Map<String, dynamic>> comparisonData = [];
  bool loading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchComparisonData();
  }

  Future<void> fetchComparisonData() async {
    final url = Uri.parse('http://localhost/api_hp/get_comparison.php');

    // Ubah list data HP menjadi format yang mudah dikirim ke API
    final List<Map<String, String>> payload = widget.phonesToCompare.map((
      phone,
    ) {
      return {'brand': phone['brand']!, 'id': phone['id']!};
    }).toList();

    try {
      final resp = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'phones': payload}),
      );

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (!mounted) return;
        setState(() {
          comparisonData = List<Map<String, dynamic>>.from(data);
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

  // List kunci data yang akan ditampilkan dalam tabel perbandingan
  final List<String> specs = [
    'nama_model',
    'price',
    'body',
    'display',
    'platform',
    'memory',
    'main_camera',
    'selfie_camera',
    'comms',
    'features',
    'battery',
  ];

  // Mapping dari key ke label yang lebih rapi
  String getLabel(String key) {
    switch (key) {
      case 'nama_model':
        return 'Model';
      case 'price':
        return 'Harga';
      case 'main_camera':
        return 'Kamera Utama';
      case 'selfie_camera':
        return 'Kamera Selfie';
      case 'comms':
        return 'Konektivitas';
      default:
        return key[0].toUpperCase() +
            key.substring(1); // Kapitalisasi huruf pertama
    }
  }

  // Widget untuk menampilkan baris spesifikasi
  Widget _buildComparisonRow(String specKey) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Kategori/Label
              Container(
                width: 120, // Lebar fixed untuk label
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  getLabel(specKey),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              // Kolom Data HP 1, HP 2, dst.
              ...comparisonData.map((data) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(data[specKey] ?? '-'),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const Divider(height: 1), // Garis pemisah antar baris spesifikasi
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perbandingan HP 📊')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Header Row (Nama Model)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 120), // Padding untuk kolom Label
                        ...comparisonData.map((data) {
                          return Expanded(
                            child: Text(
                              data['nama_model'] ?? 'N/A',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),

                  // Body Tabel Perbandingan
                  ...specs
                      .where((spec) => spec != 'nama_model')
                      .map((spec) => _buildComparisonRow(spec)),
                ],
              ),
            ),
    );
  }
}
