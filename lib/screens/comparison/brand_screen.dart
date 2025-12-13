import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import '../../utils/comparison_manager.dart';
import '../../screens/comparison/compare_screen.dart';
import '../../screens/crud/detail_screen.dart';
import '../../screens/crud/create_phone_screen.dart';
import '../../screens/crud/edit_phone_screen.dart';
import '../../utils/session.dart';

class BrandScreen extends StatefulWidget {
  final String brand;
  const BrandScreen({
    super.key,
    required this.brand,
    required List phonesToCompare,
  });

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  String errorMessage = "";

  String get baseUrl {
    if (kIsWeb) {
      return "http://localhost/api_hp/";
    } else {
      return "http://192.168.1.7/api_hp/";
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

  void _toggleSelectionAndRefresh(Map<String, dynamic> item) {
    ComparisonManager.toggleSelection(widget.brand, item['id'].toString());
    setState(() {});
    if (ComparisonManager.selectedPhones.length > 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maksimal 3 HP untuk dibandingkan")),
      );
    }
  }

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

  Future<void> _deletePhone(String id, String namaModel) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final url = Uri.parse("${baseUrl}delete_phone.php");
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'brand': widget.brand, 'id': id}),
      );

      if (!mounted) return;
      Navigator.pop(context);

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil dihapus')));
        fetchPhones();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${data['message']}')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error koneksi: $e')));
      }
    }
  }

  void _showDeleteDialog(String id, String namaModel) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus $namaModel?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _deletePhone(id, namaModel);
              },
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _goToEditScreen(Map<String, dynamic> item) {
    // Fetch detail lengkap terlebih dahulu
    _fetchDetailForEdit(item['id'].toString());
  }

  Future<void> _fetchDetailForEdit(String id) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final url = Uri.parse(
        "${baseUrl}get_detail.php?brand=${widget.brand}&id=$id",
      );
      final resp = await http.get(url);

      if (!mounted) return;
      Navigator.pop(context);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                EditPhoneScreen(brand: widget.brand, initialData: data),
          ),
        ).then((result) {
          if (result == true) {
            fetchPhones();
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data detail')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = ComparisonManager.selectedPhones.length;
    final primaryColor = const Color(0xFF553C9A);
    final secondaryColor = const Color(0xFF6C63FF);
    final accentColor = const Color(0xFF0175C2);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.brand.toUpperCase(),
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor.withOpacity(0.9),
        elevation: 0,
        actions: [
          if (selectedCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "$selectedCount Terpilih",
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[900],
                      fontSize: 12,
                    ),
                  ),
                ),
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryColor.withOpacity(0.08), Colors.grey[50]!],
          ),
        ),
        child: loading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : errorMessage.isNotEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(
                  top: 100,
                  left: 12,
                  right: 12,
                  bottom: 24,
                ),
                itemCount: items.length,
                itemBuilder: (_, i) {
                  final it = items[i];
                  final isSelected = ComparisonManager.isSelected(
                    it['id'].toString(),
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? secondaryColor.withOpacity(0.3)
                                : Colors.black.withOpacity(0.08),
                            blurRadius: isSelected ? 12 : 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withOpacity(0.95),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => _toggleSelectionAndRefresh(it),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            child: Row(
                              children: [
                                // Checkbox
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? secondaryColor
                                        : Colors.grey[100],
                                    border: Border.all(
                                      color: isSelected
                                          ? secondaryColor
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          color: Colors.white,
                                        )
                                      : Icon(
                                          Icons.phone_iphone_rounded,
                                          color: Colors.grey[400],
                                          size: 24,
                                        ),
                                ),
                                const SizedBox(width: 16),

                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        it['nama_model'] ?? "Nama tidak ada",
                                        style: GoogleFonts.nunito(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[900],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        it['price'] ?? "Harga tidak ada",
                                        style: GoogleFonts.nunito(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Action Buttons untuk Admin
                                if (UserSession.role == 'admin')
                                  SizedBox(
                                    width: 100,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.blue[600],
                                              size: 18,
                                            ),
                                            onPressed: () =>
                                                _goToEditScreen(it),
                                            tooltip: 'Edit',
                                            constraints: const BoxConstraints(
                                              minHeight: 40,
                                              minWidth: 40,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red[50],
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red[600],
                                              size: 18,
                                            ),
                                            onPressed: () => _showDeleteDialog(
                                              it['id'].toString(),
                                              it['nama_model'] ?? 'Data HP',
                                            ),
                                            tooltip: 'Hapus',
                                            constraints: const BoxConstraints(
                                              minHeight: 40,
                                              minWidth: 40,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: (UserSession.role == "admin")
          ? Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [secondaryColor, accentColor]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: secondaryColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreatePhoneScreen(brand: widget.brand),
                    ),
                  ).then((_) => fetchPhones());
                },
                tooltip: "Tambah HP Baru",
                child: const Icon(Icons.add, color: Colors.white),
              ),
            )
          : null,
    );
  }
}
