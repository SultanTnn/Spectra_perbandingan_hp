// FILE: lib/screens/comparison/brand_screen.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/smartphone.dart';
import '../../utils/comparison_manager.dart';
import '../../screens/comparison/compare_screen.dart';
import '../../screens/crud/detail_screen.dart';
import '../../screens/crud/create_phone_screen.dart';
import '../../utils/session.dart';
import '../../service/api_service.dart';

class BrandScreen extends StatefulWidget {
  final String brand;
  const BrandScreen({super.key, required this.brand}); // Hapus phonesToCompare

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  String get baseUrl => ApiService.baseUrl;

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
        setState(() {
          items = List<Map<String, dynamic>>.from(json.decode(resp.body));
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      setState(() => loading = false);
    }
  }

  void _toggleSelectionAndRefresh(Map<String, dynamic> item) {
    ComparisonManager.toggleSelection(widget.brand, item['id'].toString());
    setState(() {});
  }

  void _goToCompareScreen() {
    // Konversi Map ke Model Smartphone
    final selectedIds = ComparisonManager.selectedPhones
        .map((e) => e['id'])
        .toSet();
    List<Smartphone> phonesToSend = items
        .where((item) => selectedIds.contains(item['id'].toString()))
        .map((item) => Smartphone.fromJson(item, widget.brand))
        .toList();

    if (phonesToSend.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pilih minimal 2 HP")));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CompareScreen(phones: phonesToSend)),
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
          if (selectedCount >= 2)
            IconButton(
              icon: const Icon(Icons.compare_arrows),
              onPressed: _goToCompareScreen,
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final it = items[i];
                final isSelected = ComparisonManager.isSelected(
                  it['id'].toString(),
                );
                return ListTile(
                  leading: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.circle_outlined),
                  title: Text(it['nama_model'] ?? ""),
                  onTap: () => _toggleSelectionAndRefresh(it),
                );
              },
            ),
    );
  }
}
