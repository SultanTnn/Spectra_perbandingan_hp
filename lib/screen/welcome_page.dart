// lib/screen/welcome_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_application_1/screen/api_service.dart';
import 'package:flutter_application_1/screen/smartphone.dart';
import 'login_screen.dart'; // Pastikan file ini ada
import 'register_screen.dart'; // Pastikan file ini ada
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';


// --- HALAMAN UTAMA ---
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  // Warna Tema
  final primaryColor = const Color(0xFF553C9A);
  final secondaryColor = const Color(0xFF6C63FF);
  final blueColor = const Color(0xFF0175C2);
  
  // Instance ApiService
  final ApiService _apiService = ApiService(); 

  // State Data (Menggunakan model Smartphone)
  List<String> _brandList = [];
  String? _selectedBrandName;
  List<Smartphone> _phoneList = [];
  final List<Smartphone> _listUntukDibandingkan = [];

  // State UI
  bool _tampilkanHasilPerbandingan = false;
  bool _isBrandLoading = false;
  bool _isPhoneLoading = false;
  String? _errorMessage;

  // State Login (Simulasi)
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _fetchBrandsFromAPI();
  }

  // --- FUNGSI API ---

  Future<void> _fetchBrandsFromAPI() async {
    setState(() {
      _isBrandLoading = true;
      _errorMessage = null;
    });
    try {
      // 🚨 PERBAIKAN: Menggunakan ApiService.baseUrl
      // Asumsi endpoint get_brands.php ada di root API
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}get_brands.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        setState(() {
          _brandList = jsonData.cast<String>();
        });
      } else {
        setState(() {
          _errorMessage = "Gagal load brands: HTTP ${response.statusCode}";
        });
      }
    } catch (e) {
      log("Error Brands: $e");
      setState(() {
        _errorMessage = "Gagal Koneksi Brand API: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isBrandLoading = false;
      });
    }
  }

  Future<void> _fetchPhonesFromAPI() async {
    if (_selectedBrandName == null) return;

    setState(() {
      _isPhoneLoading = true;
      _phoneList = [];
      _tampilkanHasilPerbandingan = false;
      _errorMessage = null;
    });

    try {
      // 🚨 PERBAIKAN: Menggunakan fungsi fetch dari ApiService
      // Fungsi ini sudah menangani URL, parsing, dan error API.
      final List<Smartphone> phones = await _apiService.fetchPhonesByBrand(_selectedBrandName!);
      
      setState(() {
        _phoneList = phones;
        if (_phoneList.isEmpty) {
          _errorMessage = "Tidak ada data HP ditemukan untuk brand $_selectedBrandName.";
        }
      });
      
    } catch (e) {
      log("Error Phones: $e");
      setState(() {
        _errorMessage = "Koneksi Gagal: Pastikan IP di ApiService benar.\nError: ${e.toString()}";
      });
    } finally {
      setState(() {
        _isPhoneLoading = false;
      });
    }
  }

  // --- TAMPILAN UTAMA ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SPECTRA',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Menu Tengah
            Row(
              children: [
                _buildBrandDropdown(), // Dropdown Merk HP
                const SizedBox(width: 24),
                _buildDeveloperMenu(),
                const SizedBox(width: 24),
                TextButton(
                  onPressed: () => _showAboutDialog(context),
                  child: const Text(
                    'Tentang',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
            // Tombol Kanan (Login/Register)
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    // Navigasi ke Login Screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: Text(
                    _isLoggedIn ? 'Logout' : 'Masuk',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                if (!_isLoggedIn) // Hanya tampilkan jika belum login
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blueColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Daftar Akun'),
                  ),
              ],
            ),
          ],
        ),
      ),

      // Body dengan Animated Background
      body: AnimatedGradientBackground(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30.0),
              child: Column(
                children: [
                  Text(
                    'Selamat Datang di SPECTRA',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Platform perbandingan spesifikasi ponsel pintar terlengkap.',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: _buildBodyContent(),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'created by kelompok 3',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildBrandDropdown() {
    return PopupMenuButton<String>(
      tooltip: 'Pilih Merk HP',
      child: Row(
        children: [
          Text(
            _selectedBrandName ?? 'Merk HP',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          _isBrandLoading
              ? const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : const Icon(Icons.arrow_drop_down, color: Colors.white),
        ],
      ),
      itemBuilder: (context) => _brandList
          .map((brand) => PopupMenuItem(value: brand, child: Text(brand)))
          .toList(),
      onSelected: (val) {
        setState(() {
          _selectedBrandName = val;
          _phoneList = [];
          _listUntukDibandingkan.clear(); // Clear list perbandingan
          _tampilkanHasilPerbandingan = false;
          _errorMessage = null;
        });
        // Otomatis load data setelah pilih merk
        _fetchPhonesFromAPI();
      },
    );
  }

  Widget? _buildFloatingActionButton() {
    if (_tampilkanHasilPerbandingan) {
      return FloatingActionButton.extended(
        onPressed: () => setState(() {
          _tampilkanHasilPerbandingan = false;
          _listUntukDibandingkan.clear();
          _phoneList.clear();
          _selectedBrandName = null;
          _fetchBrandsFromAPI(); // Refresh brand list
        }),
        label: const Text("Reset & Kembali"),
        icon: const Icon(Icons.close),
        backgroundColor: Colors.red,
      );
    } else if (_listUntukDibandingkan.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: _tampilkanDialogPerbandingan,
        label: Text('Bandingkan (${_listUntukDibandingkan.length})'),
        icon: const Icon(Icons.compare_arrows),
        backgroundColor: secondaryColor,
      );
    }
    return null;
  }

  Widget _buildBodyContent() {
    if (_errorMessage != null) return _buildErrorWidget(_errorMessage!);
    if (_tampilkanHasilPerbandingan) return _buildPerbandinganFinal();
    if (_isPhoneLoading) return _buildShimmerLoading();
    if (_phoneList.isNotEmpty) return _buildHasilPencarian();
    return _buildKontenKosong();
  }

  // Widget Shimmer Loading (Efek Skeleton)
  Widget _buildShimmerLoading() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(width: 200, height: 24, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                childAspectRatio: 0.75, // Disesuaikan agar proporsi mirip Card HP
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHasilPencarian() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24.0),
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Hasil untuk: $_selectedBrandName',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text('Ditemukan ${_phoneList.length} HP'),
          const Divider(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 250,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _phoneList.length,
              itemBuilder: (context, index) {
                final phone = _phoneList[index];
                final bool isSelected = _listUntukDibandingkan.contains(phone);
                return _buildPhoneCard(phone, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Kartu HP dengan Checkbox dan Validasi Login
  Widget _buildPhoneCard(Smartphone phone, bool isSelected) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar HP
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: phone.imageUrl.isNotEmpty
                    ? Image.network(
                        phone.imageUrl, // Menggunakan field imageUrl dari model
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, _) => const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      )
                    : const Icon(
                        Icons.phone_android,
                        size: 60,
                        color: Colors.grey,
                      ),
              ),
            ),
            // Info Text
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    phone.namaModel,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _parseSpec(phone.platform, "Chipset:"),
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Checkbox dengan Validasi 3 Item
            CheckboxListTile(
              value: isSelected,
              title: const Text("Pilih", style: TextStyle(fontSize: 13)),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
              dense: true,
              activeColor: primaryColor,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    // VALIDASI LOGIN & JUMLAH ITEM
                    if (!_isLoggedIn && _listUntukDibandingkan.length >= 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            "Mode Tamu: Login untuk membandingkan lebih dari 3 HP!",
                          ),
                          backgroundColor: Colors.redAccent,
                          action: SnackBarAction(
                            label: 'Login',
                            textColor: Colors.white,
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            ),
                          ),
                        ),
                      );
                      return; // Batalkan aksi
                    }
                    _listUntukDibandingkan.add(phone);
                  } else {
                    _listUntukDibandingkan.remove(phone);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerbandinganFinal() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Perbandingan Spesifikasi',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _listUntukDibandingkan
                    .map((phone) => _buildKolomPerbandingan(phone))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKolomPerbandingan(Smartphone phone) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: phone.imageUrl.isNotEmpty
                  ? Image.network(phone.imageUrl, fit: BoxFit.contain)
                  : const Icon(
                      Icons.phone_android,
                      size: 50,
                      color: Colors.grey,
                    ),
            ),
            Text(
              phone.namaModel,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSpecRow("Harga", phone.price),
            _buildSpecRow("Layar", _parseSpec(phone.display, "Type:")),
            _buildSpecRow("Ukuran", _parseSpec(phone.display, "Size:")),
            _buildSpecRow("Resolusi", _parseSpec(phone.display, "Resolution:")),
            _buildSpecRow("OS", _parseSpec(phone.platform, "OS:")),
            _buildSpecRow("Chipset", _parseSpec(phone.platform, "Chipset:")),
            _buildSpecRow("Memori", _parseSpec(phone.memory, "Internal:")),
            _buildSpecRow(
              "Kamera Utama",
              _parseSpec(phone.mainCamera, "Triple:") ??
                  _parseSpec(phone.mainCamera, "Dual:") ??
                  "Lihat detail",
            ),
            _buildSpecRow(
              "Kamera Depan",
              _parseSpec(phone.selfieCamera, "Single:"),
            ),
            _buildSpecRow("Baterai", _parseSpec(phone.battery, "Type:")),
            _buildSpecRow("Charging", _parseSpec(phone.battery, "Charging:")),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Lainnya ---

  void _tampilkanDialogPerbandingan() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('HP yang Dipilih'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _listUntukDibandingkan.length,
              separatorBuilder: (ctx, i) => const Divider(),
              itemBuilder: (context, index) {
                final phone = _listUntukDibandingkan[index];
                return ListTile(
                  leading: phone.imageUrl.isNotEmpty
                      ? Image.network(
                          phone.imageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.phone_android),
                  title: Text(
                    phone.namaModel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _listUntukDibandingkan.remove(phone);
                      });
                      Navigator.of(context).pop();
                      if (_listUntukDibandingkan.isNotEmpty) {
                        _tampilkanDialogPerbandingan();
                      }
                    },
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _tampilkanHasilPerbandingan = true;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Bandingkan Sekarang'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKontenKosong() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_outlined,
            color: Colors.white.withOpacity(0.8),
            size: 60,
          ),
          const SizedBox(height: 20),
          Text(
            _selectedBrandName == null
                ? 'Mulai Bandingkan'
                : 'Siap Memuat Data',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _selectedBrandName == null
                ? 'Pilih "Merk HP" di menu atas untuk memulai.'
                : 'Sedang memuat data untuk $_selectedBrandName...',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 600),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text(
            'Terjadi Kesalahan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[800]),
          ),
        ],
      ),
    );
  }

  // Helper untuk mem-parsing spesifikasi (Sudah diperbaiki untuk konsistensi)
  String _parseSpec(String? specString, String key) {
    if (specString == null || specString.isEmpty) return "N/A";
    try {
      var lines = specString.split('\n');
      var line = lines.firstWhere(
        (l) => l.trim().startsWith(key),
        orElse: () => "N/A",
      );
      if (line == "N/A") return "N/A";
      return line.substring(key.length).trim();
    } catch (e) {
      return "N/A";
    }
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tentang SPECTRA'),
        content: const Text(
          'SPECTRA adalah platform perbandingan spesifikasi ponsel pintar terlengkap.\n\nDibuat oleh Kelompok 3.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  MenuAnchor _buildDeveloperMenu() {
    return MenuAnchor(
      alignmentOffset: const Offset(0, 10),
      builder: (context, controller, child) {
        return TextButton(
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: const Row(
            children: [
              Text(
                'Developer',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        );
      },
      menuChildren: [
        const Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: _DeveloperMegaMenu(),
        ),
      ],
    );
  }
}

// --- WIDGET PENDUKUNG ---

class _DeveloperMegaMenu extends StatelessWidget {
  const _DeveloperMegaMenu();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Developer Menu', style: TextStyle(fontWeight: FontWeight.bold)),
          Divider(),
          // Implementasi menu developer Anda
          Text('Simulasi: Mode Admin', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

// --- ANIMATED BACKGROUND (Widget Baru) ---
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _topAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
    ]).animate(_controller);

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color1 = Color(0xFF553C9A);
    const color2 = Color(0xFF6C63FF);
    const color3 = Color(0xFF0175C2);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _topAlignmentAnimation.value,
              end: _bottomAlignmentAnimation.value,
              colors: const [color1, color2, color3],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}