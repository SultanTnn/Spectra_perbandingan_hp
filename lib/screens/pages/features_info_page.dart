import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeaturesInfoPage extends StatelessWidget {
  const FeaturesInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Fitur Unggulan",
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF553C9A),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFeatureRow(
            Icons.filter_list_alt,
            "Filter Canggih",
            "Cari handphone berdasarkan kriteria spesifik seperti rentang harga, kapasitas baterai, jenis layar, hingga resolusi kamera. Temukan HP impian dalam hitungan detik.",
            Colors.purple,
          ),
          const Divider(height: 40),
          _buildFeatureRow(
            Icons.dark_mode,
            "Mode Gelap (Dark Mode)",
            "Nyaman di mata saat browsing di malam hari. Mode gelap juga membantu menghemat daya baterai pada layar OLED/AMOLED. Tekan ikon matahari/bulan di pojok kanan atas untuk mencoba.",
            Colors.orange,
          ),
          const Divider(height: 40),
          _buildFeatureRow(
            Icons.compare_arrows,
            "Komparasi Side-by-Side",
            "Bandingkan hingga 3 handphone sekaligus. Kami menyoroti spesifikasi unggul dengan warna hijau agar Anda tahu mana pemenangnya secara instan.",
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(
    IconData icon,
    String title,
    String desc,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.fredoka(
                fontSize: 20,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          desc,
          style: GoogleFonts.nunito(
            fontSize: 15,
            height: 1.6,
            color: Colors.grey[700],
          ),
          textAlign: TextAlign.justify,
        ),
      ],
    );
  }
}
