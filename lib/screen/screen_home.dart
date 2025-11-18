// sultantnn/spectra_perbandingan_hp/Spectra_perbandingan_hp-04d0ee372dbe119a87c7e04d14586d7bf3f38e59/lib/screen/screen_home.dart

// screen_home.dart (Versi Final - Ganti semua)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'brand_screen.dart';

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

  List<String> brands = [];
  bool loading = true;
  String errorMessage = '';
  final TextEditingController searchController = TextEditingController();
  String query = '';

  @override
  void initState() {
    super.initState();
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

  Future<void> fetchBrands() async {
    final url = Uri.parse('http://localhost/api_hp/get_brands.php');
    try {
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (!mounted) return;
        setState(() {
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

  void _logout() {
    UserSession.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

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

      // --- 🔹 INI KODE DRAWER YANG SUDAH DIPERBAIKI 🔹 ---
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
                    backgroundImage: UserSession.profileImageUrl != null
                        ? NetworkImage(UserSession.profileImageUrl!)
                        : null,
                    child: UserSession.profileImageUrl == null
                        ? const Icon(
                            Icons.person,
                            color: primaryColor,
                            size: 32,
                          )
                        : null,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    UserSession.namaLengkap ?? 'Selamat Datang!',
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

            // --- INI BAGIAN KUNCI UNTUK REFRESH ---
            ListTile(
              leading: const Icon(Icons.account_circle, color: primaryColor),
              title: const Text('Profile Saya'),
              onTap: () {
                Navigator.pop(context); // 1. Tutup drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ).then((isUpdated) {
                  // 2. "then" = SETELAH kembali

                  // 3. 'isUpdated' adalah 'true' yang kita kirim dari profile_screen
                  if (isUpdated == true) {
                    // 4. Minta HomeScreen untuk refresh dirinya sendiri
                    setState(() {});
                  }
                });
              },
            ),

            // --- AKHIR BAGIAN KUNCI ---
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

      // --- AKHIR DARI DRAWER ---
      body: // ... (Sisa kode body Anda tetap sama) ...
      loading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : errorMessage.isNotEmpty
          ? Center(
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
                              Text(
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
                          leading: CircleAvatar(
                            backgroundColor: primaryColor,
                            child: Text(
                              b.isNotEmpty ? b[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            b,
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
