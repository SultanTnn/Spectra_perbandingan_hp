import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../comparison/brand_screen.dart';
import '../home/settings/app_language.dart';

// DATA MODEL
class Smartphone {
  final String name;
  final String brand;

  Smartphone({required this.name, required this.brand});

  factory Smartphone.fromJson(Map<String, dynamic> json) {
    return Smartphone(
      name: json['name'] as String? ?? AppLanguage.get('nama_tidak_diketahui'),
      brand:
          json['brand'] as String? ?? AppLanguage.get('brand_tidak_diketahui'),
    );
  }
}

// 2. WIDGET BUILDER
class HomeWidgets {
  final BuildContext context;
  final List<String> brands;
  final List<Smartphone> searchResults;
  final String query;
  final bool isSearchingProducts;
  final Color dynamicPrimary;
  final Color dynamicAccent;
  final Color dynamicCardColor;
  final Color brandTextColor;
  final Color brandSubTextColor;
  final Color errorIconColor;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;
  final TextEditingController searchController;
  final String Function(String) getTranslatedText;
  final List<String> searchHints;
  final int currentHintIndex;
  final Function() startHintTimer;

  const HomeWidgets({
    required this.context,
    required this.brands,
    required this.searchResults,
    required this.query,
    required this.isSearchingProducts,
    required this.dynamicPrimary,
    required this.dynamicAccent,
    required this.dynamicCardColor,
    required this.brandTextColor,
    required this.brandSubTextColor,
    required this.errorIconColor,
    required this.shimmerBaseColor,
    required this.shimmerHighlightColor,
    required this.searchController,
    required this.getTranslatedText,
    required this.searchHints,
    required this.currentHintIndex,
    required this.startHintTimer,
  });

  // STATIC HELPER: Mendapatkan path gambar brand
  static String getBrandImagePath(String brandName) {
    final brandLower = brandName.toLowerCase();
    final brandMap = {
      'samsung': 'assets/brands/samsung.png',
      'realme': 'assets/brands/realme.png',
      'oppo': 'assets/brands/oppo.png',
      'vivo': 'assets/brands/vivo.png',
      'xiaomi': 'assets/brands/xiaomi.png',
      'tecno': 'assets/brands/tecno.png',
      'infinix': 'assets/brands/infinix.png',
      'itel': 'assets/brands/itel.png',
      'apple': 'assets/brands/apple.png',
      'huawei': 'assets/brands/huawei.png',
    };
    return brandMap[brandLower] ?? 'assets/brands/samsung.png';
  }

  Widget buildLoadingShimmer({int count = 6, String title = 'Memuat Data...'}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: brandSubTextColor,
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: shimmerBaseColor,
          highlightColor: shimmerHighlightColor,
          child: Column(
            children: List.generate(
              count,
              (index) => Container(
                height: 90,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: dynamicCardColor,
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildErrorView({
    required String errorMessage,
    required Function() onTryAgain,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, size: 72, color: errorIconColor),
            const SizedBox(height: 20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: brandTextColor),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: dynamicPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                shadowColor: dynamicPrimary.withOpacity(0.4),
              ),
              onPressed: onTryAgain,
              icon: const Icon(Icons.refresh),
              label: Text(
                getTranslatedText('coba_lagi'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchAndCompareBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: dynamicCardColor,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              style: TextStyle(color: brandTextColor),
              decoration: InputDecoration(
                hintText: searchHints.isNotEmpty
                    ? searchHints[currentHintIndex]
                    : '',
                hintStyle: TextStyle(color: brandSubTextColor),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Icon(Icons.search, color: dynamicPrimary, size: 22),
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: brandSubTextColor),
                        onPressed: () {
                          searchController.clear();
                          startHintTimer(); // Restart timer
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 8.0,
                ),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (query.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(getTranslatedText('input_kosong_snack')),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else {
                  // FIX: Menambahkan phonesToCompare: []
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          BrandScreen(brand: query, phonesToCompare: []),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: dynamicPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 26),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 0,
              ),
              child: Text(
                getTranslatedText('cari_button'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPhoneCard(Smartphone phone) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: dynamicCardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Mengarahkan ke detail ${phone.name} dari brand ${phone.brand} (Implementasi detail screen diperlukan)',
                ),
                backgroundColor: dynamicAccent,
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: dynamicPrimary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: dynamicPrimary.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      phone.brand.isNotEmpty
                          ? phone.brand[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: dynamicPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        phone.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: brandTextColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Brand: ${phone.brand} - ${getTranslatedText('brand_detail_ketuk')}',
                        style: TextStyle(
                          fontSize: 13,
                          color: brandSubTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: brandSubTextColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBrandCard(String brand) {
    final primaryColor = const Color(0xFF553C9A);
    final secondaryColor = const Color(0xFF6C63FF);
    final accentColor = const Color(0xFF0175C2);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: secondaryColor.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BrandScreen(brand: brand, phonesToCompare: []),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.white.withOpacity(0.95)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: secondaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  // Brand Logo Image
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: secondaryColor.withOpacity(0.2),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        HomeWidgets.getBrandImagePath(brand),
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback jika gambar tidak ditemukan
                          return Center(
                            child: Text(
                              brand.isNotEmpty ? brand[0].toUpperCase() : '?',
                              style: GoogleFonts.nunito(
                                color: secondaryColor,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Brand Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          brand,
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.grey[900],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          getTranslatedText('brand_detail_ketuk'),
                          style: GoogleFonts.nunito(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Arrow Icon dengan Background
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: secondaryColor,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEmptySearchView({
    required bool isProductSearch,
    String? customTitle,
  }) {
    String title =
        customTitle ??
        (isProductSearch
            ? '${getTranslatedText('produk_ditemukan')}"$query" ${getTranslatedText('ditemukan')}.'
            : getTranslatedText('tidak_ada_brand'));
    String subtitle = isProductSearch
        ? 'Coba cek ejaan, kata kunci lain, atau pastikan API search_products.php aktif.'
        : 'Coba periksa koneksi atau sinkronkan data brand.';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(
            Icons.sentiment_dissatisfied_outlined,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 15),
          Text(
            title,
            style: TextStyle(color: brandSubTextColor, fontSize: 17),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildDrawerListTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    final Color dynamicBrandText = brandTextColor;

    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : dynamicPrimary),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.redAccent : dynamicBrandText,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      splashColor: dynamicPrimary.withOpacity(0.1),
    );
  }
}
