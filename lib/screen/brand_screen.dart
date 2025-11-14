// brand_screen.dart (Sudah dimodifikasi untuk Lintas Brand)

import 'package:flutter/material.dart';
import 'package:flutter_application_1/compare_screen.dart';
import 'package:flutter_application_1/comparison_manager.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart';
import 'session.dart';
import 'create_phone_screen.dart';

class BrandScreen extends StatefulWidget {
  final String brand;

  const BrandScreen({super.key, required this.brand});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  String errorMessage = '';

  // Variabel selectedPhones LOKAL DIHAPUS, diganti dengan ComparisonManager

  @override
  void initState() {
    super.initState();
    fetchPhones();
  }

  Future<void> fetchPhones() async {
    // ... (Logika fetchPhones tetap sama) ...
    final url = Uri.parse(
      'http://localhost/api_hp/get_phones.php?brand=${widget.brand}',
    );
    try {
      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (!mounted) return;
        setState(() {
          items = List<Map<String, dynamic>>.from(data);
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

  // --- LOGIKA UTAMA UNTUK MENGATUR SELEKSI HP (Memanggil Manager) ---
  void _toggleSelectionAndRefresh(Map<String, dynamic> item) {
    ComparisonManager.toggleSelection(widget.brand, item['id'].toString());
    setState(() {}); // Refresh UI setelah toggle

    // Opsional: Beri tahu user jika melebihi batas
    if (ComparisonManager.selectedPhones.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 3 HP untuk dibandingkan')),
      );
    }
  }

  // Navigasi ke halaman perbandingan
  void _goToCompareScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Kirim list yang disimpan di Manager
        builder: (_) =>
            CompareScreen(phonesToCompare: ComparisonManager.selectedPhones),
      ),
    ).then((_) {
      // Bersihkan pilihan dan refresh UI BrandScreen setelah kembali
      ComparisonManager.clearSelection();
      setState(() {});
    });
  }
  // --- AKHIR LOGIKA UTAMA ---

  @override
  Widget build(BuildContext context) {
    // Ambil data dari Manager saat ini untuk di-display
    final currentSelectedCount = ComparisonManager.selectedPhones.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brand.toUpperCase()),
        actions: [
          // Tampilkan Chip jumlah terpilih (dari Manager)
          if (currentSelectedCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Chip(
                label: Text('$currentSelectedCount Terpilih'),
                backgroundColor: Colors.yellow[100],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          // Tombol Bandingkan (hanya muncul jika >= 2 HP dipilih)
          if (currentSelectedCount >= 2)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: _goToCompareScreen,
              tooltip: 'Bandingkan',
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
              padding: const EdgeInsets.all(8.0),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final it = items[i];
                // Cek status seleksi dari Manager
                final isSelected = ComparisonManager.isSelected(
                  it['id'].toString(),
                );

                return Card(
                  elevation: 3.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 8.0,
                  ),
                  child: ListTile(
                    // Icon untuk visualisasi seleksi
                    leading: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.radio_button_unchecked),
                    // Warna latar belakang jika terpilih
                    tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,

                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 16.0,
                    ),
                    title: Text(it['nama_model'] ?? 'Nama tidak ada'),
                    subtitle: Text(it['price'] ?? 'Harga tidak ada'),
                    trailing: const Icon(Icons.phone_android),

                    // Aksi onTap: Selalu panggil fungsi toggle seleksi
                    onTap: () => _toggleSelectionAndRefresh(it),

                    // Aksi onLongPress: Selalu ke Detail
                    onLongPress: () =>
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              brand: widget.brand,
                              id: it['id'].toString(),
                              refreshCallback:
                                  fetchPhones, // Callback tetap penting untuk CRUD
                            ),
                          ),
                        ).then((_) {
                          // Refresh daftar HP setelah kembali dari Detail (jika ada update/delete)
                          fetchPhones();
                        }),
                  ),
                );
              },
            ),

      // FloatingActionButton tetap sama (untuk Admin)
      floatingActionButton: (UserSession.role == 'admin')
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreatePhoneScreen(brand: widget.brand),
                  ),
                ).then((_) {
                  fetchPhones();
                });
              },
              tooltip: 'Tambah HP Baru',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
