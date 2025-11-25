import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart'; // Pastikan sudah ada di pubspec.yaml

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  // Warna background footer (Gelap/Ungu Tua ala referensi)
  static const Color footerBackground = Color(
    0xFF1A103C,
  ); // Sesuaikan jika ingin lebih hitam/ungu
  static const Color textColor = Colors.white;
  static const Color textGrey = Colors.white60;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: footerBackground, // Latar belakang gelap penuh
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BAGIAN ATAS: LOGO & KOLOM LINK ---
          LayoutBuilder(
            builder: (context, constraints) {
              // Jika layar lebar (Desktop/Tablet), pakai Row. Jika HP, pakai Column.
              if (constraints.maxWidth > 600) {
                return _buildDesktopLayout();
              } else {
                return _buildMobileLayout();
              }
            },
          ),

          const SizedBox(height: 40),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 20),

          // --- BAGIAN BAWAH: COPYRIGHT & SOCIAL ---
          Column(
            // Ubah ke Column agar aman di HP
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bahasa (Dropdown simulasi)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.language, color: Colors.white, size: 16),
                        SizedBox(width: 8),
                        Text(
                          "Bahasa Indonesia",
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 16,
                        ),
                      ],
                    ),
                  ),

                  // Social Media Icons
                  Row(
                    children: [
                      _buildSocialIcon(Icons.send), // Icon Telegram/Send
                      const SizedBox(width: 12),
                      _buildSocialIcon(Icons.camera_alt), // Icon IG
                      const SizedBox(width: 12),
                      _buildSocialIcon(Icons.business), // Icon LinkedIn
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Teks Copyright
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    child: Text(
                      "Syarat & Ketentuan   Kebijakan Privasi",
                      style: TextStyle(color: textGrey, fontSize: 11),
                    ),
                  ),
                  Text(
                    "Copyright © 2025 Spectra.",
                    style: TextStyle(color: textGrey, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- LAYOUT UNTUK HP (Mobile) ---
  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo & Tagline
        Row(
          children: [
            const Icon(Icons.smartphone_rounded, color: Colors.white, size: 32),
            const SizedBox(width: 10),
            Text(
              "SPECTRA",
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          "Bandingkan spesifikasi ribuan handphone dengan mudah, cepat, dan akurat.",
          style: TextStyle(color: textGrey, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 30),

        // Link Sections (Grid 2 Kolom)
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5, // Mengatur tinggi baris
          children: [
            _buildFooterLinkColumn("Tentang", ["Tentang Kami", "Blog"]),
            _buildFooterLinkColumn("Produk", ["Komparasi HP", "Cek Harga"]),
            _buildFooterLinkColumn("Fitur", ["Filter Canggih", "Mode Gelap"]),
            _buildFooterLinkColumn("Lainnya", [
              "Pusat Bantuan",
              "Hubungi Kami",
            ]),
          ],
        ),
      ],
    );
  }

  // --- LAYOUT UNTUK DESKTOP/TABLET (Opsional jika di-resize) ---
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.smartphone_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "SPECTRA",
                    style: GoogleFonts.fredoka(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                "Solusi perbandingan gadget terbaik untuk keputusan cerdas Anda.",
                style: TextStyle(color: textGrey, fontSize: 13),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildFooterLinkColumn("Tentang", ["Tentang Kami", "Blog"]),
        ),
        Expanded(
          child: _buildFooterLinkColumn("Produk", ["Komparasi", "Review"]),
        ),
        Expanded(child: _buildFooterLinkColumn("Bantuan", ["FAQ", "Kontak"])),
      ],
    );
  }

  Widget _buildFooterLinkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        ...links.map(
          (link) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: InkWell(
              onTap: () {}, // Aksi kosong untuk demo
              child: Text(
                link,
                style: const TextStyle(color: textGrey, fontSize: 13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}
