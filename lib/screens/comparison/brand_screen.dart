import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application_1/utils/comparison_manager.dart';
import 'package:flutter_application_1/screens/comparison/compare_screen.dart';
import 'package:flutter_application_1/screens/crud/detail_screen.dart';
import 'package:flutter_application_1/screens/crud/create_phone_screen.dart';
import '../../utils/session.dart';

class BrandScreen extends StatefulWidget {
  final String brand;

  const BrandScreen({super.key, required this.brand});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  String errorMessage = "";

  // AUTO BASE URL (Web = localhost, Mobile = LAN)
  String get baseUrl {
    if (kIsWeb) {
      return "http://localhost/api_hp/";
    } else {
      return "http://192.168.1.32/api_hp/"; // IP LAN laptop kamu
    }
  }

  @override
  void initState() {
    super.initState();
    fetchPhones();
  }

  Future<void> fetchPhones() async {
    final url = Uri.parse("${baseUrl}get_phones.php?brand=${widget.brand}");

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
          errorMessage = "Gagal memuat data. Status: ${resp.statusCode}";
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = "Terjadi kesalahan koneksi: $e";
        loading = false;
      });
    }
  }

  // Toggle selection (via ComparisonManager)
  void _toggleSelectionAndRefresh(Map<String, dynamic> item) {
    ComparisonManager.toggleSelection(widget.brand, item['id'].toString());

    setState(() {});

    if (ComparisonManager.selectedPhones.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maksimal 3 HP untuk dibandingkan")),
      );
    }
  }

  // Go to Compare Screen
  void _goToCompareScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CompareScreen(phonesToCompare: ComparisonManager.selectedPhones),
      ),
    ).then((_) {
      ComparisonManager.clearSelection();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = ComparisonManager.selectedPhones.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.brand.toUpperCase()),
        actions: [
          if (selectedCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text("$selectedCount Terpilih"),
                backgroundColor: Colors.yellow[100],
                labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          if (selectedCount >= 2)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: _goToCompareScreen,
              tooltip: "Bandingkan",
            ),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final it = items[i];
                final isSelected = ComparisonManager.isSelected(
                  it['id'].toString(),
                );

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(
                    vertical: 6,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    leading: isSelected
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.radio_button_unchecked),

                    tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,

                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),

                    title: Text(it['nama_model'] ?? "Nama tidak ada"),
                    subtitle: Text(it['price'] ?? "Harga tidak ada"),
                    trailing: const Icon(Icons.phone_android),

                    onTap: () => _toggleSelectionAndRefresh(it),

                    onLongPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            brand: widget.brand,
                            id: it['id'].toString(),
                            refreshCallback: fetchPhones,
                          ),
                        ),
                      ).then((_) => fetchPhones());
                    },
                  ),
                );
              },
            ),

      floatingActionButton: (UserSession.role == "admin")
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePhoneScreen(brand: widget.brand),
                  ),
                ).then((_) => fetchPhones());
              },
              tooltip: "Tambah HP Baru",
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}