import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CompareScreen extends StatefulWidget {
  // Menerima daftar ID & brand HP yang ingin dibandingkan
  final List<Map<String, String>> phonesToCompare;

  const CompareScreen({super.key, required this.phonesToCompare});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<Map<String, dynamic>> comparisonData = [];
  bool loading = true;
  String errorMessage = "";

  // Base URL otomatis
  String get baseUrl {
    if (kIsWeb) {
      return "http://localhost/api_hp/";
    } else {
      return "http://192.168.43.60/api_hp/";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComparisonData();
  }

  Future<void> fetchComparisonData() async {
    final url = Uri.parse("${baseUrl}get_comparison.php");

    // payload => [{brand: Samsung, id: 35}, ...]
    final List<Map<String, String>> payload = widget.phonesToCompare.map((p) {
      return {"brand": p["brand"]!, "id": p["id"]!};
    }).toList();

    try {
      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"phones": payload}),
      );

      if (resp.statusCode == 200) {
        final jsonResp = json.decode(resp.body);

        if (!mounted) return;

        if (jsonResp is List) {
          setState(() {
            comparisonData = List<Map<String, dynamic>>.from(jsonResp);
            loading = false;
          });
        } else {
          setState(() {
            errorMessage = "Format data server tidak valid";
            loading = false;
          });
        }
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

  // List spesifikasi yang dibandingkan
  final List<String> specs = [
    "nama_model",
    "price",
    "body",
    "display",
    "platform",
    "memory",
    "main_camera",
    "selfie_camera",
    "comms",
    "features",
    "battery",
  ];

  String getLabel(String key) {
    switch (key) {
      case "nama_model":
        return "Model";
      case "price":
        return "Harga";
      case "main_camera":
        return "Kamera Utama";
      case "selfie_camera":
        return "Kamera Selfie";
      case "comms":
        return "Konektivitas";
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }

  Widget _buildComparisonRow(String specKey) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label kiri
              Container(
                width: 120,
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  getLabel(specKey),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),

              // Kolom data untuk setiap HP
              ...comparisonData.map((phone) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      phone[specKey]?.toString() ?? "-",
                      textAlign: TextAlign.left,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perbandingan HP 📊")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header nama HP
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 120),
                        ...comparisonData.map((phone) {
                          return Expanded(
                            child: Text(
                              phone["nama_model"] ?? "N/A",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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

                  // Body table
                  ...specs
                      .where((s) => s != "nama_model")
                      .map(_buildComparisonRow),
                ],
              ),
            ),
    );
  }
}
