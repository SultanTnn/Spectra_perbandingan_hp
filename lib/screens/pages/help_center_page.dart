import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Pusat Bantuan",
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF553C9A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              color: const Color(0xFF553C9A),
              width: double.infinity,
              child: Column(
                children: [
                  const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 60,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Apa yang bisa kami bantu?",
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Pertanyaan Umum (FAQ)",
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildExpansionTile(
                    "Bagaimana cara membandingkan HP?",
                    "Pilih brand di halaman utama, ketuk HP untuk memilih (max 3), lalu tekan tombol 'Bandingkan' yang muncul di bawah.",
                  ),
                  _buildExpansionTile(
                    "Apakah data harga akurat?",
                    "Harga yang ditampilkan adalah estimasi rata-rata pasar dan dapat berubah sewaktu-waktu.",
                  ),
                  _buildExpansionTile(
                    "Bagaimana cara mengganti foto profil?",
                    "Masuk ke menu Drawer > Profil Saya > Klik ikon edit pada foto.",
                  ),

                  const SizedBox(height: 30),
                  Text(
                    "Hubungi Kami",
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.email, color: Color(0xFF553C9A)),
                    title: const Text("Email Support"),
                    subtitle: const Text("support@spectra.com"),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat, color: Color(0xFF553C9A)),
                    title: const Text("WhatsApp"),
                    subtitle: const Text("+62 812-3456-7890"),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(String title, String content) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        title: Text(
          title,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              content,
              style: GoogleFonts.nunito(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
