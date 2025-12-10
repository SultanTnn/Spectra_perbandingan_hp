// FILE: lib/screens/user/welcome_page.dart

import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// --- IMPORT ---
import '../pages/team_dev_page.dart';
import '../pages/about_us_page.dart';
import '../../service/api_service.dart';
import '../../models/smartphone.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../../utils/session.dart';
import '../../utils/unauth_limit.dart';
import '../comparison/compare_screen.dart'; // IMPORT COMPARE SCREEN
import 'footer_section.dart';
import 'product_showcase.dart';

class SearchOption {
  final String label;
  final String type;
  final dynamic data;

  SearchOption({required this.label, required this.type, required this.data});

  @override
  String toString() => label;
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final ApiService _apiService = ApiService();

  // State Data
  List<String> _brandList = [];
  List<SearchOption> _searchOptions = [];
  List<Smartphone> _phoneList = [];
  final List<Smartphone> _listUntukDibandingkan = [];

  // State UI
  bool _tampilkanHasilPerbandingan = false;
  bool _isPhoneLoading = false;
  String? _errorMessage;
  bool _isDarkMode = false;

  bool get _isLoggedIn => UserSession.id != null;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _fetchBrandsFromAPI();
    _populateSearchIndex();
  }

  // --- FUNGSI API ---
  Future<void> _fetchBrandsFromAPI() async {
    setState(() {
      _errorMessage = null;
    });
    try {
      final response = await http
          .get(Uri.parse('${ApiService.baseUrl}get_brands.php'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _brandList = jsonData.map((e) => e.toString()).toList();
            _brandList.sort(
              (a, b) => a.toLowerCase().compareTo(b.toLowerCase()),
            );
            _searchOptions = _brandList
                .map((b) => SearchOption(label: b, type: 'brand', data: b))
                .toList();
          });
        }
      } else {
        if (mounted) {
          setState(() => _errorMessage = "Gagal load brands.");
        }
      }
    } catch (e) {
      log("Error Brands: $e");
      if (mounted) {
        setState(() => _errorMessage = "Gagal Koneksi Server");
      }
    }
  }

  Future<void> _populateSearchIndex() async {
    if (_brandList.isEmpty) return;
    try {
      List<SearchOption> newOptions = List.from(_searchOptions);
      for (String brand in _brandList) {
        try {
          final phones = await _apiService.fetchPhonesByBrand(brand);
          for (var phone in phones) {
            newOptions.add(
              SearchOption(label: phone.namaModel, type: 'phone', data: phone),
            );
          }
        } catch (_) {}
      }
      if (mounted) {
        setState(() {
          _searchOptions = newOptions;
        });
      }
    } catch (e) {
      log("Search Index Error: $e");
    }
  }

  Future<void> _fetchPhonesFromAPI(String brand) async {
    setState(() {
      _isPhoneLoading = true;
      _phoneList = [];
      _tampilkanHasilPerbandingan = false;
      _errorMessage = null;
    });

    try {
      final List<Smartphone> phones = await _apiService.fetchPhonesByBrand(
        brand,
      );
      if (mounted) {
        setState(() {
          _phoneList = phones;
          if (_phoneList.isEmpty) {
            _errorMessage = "Tidak ada data HP untuk brand $brand.";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "Koneksi Gagal: ${e.toString()}");
      }
    } finally {
      if (mounted) setState(() => _isPhoneLoading = false);
    }
  }

  // --- FUNGSI PEMBELIAN LANGSUNG ---
  Future<void> _launchMarketplace(String? url, String storeName) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Link $storeName tidak tersedia")));
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Fallback
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  void _showStoreOptions(Smartphone phone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Beli ${phone.namaModel}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Pilih toko resmi untuk melanjutkan pembelian:",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Tombol Shopee
              ListTile(
                leading: const Icon(
                  Icons.shopping_bag,
                  color: Colors.orange,
                  size: 30,
                ),
                title: const Text(
                  "Shopee Official Store",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _launchMarketplace(phone.shopeeUrl, "Shopee");
                },
              ),
              const Divider(),

              // Tombol Tokopedia
              ListTile(
                leading: const Icon(Icons.store, color: Colors.green, size: 30),
                title: const Text(
                  "Tokopedia Official Store",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.pop(context);
                  _launchMarketplace(phone.tokopediaUrl, "Tokopedia");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme);
    final glassColor = _isDarkMode
        ? Colors.black.withValues(alpha: 0.4)
        : Colors.white.withValues(alpha: 0.2);
    final borderColor = _isDarkMode
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.3);
    final screenHeight = MediaQuery.of(context).size.height;

    return Theme(
      data: _isDarkMode
          ? ThemeData.dark().copyWith(textTheme: textTheme)
          : ThemeData.light().copyWith(textTheme: textTheme),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          leadingWidth: 220,
          leading: Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: glassColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  child: const Icon(
                    Icons.smartphone_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'SPECTRA',
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          title: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- MENU MERK ---
                    Theme(
                      data: Theme.of(context).copyWith(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        popupMenuTheme: PopupMenuThemeData(
                          color: _isDarkMode
                              ? const Color(0xFF1E1E2C)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        tooltip: "Pilih Merk HP",
                        offset: const Offset(0, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        onSelected: (String brand) {
                          setState(() {
                            _phoneList = [];
                            _listUntukDibandingkan.clear();
                            _tampilkanHasilPerbandingan = false;
                            _errorMessage = null;
                          });
                          FocusManager.instance.primaryFocus?.unfocus();
                          _fetchPhonesFromAPI(brand);
                        },
                        itemBuilder: (context) {
                          if (_brandList.isEmpty) {
                            return [
                              const PopupMenuItem(
                                enabled: false,
                                child: Text("Memuat data..."),
                              ),
                            ];
                          }
                          return _brandList.map((String brand) {
                            return PopupMenuItem<String>(
                              value: brand,
                              child: Text(
                                brand,
                                style: GoogleFonts.nunito(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }).toList();
                        },
                        child: _buildGlassMenuButton(
                          label: "Merk",
                          icon: Icons.smartphone_rounded,
                          isDropdown: true,
                          glassColor: glassColor,
                          borderColor: borderColor,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // --- TOMBOL TIM DEV ---
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TeamDevPage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.white.withValues(alpha: 0.3),
                        highlightColor: Colors.white.withValues(alpha: 0.1),
                        child: _buildGlassMenuButton(
                          label: "Tim Dev",
                          icon: Icons.group_rounded,
                          isDropdown: false,
                          glassColor: glassColor,
                          borderColor: borderColor,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    // --- TOMBOL TENTANG ---
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutUsPage(),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.white.withValues(alpha: 0.3),
                        highlightColor: Colors.white.withValues(alpha: 0.1),
                        child: _buildGlassMenuButton(
                          label: "Tentang",
                          icon: Icons.info_outline_rounded,
                          isDropdown: false,
                          glassColor: glassColor,
                          borderColor: borderColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
                    tooltip: _isDarkMode ? "Mode Terang" : "Mode Gelap",
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _isDarkMode
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        key: ValueKey(_isDarkMode),
                        color: Colors.yellowAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!_isLoggedIn)
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (!_isLoggedIn)
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF553C9A),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (_isLoggedIn)
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        UserSession.clearSession();
                        setState(() {});
                      },
                    ),
                ],
              ),
            ),
          ],
        ),

        body: AnimatedGradientBackground(
          isDarkMode: _isDarkMode,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // --- HEADER PENCARIAN ---
                  Container(
                    margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.smartphone_rounded,
                          color: Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'SPECTRA',
                          style: GoogleFonts.fredoka(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bandingkan spesifikasi ribuan handphone dengan mudah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 15),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            return Autocomplete<SearchOption>(
                              optionsBuilder: (TextEditingValue val) {
                                if (val.text == '')
                                  return const Iterable<SearchOption>.empty();
                                return _searchOptions.where(
                                  (opt) => opt.label.toLowerCase().contains(
                                    val.text.toLowerCase(),
                                  ),
                                );
                              },
                              displayStringForOption: (opt) => opt.label,
                              onSelected: (selection) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (selection.type == 'brand') {
                                  _fetchPhonesFromAPI(selection.data as String);
                                } else {
                                  setState(() {
                                    _phoneList = [selection.data as Smartphone];
                                    _listUntukDibandingkan.clear();
                                    _tampilkanHasilPerbandingan = false;
                                    _errorMessage = null;
                                    _isPhoneLoading = false;
                                  });
                                }
                              },
                              fieldViewBuilder:
                                  (
                                    context,
                                    controller,
                                    focusNode,
                                    onSubmitted,
                                  ) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      alignment: Alignment.center,
                                      child: TextField(
                                        controller: controller,
                                        focusNode: focusNode,
                                        style: const TextStyle(fontSize: 14),
                                        decoration: InputDecoration(
                                          hintText: "Cari HP...",
                                          hintStyle: const TextStyle(
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                          icon: Icon(
                                            Icons.search,
                                            color: const Color(0xFF553C9A),
                                            size: 20,
                                          ),
                                          contentPadding: const EdgeInsets.only(
                                            bottom: 10,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  // --- CONTENT AREA ---
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: _isDarkMode
                          ? const Color(0xFF1E1E2C)
                          : Colors.white,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                      child: Column(
                        children: [
                          // 1. BODY KONTEN
                          Container(
                            constraints: BoxConstraints(
                              minHeight: screenHeight * 0.6,
                            ),
                            color: _isDarkMode
                                ? const Color(0xFF1E1E2C)
                                : Colors.white,
                            child: _buildBodyContent(),
                          ),

                          // 2. FITUR 3D SHOWCASE
                          Container(
                            color: _isDarkMode
                                ? const Color(0xFF1E1E2C)
                                : Colors.white,
                            child: ProductShowcase(isDarkMode: _isDarkMode),
                          ),

                          // 3. FOOTER
                          const FooterSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  // ... WIDGET HELPER ...

  Widget _buildGlassMenuButton({
    required String label,
    required IconData icon,
    required bool isDropdown,
    required Color glassColor,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: glassColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (isDropdown) ...[
            const SizedBox(width: 2),
            const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
              size: 14,
            ),
          ],
        ],
      ),
    );
  }

  // --- LOGIKA UTAMA TOMBOL BANDINGKAN DENGAN LIMIT & NAVIGASI ---
  Widget? _buildFloatingActionButton() {
    if (_tampilkanHasilPerbandingan) {
      return FloatingActionButton.extended(
        onPressed: () => setState(() {
          _tampilkanHasilPerbandingan = false;
          _listUntukDibandingkan.clear();
          _phoneList.clear();
          _fetchBrandsFromAPI();
        }),
        label: const Text("Reset"),
        icon: const Icon(Icons.refresh),
        backgroundColor: Colors.redAccent,
      );
    }

    // Tombol Bandingkan Aktif
    if (_listUntukDibandingkan.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: () {
          // 1. Jika User Sudah Login -> Pindah ke CompareScreen (Tampilan Bagus + Beli Aktif)
          if (UserSession.isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CompareScreen(phones: _listUntukDibandingkan),
              ),
            );
            return;
          }

          // 2. Jika Tamu, Cek Limit (Maks 2x) & Tampil di Halaman Ini Saja
          if (UnauthComparisonLimit.checkAndIncrement()) {
            setState(() => _tampilkanHasilPerbandingan = true);
          } else {
            // 3. Jika Limit Habis, Tampilkan Dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Batas Akses Tamu Habis"),
                  content: const Text(
                    "Anda telah mencapai batas maksimal 2x perbandingan sebagai tamu. "
                    "Silakan login atau daftar untuk menikmati fitur tanpa batas.",
                  ),
                  actions: [
                    TextButton(
                      child: const Text("Batal"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      child: const Text("Login Sekarang"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            );
          }
        },
        label: Text('Bandingkan (${_listUntukDibandingkan.length})'),
        icon: const Icon(Icons.compare_arrows),
        backgroundColor: const Color(0xFF6C63FF),
      );
    }
    return null;
  }

  Widget _buildBodyContent() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(_errorMessage!),
        ),
      );
    }
    if (_tampilkanHasilPerbandingan) return _buildPerbandinganFinal();
    if (_isPhoneLoading) {
      return const Padding(
        padding: EdgeInsets.all(50),
        child: CircularProgressIndicator(),
      );
    }
    if (_phoneList.isNotEmpty) return _buildHasilPencarian();
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        children: [
          Icon(Icons.touch_app, size: 60, color: Colors.grey),
          Text(
            "Siap Membandingkan?",
            style: TextStyle(
              fontSize: 20,
              color: _isDarkMode ? Colors.white : Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerbandinganFinal() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'Perbandingan Spesifikasi',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _isDarkMode ? Colors.white : const Color(0xFF553C9A),
            ),
          ),
        ),
        SizedBox(
          height: 650,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _listUntukDibandingkan
                  .map((phone) => _buildKolomPerbandingan(phone))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKolomPerbandingan(Smartphone phone) {
    return Container(
      width: 240,
      height: 600,
      margin: const EdgeInsets.only(right: 16, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF2C2C3E) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              height: 120,
              padding: const EdgeInsets.all(10),
              child: phone.imageUrl.isNotEmpty
                  ? Image.network(phone.imageUrl, fit: BoxFit.contain)
                  : const Icon(Icons.phone_android, size: 50),
            ),
            SizedBox(
              height: 35,
              child: ElevatedButton.icon(
                // --- LOGIKA TOMBOL BELI TERKUNCI (MODE TAMU) ---
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Akses Terbatas"),
                      content: const Text(
                        "Silakan Login terlebih dahulu untuk mengakses link pembelian resmi.",
                      ),
                      actions: [
                        TextButton(
                          child: const Text("Batal"),
                          onPressed: () => Navigator.pop(context),
                        ),
                        ElevatedButton(
                          child: const Text("Login Sekarang"),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.lock, size: 14), // Ikon Gembok
                label: const Text(
                  "Login untuk Beli",
                  style: TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey, // Warna Abu-abu
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 15),
            Text(
              phone.namaModel,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            _buildSpecPill("Harga", phone.price, Colors.green),
            _buildSpecPill(
              "Layar",
              _parseSpec(phone.display, "Type:") ?? "N/A",
              Colors.blue,
            ),
            _buildSpecPill(
              "Chipset",
              _parseSpec(phone.platform, "Chipset:") ?? "N/A",
              Colors.orange,
            ),
            _buildSpecPill(
              "Memori",
              _parseSpec(phone.memory, "Internal:") ?? "N/A",
              Colors.purple,
            ),
            _buildSpecPill(
              "Kamera",
              _parseSpec(phone.mainCamera, "Triple:") ?? "Lihat detail",
              Colors.pink,
            ),
            _buildSpecPill(
              "Baterai",
              _parseSpec(phone.battery, "Type:") ?? "N/A",
              Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHasilPencarian() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.68,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      itemCount: _phoneList.length,
      itemBuilder: (ctx, i) => _buildPhoneCard(
        _phoneList[i],
        _listUntukDibandingkan.contains(_phoneList[i]),
      ),
    );
  }

  Widget _buildPhoneCard(Smartphone phone, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          if (!isSelected) {
            if (_listUntukDibandingkan.length >= 3) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Maksimal 3 HP")));
              return;
            }
            _listUntukDibandingkan.add(phone);
          } else {
            _listUntukDibandingkan.remove(phone);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF2C2C3E) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: const Color(0xFF6C63FF), width: 3)
              : Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: phone.imageUrl.isNotEmpty
                    ? Image.network(phone.imageUrl, fit: BoxFit.contain)
                    : const Icon(Icons.phone_android),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phone.namaModel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      phone.price,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                isSelected ? "Terpilih" : "Pilih",
                style: TextStyle(
                  color: isSelected ? const Color(0xFF6C63FF) : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecPill(String label, String value, MaterialColor color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String? _parseSpec(String? specString, String key) {
    if (specString == null || specString.isEmpty) return null;
    try {
      var lines = specString.split('\n');
      var line = lines.firstWhere(
        (l) => l.trim().startsWith(key),
        orElse: () => "N/A",
      );
      if (line == "N/A") return null;
      return line.substring(key.length).trim();
    } catch (e) {
      return null;
    }
  }
}

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final bool isDarkMode;
  const AnimatedGradientBackground({
    super.key,
    required this.child,
    required this.isDarkMode,
  });
  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _top;
  late Animation<Alignment> _bottom;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _top = TweenSequence<Alignment>([
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
    _bottom = TweenSequence<Alignment>([
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: _top.value,
            end: _bottom.value,
            colors: widget.isDarkMode
                ? [const Color(0xFF1A103C), const Color(0xFF2D1B4E)]
                : [
                    const Color(0xFF553C9A),
                    const Color(0xFF6C63FF),
                    const Color(0xFF0175C2),
                  ],
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
