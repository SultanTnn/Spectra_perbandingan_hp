import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:developer';

class CompareScreen extends StatefulWidget {
  // phonesToCompare berisi list of maps: [{'brand':'samsung', 'id':'1'}, {'brand':'xiaomi', 'id':'5'}]
  final List<Map<String, String>> phonesToCompare;

  const CompareScreen({super.key, required this.phonesToCompare});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen> {
  List<Map<String, dynamic>> comparisonData = [];
  bool loading = true;
  String errorMessage = "";

  // Bobot untuk perhitungan skor akhir (Total harus 100)
  final Map<String, double> weights = {
    'price': 15,
    'battery': 15,
    'memory': 15,
    'platform': 20,
    'display': 10,
    'main_camera': 10,
    'selfie_camera': 5,
    'comms': 5,
    'body': 3,
    'features': 2,
  };

  // Skor Kata Kunci untuk penilaian spek berbasis teks (Higher is Better)
  final Map<String, Map<String, double>> keywordScoresMap = {
    'platform': {
      'a17 bionic': 20.0,
      'snapdragon 8 gen 3': 20.0,
      'dimensity 9300': 18.0,
      'snapdragon 8 gen 2': 18.0,
      'a16 bionic': 15.0,
      'dimensity 9200': 15.0,
      'snapdragon 7': 10.0,
      'dimensity 8': 8.0,
    },
    'display': {
      'ltpo': 10.0,
      '144hz': 10.0,
      '120hz': 8.0,
      'oled': 5.0,
      'amoled': 5.0,
      'hdr10+': 5.0,
    },
    'main_camera': {
      'periscope': 15.0,
      'ois': 10.0,
      'telephoto': 8.0,
      '4k': 5.0,
    },
    'selfie_camera': {'autofocus': 5.0, 'ois': 3.0},
    'body': {'titanium': 8.0, 'glass': 5.0, 'metal': 5.0, 'leather': 3.0},
    'comms': {'5g': 10.0, 'wifi 6e': 5.0, 'nfc': 3.0},
    'features': {'ir blaster': 3.0, 'ultrawideband': 5.0, 'under display': 5.0},
  };

  // Base URL HARUS SAMA dengan yang ada di PHP, tanpa nama file!
  String get baseUrl {
    if (kIsWeb) {
      // Untuk web, gunakan localhost
      return "http://localhost/api_hp/";
    } else {
      // Untuk emulator/perangkat fisik, gunakan IP yang sesuai
      // GANTI IP INI JIKA IP ANDA BERBEDA!
      return "http://192.168.1.6/api_hp/";
    }
  }

  @override
  void initState() {
    super.initState();
    fetchComparisonData();
  }

  Future<void> fetchComparisonData() async {
    // Memanggil get_comparison.php
    final url = Uri.parse("${baseUrl}get_comparison.php");
    final List<Map<String, String>> payload = widget.phonesToCompare.map((p) {
      return {"brand": p["brand"]!, "id": p["id"]!};
    }).toList();

    try {
      final resp = await http
          .post(
            url,
            headers: {"Content-Type": "application/json"},
            body: json.encode({"phones": payload}),
          )
          .timeout(const Duration(seconds: 15));

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
            errorMessage = "Format data server tidak valid atau data kosong.";
            loading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = "Gagal memuat data. Status: ${resp.statusCode}.";
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage =
            "Terjadi kesalahan koneksi. Pastikan XAMPP berjalan dan IP sudah benar. Error: ${e.runtimeType}";
        loading = false;
      });
    }
  }

  // --- LOGIKA PERBANDINGAN NILAI UNGGUL (Dibiarkan Tidak Berubah) ---
  double _parseNumericValue(String? specString, String unit) {
    if (specString == null || specString.isEmpty) return 0.0;
    specString = specString.replaceAll(' ', '').toLowerCase();

    // 1. Parsing Satuan (mAh, GB)
    final unitRegex = RegExp(
      r'(\d+(\.\d+)?)' + unit.toLowerCase(),
      caseSensitive: false,
    );
    final unitMatch = unitRegex.firstMatch(specString);
    if (unitMatch != null && unitMatch.group(1) != null) {
      return double.tryParse(unitMatch.group(1)!.replaceAll(',', '.')) ?? 0.0;
    }

    // 2. Parsing Harga
    if (unit == r'\$') {
      String cleanedPrice = specString.replaceAll(RegExp(r'[^\d,\.]'), '');
      cleanedPrice = cleanedPrice.replaceAll('.', '');
      cleanedPrice = cleanedPrice.replaceAll(',', '.');
      return double.tryParse(cleanedPrice) ?? 0.0;
    }
    return 0.0;
  }

  double _scoreKeywords(String? specKey, String? specString) {
    if (specString == null || specString.isEmpty) return 0.0;
    String lowerSpec = specString.toLowerCase();
    double score = 0.0;

    final keywordScores = keywordScoresMap[specKey];
    if (keywordScores == null) return 0.0;

    keywordScores.forEach((keyword, value) {
      if (lowerSpec.contains(keyword.toLowerCase())) {
        score += value;
      }
    });
    return score;
  }

  double _getSuperiorValue(String specKey, {required bool higherIsBetter}) {
    if (comparisonData.isEmpty) return 0.0;

    List<double> values = [];
    String unit = '';

    if (specKey == 'battery') {
      unit = r'mAh';
    } else if (specKey == 'memory') {
      unit = r'GB';
    } else if (specKey == 'price') {
      unit = r'\$';
    } else {
      return comparisonData
          .map((p) => _scoreKeywords(specKey, p[specKey]?.toString()))
          .reduce((a, b) => a > b ? a : b);
    }

    for (var phone in comparisonData) {
      final value = _parseNumericValue(phone[specKey]?.toString(), unit);
      if (value > 0.0) {
        values.add(value);
      }
    }

    if (values.isEmpty) return 0.0;

    if (higherIsBetter) {
      return values.reduce((a, b) => a > b ? a : b);
    } else {
      return values.reduce((a, b) => a < b ? a : b);
    }
  }

  double _calculatePhoneScore(Map<String, dynamic> phone) {
    if (comparisonData.isEmpty) return 0.0;

    double totalScore = 0.0;

    Map<String, double> maxValues = {};
    Map<String, double> minValues = {};

    Map<String, List<double>> rawScores = {};

    for (var p in comparisonData) {
      weights.keys.forEach((key) {
        double rawScore;
        if (key == 'price' || key == 'battery' || key == 'memory') {
          String unit = (key == 'battery'
              ? r'mAh'
              : (key == 'memory' ? r'GB' : r'\$'));
          rawScore = _parseNumericValue(p[key]?.toString(), unit);
        } else {
          rawScore = _scoreKeywords(key, p[key]?.toString());
        }

        if (!rawScores.containsKey(key)) rawScores[key] = [];
        rawScores[key]!.add(rawScore);
      });
    }

    rawScores.forEach((key, values) {
      if (values.isNotEmpty) {
        maxValues[key] = values.reduce((a, b) => a > b ? a : b);
        minValues[key] = values.reduce((a, b) => a < b ? a : b);
      } else {
        maxValues[key] = 1.0;
        minValues[key] = 0.0;
      }
    });

    weights.forEach((key, weight) {
      double phoneValue;
      bool higherIsBetter = true;

      if (key == 'price' || key == 'battery' || key == 'memory') {
        String unit = (key == 'battery'
            ? r'mAh'
            : (key == 'memory' ? r'GB' : r'\$'));
        phoneValue = _parseNumericValue(phone[key]?.toString(), unit);
        if (key == 'price') higherIsBetter = false;
      } else {
        phoneValue = _scoreKeywords(key, phone[key]?.toString());
      }

      double maxValue = maxValues[key] ?? 1.0;
      double minValue = minValues[key] ?? 0.0;

      double normalizedScore = 0.0;
      if (maxValue > minValue) {
        if (higherIsBetter) {
          normalizedScore = (phoneValue - minValue) / (maxValue - minValue);
        } else {
          normalizedScore = (maxValue - phoneValue) / (maxValue - minValue);
        }
      } else if (phoneValue > 0) {
        normalizedScore = 1.0;
      }

      totalScore += normalizedScore * weight;
    });

    return totalScore.clamp(0.0, 100.0);
  }
  // --- AKHIR LOGIKA PERBANDINGAN NILAI UNGGUL ---

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

  // Widget konten sel perbandingan
  Widget _buildComparisonCell({
    required BuildContext context,
    required String value,
    required bool isSuperior,
    required Color color,
    required String comparisonText,
  }) {
    final summaryValue = value.split('\n').take(4).join('\n');
    final displayValue = comparisonText.isNotEmpty
        ? comparisonText
        : summaryValue;

    final isDetailText = comparisonText.isEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      decoration: BoxDecoration(
        color: isSuperior ? color.withOpacity(0.1) : null,
        borderRadius: isSuperior ? BorderRadius.circular(8) : null,
        border: isSuperior
            ? Border.all(color: color.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Row(
        mainAxisAlignment: isDetailText
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSuperior)
            Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: Icon(Icons.check_circle, size: 14, color: color),
            ),
          Expanded(
            child: Text(
              displayValue,
              textAlign: isDetailText ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSuperior ? FontWeight.bold : FontWeight.normal,
                color: isSuperior
                    ? color
                    : Theme.of(context).textTheme.bodyMedium!.color,
              ),
              maxLines: isDetailText ? 4 : 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk membangun baris perbandingan
  Widget _buildComparisonRow(String specKey) {
    bool isNumerical =
        specKey == 'battery' || specKey == 'memory' || specKey == 'price';
    bool higherIsBetter = specKey != 'price';

    double superiorValue = 0.0;

    superiorValue = _getSuperiorValue(specKey, higherIsBetter: higherIsBetter);

    Color specColor;
    switch (specKey) {
      case 'price':
        specColor = Colors.green.shade700;
        break;
      case 'body':
        specColor = Colors.brown.shade700;
        break;
      case 'display':
        specColor = Colors.blue.shade700;
        break;
      case 'platform':
        specColor = Colors.red.shade700;
        break;
      case 'memory':
        specColor = Colors.deepOrange.shade700;
        break;
      case 'main_camera':
        specColor = Colors.pink.shade700;
        break;
      case 'selfie_camera':
        specColor = Colors.pink.shade400;
        break;
      case 'comms':
        specColor = Colors.cyan.shade700;
        break;
      case 'features':
        specColor = Colors.indigo.shade700;
        break;
      case 'battery':
        specColor = Colors.purple.shade700;
        break;
      default:
        specColor = Colors.grey.shade700;
        break;
    }

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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: specColor,
                  ),
                ),
              ),

              // Kolom data untuk setiap HP
              ...comparisonData.map((phone) {
                final String specValueString =
                    phone[specKey]?.toString() ?? "-";

                bool isSuperior = false;
                String comparisonValueText = '';

                if (superiorValue > 0.0) {
                  double currentValue;

                  if (isNumerical) {
                    String unit = (specKey == 'battery'
                        ? r'mAh'
                        : (specKey == 'memory' ? r'GB' : r'\$'));
                    currentValue = _parseNumericValue(specValueString, unit);

                    if (currentValue > 0.0) {
                      isSuperior = higherIsBetter
                          ? (currentValue >= superiorValue)
                          : (currentValue <= superiorValue);

                      // Format teks nilai perbandingan
                      if (specKey == 'price') {
                        comparisonValueText = specValueString;
                      } else if (specKey == 'battery') {
                        comparisonValueText =
                            '${currentValue.toStringAsFixed(0)} mAh';
                      } else if (specKey == 'memory') {
                        final allRam = RegExp(r'(\d+)\s*GB\s*RAM')
                            .allMatches(specValueString)
                            .map(
                              (m) => double.tryParse(m.group(1) ?? '0') ?? 0.0,
                            )
                            .toList();
                        final ramValue = allRam.isNotEmpty
                            ? allRam.reduce((a, b) => a > b ? a : b)
                            : 0.0;
                        if (ramValue > 0)
                          comparisonValueText =
                              '${ramValue.toStringAsFixed(0)} GB RAM';
                        if (ramValue == 0) {
                          final allGB = RegExp(r'(\d+)\s*GB')
                              .allMatches(specValueString)
                              .map(
                                (m) =>
                                    double.tryParse(m.group(1) ?? '0') ?? 0.0,
                              )
                              .toList();
                          final storageValue = allGB.isNotEmpty
                              ? allGB.reduce((a, b) => a > b ? a : b)
                              : 0.0;
                          if (storageValue > 0)
                            comparisonValueText =
                                '${storageValue.toStringAsFixed(0)} GB Storage';
                        }
                      }
                    }
                  } else {
                    currentValue = _scoreKeywords(specKey, specValueString);
                    isSuperior =
                        currentValue >= superiorValue && currentValue > 0.0;
                  }
                }

                return Expanded(
                  child: _buildComparisonCell(
                    context: context,
                    value: specValueString,
                    isSuperior: isSuperior,
                    color: specColor,
                    comparisonText: comparisonValueText,
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

  // Widget baru untuk menampilkan skor akhir
  Widget _buildFinalScoreRow() {
    List<double> finalScores = comparisonData
        .map(_calculatePhoneScore)
        .toList();
    double maxScore = finalScores.isNotEmpty
        ? finalScores.reduce((a, b) => a > b ? a : b)
        : 0.0;

    return Column(
      children: [
        const Divider(height: 1, thickness: 3, color: Colors.black54),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label Kiri
              Container(
                width: 120,
                padding: const EdgeInsets.only(right: 8),
                child: const Text(
                  "SKOR AKHIR",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: Colors.red,
                  ),
                ),
              ),

              // Kolom Skor
              ...finalScores.asMap().entries.map((entry) {
                final double score = entry.value;
                final bool isSuperior = maxScore > 0.0 && score >= maxScore;

                Color scoreColor = score >= 80
                    ? Colors.green.shade700
                    : (score >= 60
                          ? Colors.orange.shade700
                          : Colors.red.shade700);

                return Expanded(
                  child: _buildComparisonCell(
                    context: context,
                    value: score.toStringAsFixed(1),
                    isSuperior: isSuperior,
                    color: scoreColor,
                    comparisonText:
                        "${score.toStringAsFixed(1)} / 100", // Tampilan nilai skor
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  // Widget baru untuk bagian header (Gambar dan Nama HP) - Tempat gambar ditampilkan
  Widget _buildHeaderRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 120), // Placeholder untuk label kiri
          ...comparisonData.map((phone) {
            final String imageUrl = phone["image_url"]?.toString() ?? "";
            final String modelName = phone["nama_model"] ?? "N/A";

            return Expanded(
              child: Column(
                children: [
                  // --- AREA GAMBAR ---
                  Container(
                    height: 100, // Ukuran gambar
                    margin: const EdgeInsets.only(bottom: 8),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            // MENGGUNAKAN URL LENGKAP DARI PHP
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              log(
                                "Error loading image: $error, URL: $imageUrl",
                              );
                              return const Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              );
                            },
                          )
                        : const Icon(
                            Icons.phone_android,
                            size: 50,
                            color: Colors.grey,
                          ),
                  ),
                  // --- NAMA MODEL ---
                  Text(
                    modelName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perbandingan HP 📊")),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "❌ GAGAL MEMUAT DATA:\n$errorMessage",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header (GAMBAR DAN NAMA HP)
                  _buildHeaderRow(),

                  // Body table (Semua spek)
                  ...specs
                      .where((s) => s != "nama_model")
                      .map(_buildComparisonRow),

                  // BARIS SKOR AKHIR
                  _buildFinalScoreRow(),
                ],
              ),
            ),
    );
  }
}

// Extension ini hanya untuk compatibility, aslinya Anda harus punya import dart:ui
extension on Color {
  Color get shade900 {
    // Implementasi dummy shade 900
    return this;
  }
}
