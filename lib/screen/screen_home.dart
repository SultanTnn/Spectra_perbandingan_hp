import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'brand_screen.dart'; // Pastikan nama file ini benar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Warna utama agar konsisten dengan halaman login/register — sesuaikan jika perlu
  static const Color primaryColor = Color(0xFF6C63FF);

  List<String> brands = [];
  bool loading = true;
  String errorMessage = ''; // Untuk menampilkan pesan error

  // filter/search
  final TextEditingController searchController = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
    fetchBrands();
    searchController.addListener(() {
      setState(() {
        query = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBrands() async {
    // INI YANG DIPERBARUI: (Diganti ke localhost untuk Windows/Web)
    final url = Uri.parse('http://localhost/api_hp/get_brands.php');

    try {
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (!mounted) return;

        setState(() {
          brands = List<String>.from(data.map((b) => b.toString()));
          loading = false;
          errorMessage = '';
        });
      } else {
        // Handle jika server error
        if (!mounted) return;
        setState(() {
          errorMessage = 'Gagal memuat data. Status: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      // Handle jika tidak ada koneksi
      if (!mounted) return;
      setState(() {
        // Pesan error ini sekarang akan lebih jelas di Windows/Web
        errorMessage = 'Terjadi kesalahan koneksi: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayed = query.isEmpty
        ? brands
        : brands.where((b) => b.toLowerCase().contains(query.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perbandingan HP'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, Color(0xFF4B3BE3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_off, size: 64, color: primaryColor.withOpacity(0.9)),
                        const SizedBox(height: 12),
                        Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                          onPressed: () {
                            setState(() {
                              loading = true;
                              errorMessage = '';
                            });
                            fetchBrands();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: fetchBrands,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    children: [
                      // Header / Intro card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.phone_android, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pilih Brand',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text('Lihat spesifikasi dan bandingkan HP dari brand favorit.'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Search field
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari brand (mis. Samsung, Xiaomi)...',
                          prefixIcon: Icon(Icons.search, color: primaryColor),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor.withOpacity(0.6)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // List of brands
                      if (displayed.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Column(
                            children: [
                              Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text('Brand tidak ditemukan'),
                            ],
                          ),
                        )
                      else
                        ...displayed.map(
                          (b) => Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              leading: CircleAvatar(
                                backgroundColor: primaryColor,
                                child: Text(
                                  b.isNotEmpty ? b[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                b,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: const Text('Tap untuk lihat produk dan bandingkan'),
                              trailing: Icon(Icons.keyboard_arrow_right, color: primaryColor),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BrandScreen(brand: b),
                                ),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }
}