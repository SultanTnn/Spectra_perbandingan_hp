import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:url_launcher/url_launcher.dart'; // Aktifkan jika ingin link eksternal

// Import halaman-halaman yang sudah dibuat
import '../pages/about_us_page.dart';
import '../pages/price_check_page.dart';
import '../pages/features_info_page.dart';
import '../pages/help_center_page.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  static const Color footerBackground = Color(0xFF1A103C);
  static const Color textColor = Colors.white;
  static const Color textGrey = Colors.white60;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: footerBackground,
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BAGIAN ATAS ---
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return _buildDesktopLayout(context);
              } else {
                return _buildMobileLayout(context);
              }
            },
          ),

          const SizedBox(height: 40),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 20),

          // --- BAGIAN BAWAH ---
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                  Row(
                    children: [
                      _buildSocialIcon(Icons.send),
                      const SizedBox(width: 12),
                      _buildSocialIcon(Icons.camera_alt),
                      const SizedBox(width: 12),
                      _buildSocialIcon(Icons.business),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
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

  // --- LOGIKA NAVIGASI ---
  void _handleNavigation(BuildContext context, String linkName) {
    Widget? page;

    switch (linkName) {
      case "Tentang Kami":
        page = const AboutUsPage();
        break;
      case "Cek Harga":
      case "Review":
        page = const PriceCheckPage();
        break;
      case "Filter Canggih":
        page = const FeaturesInfoPage();
        break;
      case "Pusat Bantuan":
      case "FAQ":
        page = const HelpCenterPage();
        break;
      case "Komparasi HP":
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Silakan pilih HP di halaman utama untuk membandingkan.",
            ),
          ),
        );
        return;
    }

    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  // --- LAYOUT WIDGETS ---
  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          children: [
            // Revisi: Blog dihapus
            _buildFooterLinkColumn(context, "Tentang", ["Tentang Kami"]),

            // Produk tetap sama
            _buildFooterLinkColumn(context, "Produk", [
              "Komparasi HP",
              "Cek Harga",
            ]),

            // Revisi: Mode Gelap dihapus
            _buildFooterLinkColumn(context, "Fitur", ["Filter Canggih"]),

            // Revisi: Hubungi Kami dihapus
            _buildFooterLinkColumn(context, "Lainnya", ["Pusat Bantuan"]),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
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
        // Revisi Desktop: Link disesuaikan (menghapus Blog, dll)
        Expanded(
          child: _buildFooterLinkColumn(context, "Tentang", ["Tentang Kami"]),
        ),
        Expanded(
          child: _buildFooterLinkColumn(context, "Produk", [
            "Komparasi HP",
            "Cek Harga",
          ]),
        ),
        Expanded(
          child: _buildFooterLinkColumn(context, "Bantuan", ["Pusat Bantuan"]),
        ),
      ],
    );
  }

  Widget _buildFooterLinkColumn(
    BuildContext context,
    String title,
    List<String> links,
  ) {
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
              onTap: () => _handleNavigation(context, link),
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
