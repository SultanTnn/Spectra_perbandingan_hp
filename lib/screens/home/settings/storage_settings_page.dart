import 'package:flutter/material.dart';
import 'dart:async';
import 'app_language.dart'; 

class StorageSettingsPage extends StatefulWidget {
  const StorageSettingsPage({super.key});

  @override
  State<StorageSettingsPage> createState() => _StorageSettingsPageState();
}

class _StorageSettingsPageState extends State<StorageSettingsPage> {
  bool _isClearing = false;
  String _cacheSize = "0 MB";
  bool _isCalculated = false;

  @override
  void initState() {
    super.initState();
    _calculateCacheSize();
  }

  // Simulasi menghitung ukuran cache saat halaman dibuka
  Future<void> _calculateCacheSize() async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _cacheSize = "24.5 MB"; // Angka simulasi
        _isCalculated = true;
      });
    }
  }

  Future<void> _handleClearCache() async {
    setState(() {
      _isClearing = true;
    });

    // Simulasi proses penghapusan
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isClearing = false;
        _cacheSize = "0 KB"; // Reset ukuran
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              Text(AppLanguage.get('cache_dibersihkan')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Deteksi Tema (Gelap/Terang)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final accentColor = Colors.orangeAccent;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          AppLanguage.get('penyimpanan_judul'),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- BAGIAN 1: STATUS CACHE UTAMA ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon Animasi atau Statis
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cleaning_services_rounded,
                      size: 50,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppLanguage.get('total_cache'),
                    style: TextStyle(
                      color: textColor.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _isCalculated
                      ? Text(
                          _cacheSize,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: accentColor,
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- BAGIAN 2: RINCIAN ---
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLanguage.get('rincian_cache').toUpperCase(),
                style: TextStyle(
                  color: textColor.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildDetailItem(
                    context,
                    icon: Icons.image,
                    color: Colors.blue,
                    title: AppLanguage.get('gambar_cache'),
                    size: _cacheSize == "0 KB" ? "0 KB" : "18.2 MB",
                    textColor: textColor,
                  ),
                  Divider(height: 1, indent: 60, color: Colors.grey.withOpacity(0.2)),
                  _buildDetailItem(
                    context,
                    icon: Icons.data_usage,
                    color: Colors.purple,
                    title: AppLanguage.get('data_sementara'),
                    size: _cacheSize == "0 KB" ? "0 KB" : "6.3 MB",
                    textColor: textColor,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // --- BAGIAN 3: TOMBOL AKSI ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_isClearing || _cacheSize == "0 KB")
                    ? null
                    : _handleClearCache,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  elevation: _isClearing ? 0 : 5,
                  shadowColor: accentColor.withOpacity(0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isClearing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        AppLanguage.get('bersihkan_konfirmasi'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String size,
    required Color textColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
          Text(
            size,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}