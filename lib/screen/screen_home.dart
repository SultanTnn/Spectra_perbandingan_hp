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
  List<String> brands = [];
  bool loading = true;
  String errorMessage = ''; // Untuk menampilkan pesan error

  @override
  void initState() {
    super.initState();
    fetchBrands();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Perbandingan HP')),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(errorMessage),
                  ),
                )
              : ListView(
                  children: brands
                      .map(
                        (b) => ListTile(
                          title: Text(b.toUpperCase()),
                          trailing: const Icon(Icons.keyboard_arrow_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BrandScreen(brand: b),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
    );
  }
}