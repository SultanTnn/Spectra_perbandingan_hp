// lib/screen/screen_home.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'brand_screen.dart'; // Layar yang menampilkan daftar HP merek tertentu

// --- IMPORT UNTUK PROFIL & LOGOUT ---
import 'login_screen.dart';
import 'session.dart';
import 'profile_screen.dart';
// ------------------------------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color primaryColor = Color(0xFF6C63FF);

  // ⚠️ PENTING: GANTI IP ADDRESS INI DENGAN IP KOMPUTER ANDA!
  // Ini harus sesuai dengan BASE_URL API Anda.
  static const String BASE_URL =
      'http://192.168.43.60/api_hp'; // <--- GANTI IP ANDA

  // 🔹 KEMBALI KE STRING: Hanya menyimpan nama merek
  List<String> brands = [];
  bool loading = true;
  String errorMessage = '';
  final TextEditingController searchController = TextEditingController();
  String query = '';
  bool _sessionLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    fetchBrands();
    searchController.addListener(() {
      setState(() {
        query = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Fungsi memuat data sesi (dari jawaban sebelumnya)
  Future<void> _loadSessionData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() {
      _sessionLoaded = true;
    });
  }

  // Fungsi untuk mengambil data merek dari API
  Future<void> fetchBrands() async {
    // 🔹 MENGGUNAKAN IP ADDRESS YANG BENAR
    final url = Uri.parse('$BASE_URL/get_brands.php');
    try {
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        if (!mounted) return;
        setState(() {
          // 🔹 MENGASUMSIKAN API MENGEMBALIKAN LIST OF STRING LAGI
          // Pastikan API PHP Anda juga mengembalikan List of String,
          // BUKAN List of Object/Map.
          brands = List<String>.from(data.map((b) => b.toString()));
          loading = false;
          errorMessage = '';
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Gagal memuat data. Status: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Terjadi kesalahan koneksi: $e';
        loading = false;
      });
    }
  }

  // Fungsi logout
  void _logout() {
    UserSession.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // Fungsi menampilkan dialog about
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Perbandingan HP',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2025 Aplikasi Perbandingan HP',
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: Text(
            'Aplikasi ini digunakan untuk membandingkan spesifikasi berbagai merek HP.',
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter merek berdasarkan input pencarian
    final displayed = query.isEmpty
        ? brands
        : brands
              .where((b) => b.toLowerCase().contains(query.toLowerCase()))
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perbandingan HP'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
      ),

      // --- DRAWER (Menu Samping) ---
      // (Tetap menggunakan logika session dari jawaban sebelumnya)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, Color(0xFF4B3BE3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        (UserSession.profileImageUrl != null && _sessionLoaded)
                        ? NetworkImage(UserSession.profileImageUrl!)
                        : null,
                    child:
                        (UserSession.profileImageUrl == null ||
                            UserSession.profileImageUrl!.isEmpty ||
                            !_sessionLoaded)
                        ? const Icon(
                            Icons.person,
                            color: primaryColor,
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    UserSession.namaLengkap ??
                        (_sessionLoaded ? 'Selamat Datang!' : 'Memuat...'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    UserSession.username ?? 'User Aktif',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: primaryColor),
              title: const Text('Beranda'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle, color: primaryColor),
              title: const Text('Profile Saya'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ).then((isUpdated) {
                  if (isUpdated == true) {
                    setState(() {});
                  }
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: primaryColor),
              title: const Text('Pengaturan'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Menu Pengaturan belum tersedia"),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline, color: primaryColor),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),

      // --- BODY ---
      body: loading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : errorMessage.isNotEmpty
          ? Center(
              // Tampilan error koneksi
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: primaryColor.withOpacity(0.9),
                    ),
                    const SizedBox(height: 12),
                    Text(errorMessage, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                      ),
                      onPressed: () {
                        setState(() {
                          loading = true;
                          errorMessage = '';
                        });
                        fetchBrands();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              color: primaryColor,
              onRefresh: fetchBrands,
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  // Banner Informasi
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.phone_android,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pilih Brand',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Lihat spesifikasi dan bandingkan HP dari brand favorit.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Search Field
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari brand (mis. Samsung, Xiaomi)...',
                      prefixIcon: const Icon(Icons.search, color: primaryColor),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: primaryColor.withOpacity(0.6),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Daftar Merek
                  if (displayed.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 56,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 8),
                          const Text('Brand tidak ditemukan'),
                        ],
                      ),
                    )
                  else
                    ...displayed.map(
                      (b) => Card(
                        // 🔹 MENGGUNAKAN 'b' (String)
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),

                          // 🔹 MENGGUNAKAN FALLBACK TEKS (Huruf Pertama)
                          leading: CircleAvatar(
                            backgroundColor: primaryColor,
                            child: Text(
                              b.isNotEmpty ? b[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),

                          // ----------------------------------------------------
                          title: Text(
                            b, // Menggunakan string merek
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: const Text(
                            'Tap untuk lihat produk dan bandingkan',
                          ),
                          trailing: const Icon(
                            Icons.keyboard_arrow_right,
                            color: primaryColor,
                          ),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              // Navigasi ke PhoneListScreen/BrandScreen dengan nama merek (string)
                              builder: (_) => BrandScreen(brand: b),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
