import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TeamDevPage extends StatelessWidget {
  const TeamDevPage({super.key});

  // Fungsi diperbarui untuk menerima LINK LENGKAP
  Future<void> _launchInstagram(BuildContext context, String urlString) async {
    // Jika link kosong, jangan lakukan apa-apa
    if (urlString.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Link Instagram belum tersedia')),
      );
      return;
    }

    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        // Fallback jika mode external gagal
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuka link: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Data Lengkap Tim
    final List<Map<String, dynamic>> members = [
      {
        "name": "Tia",
        "nim": "24111814082",
        "class": "S1 Informatika 2023 C",
        // --- TARUH LINK DI SINI ---
        "instagram_link":
            "https://www.instagram.com/tia_ftrn?igsh=eWxrbTQ5eXpseDRs&utm_source=qr",
        "color": Colors.pinkAccent,
      },
      {
        "name": "Muhammad Dava Firmansyah",
        "nim": "24111814030",
        "class": "S1 Informatika 2023 C",
        // Masukkan link anggota lain di sini
        "instagram_link":
            "https://www.instagram.com/amad_firmn?igsh=MWtqa3htdWFjNW9kcA==",
        "color": Colors.blueAccent,
      },
      {
        "name": "Sultan Raffi Suryanegara",
        "nim": "24111814108",
        "class": "S1 Informatika 2024 C",
        "instagram_link":
            "https://www.instagram.com/sultanrsn/", // Kosongkan jika tidak ada
        "color": Colors.orangeAccent,
      },
      {
        "name": "Naufal yudantara saputra",
        "nim": "24111814023",
        "class": "S1 Informatika 2023 C",
        "instagram_link":
            "https://www.instagram.com/nuflydtr7?igsh=OHR6cG9hNTYzMWNy&utm_source=qr",
        "color": Colors.tealAccent,
      },
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Tim Pengembang",
          style: GoogleFonts.fredoka(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2E0249), // Ungu Gelap
              Color(0xFF570A57),
              Color(0xFFA91079), // Pink/Ungu terang
            ],
          ),
        ),
        child: Stack(
          children: [
            // --- Dekorasi Background ---
            Positioned(
              top: -50,
              left: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purpleAccent.withValues(alpha: 0.3),
                      blurRadius: 50,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              right: -30,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.2),
                      blurRadius: 80,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),

            // --- Konten Utama ---
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Text(
                    "Kelompok 1 - S1 Informatika",
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        return _buildComplexCard(context, members[index]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplexCard(BuildContext context, Map<String, dynamic> member) {
    // Ambil data
    final Color accentColor = member['color'] as Color;
    final String name = member['name'].toString();
    final String role = member['role'].toString();
    final String nim = member['nim'].toString();
    final String instagramUrl = member['instagram_link'].toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      height: 170,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Layer Kartu Belakang (Background Glass)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 130,
                  right: 16,
                  top: 16,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Bagian Atas: Nama & Role
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                role,
                                style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              nim,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Bagian Bawah: Tombol Instagram (Dipojokkan ke kanan)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _launchInstagram(context, instagramUrl),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF833AB4),
                                  Color(0xFFFD1D1D),
                                  Color(0xFFF77737),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.pink.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Follow",
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Layer Foto Profil
          Positioned(
            left: 20,
            bottom: 30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                gradient: LinearGradient(
                  colors: [accentColor, accentColor.withValues(alpha: 0.5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 55,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
