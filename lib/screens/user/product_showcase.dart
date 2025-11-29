import 'package:flutter/material.dart';
import 'package:flutter_3d_controller/flutter_3d_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductShowcase extends StatefulWidget {
  final bool isDarkMode;

  const ProductShowcase({super.key, required this.isDarkMode});

  @override
  State<ProductShowcase> createState() => _ProductShowcaseState();
}

class _ProductShowcaseState extends State<ProductShowcase> {
  final Flutter3DController _controller = Flutter3DController();

  @override
  Widget build(BuildContext context) {
    final textColor = widget.isDarkMode
        ? Colors.white
        : const Color(0xFF553C9A);
    final cardColor = widget.isDarkMode
        ? const Color(0xFF2C2C3E)
        : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          // --- HEADER ---
          const Text(
            "FLAGSHIP TERBARU",
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "iPhone 17 Pro Max",
            style: GoogleFonts.fredoka(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Menggunakan Icon standard agar tidak error
                Icon(
                  Icons.threed_rotation,
                  size: 16,
                  color: textColor.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  "Geser untuk memutar 360°",
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),

          // --- 3D VIEWER AREA ---
          SizedBox(
            height: 400,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Efek Glow
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.2),
                        blurRadius: 60,
                        spreadRadius: 20,
                      ),
                    ],
                  ),
                ),

                // ====================================================
                // BAGIAN YANG DIGANTI (SRC)
                // ====================================================
                Flutter3DViewer(
                  // Link Astronaut ini 100% aman untuk Web
                  src:
                      'https://raw.githubusercontent.com/pizza3/asset/master/iphone.glb',

                  controller: _controller,
                  progressBarColor: Colors.orange,
                ),
              ],
            ),
          ),

          // --- SPESIFIKASI GRID ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Spesifikasi Utama",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 20),

                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    _buildSpecCard(
                      Icons.memory,
                      "Chipset",
                      "A19 Bionic Pro",
                      cardColor,
                      textColor,
                    ),
                    _buildSpecCard(
                      Icons.camera_alt,
                      "Kamera",
                      "200MP Quad",
                      cardColor,
                      textColor,
                    ),
                    _buildSpecCard(
                      Icons.battery_charging_full,
                      "Baterai",
                      "5500 mAh",
                      cardColor,
                      textColor,
                    ),
                    _buildSpecCard(
                      Icons.storage,
                      "Memori",
                      "Hingga 2TB",
                      cardColor,
                      textColor,
                    ),
                    _buildSpecCard(
                      Icons.screenshot_monitor,
                      "Layar",
                      "6.9\" Ultra XDR",
                      cardColor,
                      textColor,
                    ),
                    _buildSpecCard(
                      Icons.wifi_tethering,
                      "Koneksi",
                      "Wi-Fi 8E / 6G",
                      cardColor,
                      textColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecCard(
    IconData icon,
    String label,
    String value,
    Color bgColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isDarkMode ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.isDarkMode ? Colors.white10 : Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
