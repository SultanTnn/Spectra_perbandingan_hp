import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  // Fungsi Helper untuk membuka link GitHub
  Future<void> _launchUrl(BuildContext context, String urlString) async {
    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link GitHub belum tersedia')),
      );
      return;
    }
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal membuka link: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data Tim (4 Anggota)
    final List<Map<String, String>> teamMembers = [
      {
        "name": "tia fitrianimgsih",
        "nim": "24111814082",
        "class": "Informatika 2023 C",
        "github": "https://github.com/TiaaaFitria",
      },
      {
        "name": "Muhammad Dava Firmansyah ",
        "nim": "24111814030",
        "class": "Informatika 2023 C",
        "github": "https://github.com/mdavafirmansyah",
      },
      {
        "name": "Sultan Raffi Suryanegara",
        "nim": "24111814108",
        "class": "Informatika 2024 C",
        "github": "https://github.com/SultanTnn",
      },
      {
        "name": "Naufal yudantara saputra ",
        "nim": " 24111814023",
        "class": "Informatika 2023 C",
        "github": "https://github.com/naufalyudantara07",
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Tentang Spectra",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        // Background Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF2C3E50), // Dark Blue Grey
              Color(0xFF4CA1AF), // Soft Teal
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // ============================================================
                // BAGIAN 1: DESKRIPSI APLIKASI (HEADER)
                // ============================================================
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.smartphone_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "SPECTRA",
                        style: GoogleFonts.fredoka(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "Spectra adalah solusi cerdas untuk membandingkan spesifikasi handphone terkini. "
                        "Kami membantu Anda menemukan gadget impian dengan data yang akurat dan transparan.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // --- JUDUL SECTION ---
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white30)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "TIM PENGEMBANG",
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white30)),
                  ],
                ),
                const SizedBox(height: 15),

                // ============================================================
                // BAGIAN 2: LIST ANGGOTA (TANPA ROLE)
                // ============================================================
                Column(
                  children: teamMembers.map((member) {
                    return _buildCompactMemberCard(context, member);
                  }).toList(),
                ),

                const SizedBox(height: 30),

                Text(
                  "© 2025 Kelompok 1 - S1 Informatika",
                  style: GoogleFonts.nunito(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget Kartu Anggota Tim (Desain Compact Horizontal Tanpa Role)
  Widget _buildCompactMemberCard(
    BuildContext context,
    Map<String, String> member,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), // Jarak antar kartu
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Sudut membulat modern
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Avatar (Kiri)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Colors.blue.shade700, size: 28),
          ),

          const SizedBox(width: 16),

          // 2. Info Lengkap (Tengah)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member['name']!,
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${member['nim']} • ${member['class']}",
                  style: GoogleFonts.nunito(
                    fontSize: 11, // Ukuran font sedikit disesuaikan
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 3. Tombol GitHub (Kanan)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _launchUrl(context, member['github']!),
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF24292e), // GitHub Black
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.code, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
