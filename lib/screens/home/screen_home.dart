import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';

import '../comparison/brand_screen.dart';
import '../auth/login_screen.dart';
import '../../utils/session.dart';
import '../profile_screen.dart';

class Smartphone {
  final String name;
  final String brand;

  Smartphone({required this.name, required this.brand});

  factory Smartphone.fromJson(Map<String, dynamic> json) {
    return Smartphone(
      name: json['name'] as String? ?? 'Nama Tidak Diketahui',
      brand: json['brand'] as String? ?? 'Brand Tidak Diketahui',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // --- KONSTANTA WARNA ---
  static const Color primaryPurple = Color(0xFF4B0082); 
  static const Color accentBlue = Color(0xFF6A5ACD);
  static const Color textColor = Colors.white;
  static const Color subTextColor = Colors.white70;
  static const Color cardColor = Colors.white;
  static const Color brandTextColor = Color(0xFF333333);
  static const Color brandSubTextColor = Color(0xFF888888);

  static const String BASE_URL =
      'http://10.71.91.197/api_hp'; // GANTI IP JIKA PERLU!

  // --- STATE VARIABLES ---
  List<String> brands = [];
  bool loading = true; 
  String errorMessage = '';
  List<Smartphone> searchResults = [];
  bool isSearchingProducts = false; 
  final TextEditingController searchController = TextEditingController();
  String query = '';
  bool _sessionLoaded = false;

  // Timer dan Animasi untuk Search Hint
  final List<String> _searchHints = const [
    'Ketik nama perangkat untuk membandingkan...',
    'Cari brand (mis. Samsung, Xiaomi)...',
    'Temukan merek favoritmu di sini!',
    'Bandingkan HP impian Anda!',
  ];
  int _currentHintIndex = 0;
  Timer? _hintTimer;

  // Animasi Background Gradient
  late AnimationController _animationController;
  late Animation<AlignmentGeometry> _topAlignmentAnimation;
  late Animation<AlignmentGeometry> _bottomAlignmentAnimation;
  late Animation<Color?> _color1Animation;
  late Animation<Color?> _color2Animation;

  final List<List<Color>> _gradientColorPairs = [
    [primaryPurple.withOpacity(0.9), accentBlue.withOpacity(0.9)],
    [const Color(0xFF2C0B4F), const Color(0xFF1E90FF)],
    [const Color(0xFF6A0DAD), const Color(0xFF483D8B)],
  ];
  int _currentColorPairIndex = 0;
  Timer? _gradientTimer;

  @override
  void initState() {
    super.initState();
    _loadSessionData();
    fetchBrands(); 
    
    searchController.addListener(() {
      final newQuery = searchController.text;
      setState(() {
        query = newQuery;
      });
      searchProducts(newQuery); 
    });
    
    _startHintTimer();

    // Inisialisasi Kontroler Animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
      setState(() {});
    });

    // Inisialisasi Animasi Alignment
    _topAlignmentAnimation = TweenSequence<AlignmentGeometry>([
      TweenSequenceItem(tween: Tween<AlignmentGeometry>(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween<AlignmentGeometry>(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
      TweenSequenceItem(tween: Tween<AlignmentGeometry>(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween<AlignmentGeometry>(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
    ]).animate(_animationController);

    _bottomAlignmentAnimation = TweenSequence<AlignmentGeometry>([
      TweenSequenceItem(tween: Tween<AlignmentGeometry>(begin: Alignment.bottomRight, end: Alignment.bottomLeft), weight: 1),
      TweenSequenceItem(tween: Tween<AlignmentGeometry>(begin: Alignment.bottomLeft, end: Alignment.topLeft), weight: 1),
      TweenSequenceItem(tween: Tween<AlignmentGeometry>(begin: Alignment.topLeft, end: Alignment.topRight), weight: 1),
      TweenSequenceItem(tween: Tween<AlignmentGeometry>(begin: Alignment.topRight, end: Alignment.bottomRight), weight: 1),
    ]).animate(_animationController);

    _startGradientAnimation();
  }

  @override
  void dispose() {
    searchController.dispose();
    _hintTimer?.cancel();
    _gradientTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // --- LOGIKA TIMER DAN ANIMASI ---
  void _startHintTimer() {
    _hintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentHintIndex = (_currentHintIndex + 1) % _searchHints.length;
      });
    });
  }

  void _startGradientAnimation() {
    _gradientTimer = Timer.periodic(const Duration(seconds: 8), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _currentColorPairIndex = (_currentColorPairIndex + 1) % _gradientColorPairs.length;
        _animationController.reset();
        _animationController.forward();
      });
    });
    _animationController.forward();
  }

  Future<void> _loadSessionData() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() {
      _sessionLoaded = true;
    });
  }

  // --- LOGIKA FETCH DATA ---

  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        searchResults = [];
        isSearchingProducts = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      isSearchingProducts = true;
    });

    final url = Uri.parse('$BASE_URL/search_products.php?query=$query');
    
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 5));

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        if (!mounted) return;
        setState(() {
          searchResults = data.map((json) => Smartphone.fromJson(json)).toList();
          isSearchingProducts = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          searchResults = [];
          isSearchingProducts = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        searchResults = [];
        isSearchingProducts = false;
      });
    }
  }

  Future<void> fetchBrands() async {
    final url = Uri.parse('$BASE_URL/get_brands.php');
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        if (!mounted) return;
        setState(() {
          brands = List<String>.from(data.map((b) => b.toString()));
          // HILANGKAN LOGIKA PENAMBAHAN 'Spectra' secara manual
          // brands.add('Spectra'); telah dihapus.
          
          brands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          loading = false;
          errorMessage = '';
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Gagal memuat data brand. Status: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Terjadi kesalahan koneksi API brand.';
        loading = false;
      });
    }
  }

  // --- LOGIKA NAVIGASI/DRAWER ---
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
      applicationName: 'Aplikasi Perbandingan HP',
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

  // --- WIDGET BUILDER ---
  @override
  Widget build(BuildContext context) {

    final List<Color> currentGradientColors = _gradientColorPairs[_currentColorPairIndex];

    _color1Animation = ColorTween(begin: currentGradientColors[0], end: currentGradientColors[0]).animate(_animationController);
    _color2Animation = ColorTween(begin: currentGradientColors[1], end: currentGradientColors[1]).animate(_animationController);

    Widget contentList;
    
    if (loading) {
      contentList = _buildLoadingShimmer();
    } else if (errorMessage.isNotEmpty) {
      contentList = _buildErrorView();
    } else if (query.trim().isNotEmpty) {
      if (isSearchingProducts) {
        contentList = _buildLoadingShimmer();
      } else if (searchResults.isEmpty) {
        contentList = _buildEmptySearchView(isProductSearch: true);
      } else {
        contentList = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Hasil Produk untuk "${query}" (${searchResults.length} ditemukan)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: brandTextColor,
                ),
              ),
            ),
            ...searchResults.map((phone) => _buildPhoneCard(phone)).toList(),
          ],
        );
      }
    } else {
      final displayedBrands = brands;
      
      contentList = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'Pilih Merek HP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: brandTextColor,
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (displayedBrands.isEmpty)
            _buildEmptySearchView(isProductSearch: false)
          else
            ...displayedBrands.map((b) => _buildBrandCard(b)).toList(),
        ],
      );
    }
    
    return Scaffold(
      backgroundColor: primaryPurple, 
      appBar: AppBar(
        // JUDUL DIUBAH DARI 'SPECTRA' MENJADI 'HP Compare'
        title: const Text(
          'HP Compare', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 2,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: CircleAvatar(
              radius: 15,
              backgroundColor: Colors.white24,
              backgroundImage: (UserSession.profileImageUrl != null && _sessionLoaded)
                  ? NetworkImage(UserSession.profileImageUrl!)
                  : null,
              child: (UserSession.profileImageUrl == null || UserSession.profileImageUrl!.isEmpty || !_sessionLoaded)
                  ? const Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
            onPressed: () {
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
          const SizedBox(width: 10),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryPurple, accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
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
                              color: primaryPurple,
                              size: 36,
                            )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    UserSession.namaLengkap ??
                        (_sessionLoaded ? 'Selamat Datang!' : 'Memuat...'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    UserSession.username ?? 'User Aktif',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            _buildDrawerListTile(Icons.home, 'Beranda', () => Navigator.pop(context)),
            _buildDrawerListTile(Icons.account_circle, 'Profile Saya', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((isUpdated) {
                if (isUpdated == true) {
                  setState(() {});
                }
              });
            }),
            _buildDrawerListTile(Icons.settings, 'Pengaturan', () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Menu Pengaturan belum tersedia"),
                  backgroundColor: primaryPurple,
                ),
              );
            }),
            _buildDrawerListTile(Icons.info_outline, 'Tentang Aplikasi', () {
              Navigator.pop(context);
              _showAboutDialog();
            }),
            const Divider(height: 20, thickness: 1, indent: 16, endIndent: 16),
            _buildDrawerListTile(Icons.logout, 'Log Out', _logout, isLogout: true),
          ],
        ),
      ),

      body: Stack(
        children: [
          // Background Gradient Animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: _topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value,
                    colors: [
                      _color1Animation.value!,
                      _color2Animation.value!,
                    ],
                  ),
                ),
              );
            },
          ),

          // Content Scrollable
          RefreshIndicator(
            color: primaryPurple,
            onRefresh: fetchBrands,
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      // Header Section
                      Container(
                        height: MediaQuery.of(context).size.height * 0.45,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'BANDINGKAN SEMUA',
                              style: GoogleFonts.montserrat(
                                fontSize: 40, 
                                fontWeight: FontWeight.w900, 
                                color: textColor,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    offset: Offset(0, 3),
                                    blurRadius: 6,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'spesifikasi handphone dengan mudah',
                              style: TextStyle(
                                fontSize: 18,
                                color: subTextColor,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            _buildSearchAndCompareBar(), 
                            const SizedBox(height: 30),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 30),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                      
                      // Brand/Search Results Section
                      Container(
                        color: cardColor, 
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 20,
                        ),
                        child: contentList, 
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET KOMPONEN ---

  Widget _buildDrawerListTile(IconData icon, String title, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.redAccent : primaryPurple,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.redAccent : brandTextColor,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      splashColor: primaryPurple.withOpacity(0.1),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200, // Mengubah baseColor agar shimmer terlihat
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(6, (index) => Container(
          height: 90,
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        )),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 72,
              color: primaryPurple.withOpacity(0.7),
            ),
            const SizedBox(height: 20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, color: brandTextColor),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                shadowColor: primaryPurple.withOpacity(0.4),
              ),
              onPressed: () {
                setState(() {
                  loading = true;
                  errorMessage = '';
                });
                fetchBrands();
              },
              icon: const Icon(Icons.refresh),
              label: const Text(
                'Coba lagi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndCompareBar() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
                hintText: _searchHints[_currentHintIndex],
                hintStyle: TextStyle(color: brandSubTextColor),
                prefixIcon: const Icon(Icons.search, color: primaryPurple),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, color: brandSubTextColor),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            query = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              if (query.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Masukkan nama brand atau produk untuk membandingkan!'),
                    backgroundColor: Colors.orange,
                  ),
                );
              } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Mengarahkan ke hasil pencarian untuk "$query"...'),
                    backgroundColor: primaryPurple,
                  ),
                );
                Navigator.push(
                  context,
                  // Menggunakan query sebagai brand untuk pencarian awal
                  MaterialPageRoute(builder: (_) => BrandScreen(brand: query)), 
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Cari', // Diubah dari 'Bandingkan' menjadi 'Cari' agar lebih sesuai dengan fungsi di sini
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneCard(Smartphone phone) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Logika navigasi ke detail HP (menggunakan brand dan nama/id HP)
             ScaffoldMessenger.of(context).showSnackBar(
               SnackBar(
                 content: Text('Mengarahkan ke detail ${phone.name} dari brand ${phone.brand} (Implementasi detail screen diperlukan)'),
                 backgroundColor: accentBlue,
               ),
             );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      phone.brand.isNotEmpty ? phone.brand[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: primaryPurple,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: brandTextColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Brand: ${phone.brand} - Ketuk untuk detail',
                        style: TextStyle(
                          fontSize: 13,
                          color: brandSubTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
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

  Widget _buildEmptySearchView({required bool isProductSearch}) {
    String title = isProductSearch 
        ? 'Produk "${query}" tidak ditemukan.' 
        : 'Tidak ada Brand yang tersedia.';
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

  Widget _buildBrandCard(String brand) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BrandScreen(brand: brand),
            ),
          ),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: primaryPurple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      brand.isNotEmpty ? brand[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: primaryPurple,
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
                        brand,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: brandTextColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Lihat semua produk & bandingkan',
                        style: TextStyle(
                          fontSize: 13,
                          color: brandSubTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
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
}