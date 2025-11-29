import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PriceCheckPage extends StatelessWidget {
  const PriceCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cek Harga Terkini",
          style: GoogleFonts.fredoka(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF553C9A),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF0175C2)],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                const Icon(Icons.trending_down, color: Colors.white, size: 40),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Penurunan Harga",
                        style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        "Pantau gadget yang sedang turun harga minggu ini.",
                        style: GoogleFonts.nunito(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildPriceItem("iPhone 15", "Rp 12.999.000", "Rp 13.499.000", "-4%"),
          _buildPriceItem(
            "Samsung S24 Ultra",
            "Rp 19.500.000",
            "Rp 21.000.000",
            "-7%",
          ),
          _buildPriceItem("Xiaomi 14", "Rp 11.200.000", "Rp 11.999.000", "-6%"),
          _buildPriceItem(
            "Pixel 8 Pro",
            "Rp 14.500.000",
            "Rp 15.000.000",
            "-3%",
          ),
        ],
      ),
    );
  }

  Widget _buildPriceItem(
    String name,
    String currentPrice,
    String oldPrice,
    String discount,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      currentPrice,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      oldPrice,
                      style: const TextStyle(
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                discount,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
