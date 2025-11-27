import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shimmer/shimmer.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

import '../comparison/brand_screen.dart';
import '../auth/login_screen.dart';
import '../../utils/session.dart';
import '../profile_screen.dart';

// ======================================================================
// 1. CLASS UNTUK LOGIKA LOKALISASI DAN KEYS
// ======================================================================

class AppLanguage {
  static const String keyLanguageCode = 'app_language_code';
  static const String keyDarkMode = 'is_dark_mode'; 

  static final Map<String, Map<String, String>> _localizedValues = {
    'id': {
      'beranda': 'Beranda',
      'profile_saya': 'Profile Saya',
      'pengaturan': 'Pengaturan',
      'tentang_aplikasi': 'Tentang Aplikasi',
      'log_out': 'Log Out',
      'selamat_datang': 'Selamat Datang!',
      'user_aktif': 'User Aktif',
      'bandingkan_semua': 'BANDINGKAN SEMUA',
      'slogan_hp': 'spesifikasi handphone dengan mudah',
      'cari_hint_1': 'Ketik nama perangkat untuk membandingkan...',
      'cari_hint_2': 'Cari brand (mis. Samsung, Xiaomi)...',
      'cari_hint_3': 'Temukan merek favoritmu di sini!',
      'cari_hint_4': 'Bandingkan HP impian Anda!',
      'pilih_merek_hp': 'Pilih Merek HP',
      'cari_button': 'Cari',
      'loading_merek': 'Memuat Merek HP...',
      'gagal_merek': 'Gagal memuat data brand.',
      'error_koneksi': 'Terjadi kesalahan koneksi API brand. Pastikan BASE_URL benar:',
      'coba_lagi': 'Coba lagi',
      'produk_ditemukan': 'Hasil Produk untuk "',
      'ditemukan': ' ditemukan)',
      'brand_detail_ketuk': 'Lihat semua produk & bandingkan',
      'input_kosong_snack': 'Masukkan nama brand atau produk untuk membandingkan!',
      'mode_tampilan': 'Mode Tampilan',
      'mode_terang': 'Mode Terang',
      'mode_gelap': 'Mode Gelap',
      'mengubah_mode': 'Mengubah ke mode ',
      'mode_gelap_label': 'gelap',
      'mode_terang_label': 'terang',
      'umum': 'Umum',
      'bahasa_aplikasi': 'Bahasa Aplikasi',
      'saat_ini': 'Saat ini:',
      'pilih_bahasa': 'Pilih Bahasa',
      'ganti_bahasa_snack': 'Bahasa berhasil diubah ke ',
      'data_sinkronisasi': 'Data & Sinkronisasi',
      'perbarui_data': 'Perbarui Data Brand',
      'sinkron_subtitle': 'Sinkronkan data HP terbaru dari server',
      'sinkron_snack': 'Melakukan sinkronisasi data...',
      'nama_tidak_diketahui': 'Nama Tidak Diketahui',
      'brand_tidak_diketahui': 'Brand Tidak Diketahui',
      'notifikasi': 'Notifikasi',
      'notif_push': 'Notifikasi Push',
      'notif_subtitle': 'Terima berita & pembaruan perbandingan',
      'privasi_keamanan': 'Privasi & Keamanan',
      'tidak_ada_brand': 'Tidak ada Brand yang tersedia.',
    },
    'en': {
      'beranda': 'Home',
      'profile_saya': 'My Profile',
      'pengaturan': 'Settings',
      'tentang_aplikasi': 'About App',
      'log_out': 'Log Out',
      'selamat_datang': 'Welcome!',
      'user_aktif': 'Active User',
      'bandingkan_semua': 'COMPARE ALL',
      'slogan_hp': 'mobile specifications easily',
      'cari_hint_1': 'Type device name to compare...',
      'cari_hint_2': 'Search brands (e.g. Samsung, Xiaomi)...',
      'cari_hint_3': 'Find your favorite brand here!',
      'cari_hint_4': 'Compare your dream phone!',
      'pilih_merek_hp': 'Select Handphone Brand',
      'cari_button': 'Search',
      'loading_merek': 'Loading Phone Brands...',
      'gagal_merek': 'Failed to load brand data.',
      'error_koneksi': 'API connection error for brands. Make sure BASE_URL is correct:',
      'coba_lagi': 'Try Again',
      'produk_ditemukan': 'Product Results for "',
      'ditemukan': ' found)',
      'brand_detail_ketuk': 'View all products & compare',
      'input_kosong_snack': 'Enter a brand or product name to compare!',
      'mode_tampilan': 'Display Mode',
      'mode_terang': 'Light Mode',
      'mode_gelap': 'Dark Mode',
      'mengubah_mode': 'Switching to ',
      'mode_gelap_label': 'dark mode',
      'mode_terang_label': 'light mode',
      'umum': 'General',
      'bahasa_aplikasi': 'App Language',
      'saat_ini': 'Current:',
      'pilih_bahasa': 'Select Language',
      'ganti_bahasa_snack': 'Language successfully changed to ',
      'data_sinkronisasi': 'Data & Synchronization',
      'perbarui_data': 'Update Brand Data',
      'sinkron_subtitle': 'Synchronize latest phone data from server',
      'sinkron_snack': 'Performing data synchronization...',
      'nama_tidak_diketahui': 'Unknown Name',
      'brand_tidak_diketahui': 'Unknown Brand',
      'notifikasi': 'Notifications',
      'notif_push': 'Push Notifications',
      'notif_subtitle': 'Receive news & comparison updates',
      'privasi_keamanan': 'Privacy & Security',
      'tidak_ada_brand': 'No Brands available.',
    },
    'ms': {
      'beranda': 'Laman Utama',
      'profile_saya': 'Profil Saya',
      'pengaturan': 'Tetapan',
      'tentang_aplikasi': 'Mengenai Aplikasi',
      'log_out': 'Log Keluar',
      'selamat_datang': 'Selamat Datang!',
      'user_aktif': 'Pengguna Aktif',
      'bandingkan_semua': 'BANDINGKAN SEMUA',
      'slogan_hp': 'spesifikasi telefon bimbit dengan mudah',
      'cari_hint_1': 'Taip nama peranti untuk membandingkan...',
      'cari_hint_2': 'Cari jenama (cth. Samsung, Xiaomi)...',
      'cari_hint_3': 'Cari jenama kegemaran anda di sini!',
      'cari_hint_4': 'Bandingkan telefon impian anda!',
      'pilih_merek_hp': 'Pilih Jenama Telefon',
      'cari_button': 'Cari',
      'loading_merek': 'Memuat Jenama Telefon...',
      'gagal_merek': 'Gagal memuat data jenama.',
      'error_koneksi': 'Ralat sambungan API untuk jenama. Pastikan BASE_URL betul:',
      'coba_lagi': 'Cuba Lagi',
      'produk_ditemukan': 'Keputusan Produk untuk "',
      'ditemukan': ' dijumpai)',
      'brand_detail_ketuk': 'Lihat semua produk & bandingkan',
      'input_kosong_snack': 'Masukkan nama jenama atau produk untuk membandingkan!',
      'mode_tampilan': 'Mod Paparan',
      'mode_terang': 'Mod Terang',
      'mode_gelap': 'Mod Gelap',
      'mengubah_mode': 'Bertukar kepada ',
      'mode_gelap_label': 'mod gelap',
      'mode_terang_label': 'mod terang',
      'umum': 'Umum',
      'bahasa_aplikasi': 'Bahasa Aplikasi',
      'saat_ini': 'Semasa:',
      'pilih_bahasa': 'Pilih Bahasa',
      'ganti_bahasa_snack': 'Bahasa berjaya ditukar kepada ',
      'data_sinkronisasi': 'Data & Penyegerakan',
      'perbarui_data': 'Kemas Kini Data Jenama',
      'sinkron_subtitle': 'Segerakkan data telefon terkini dari pelayan',
      'sinkron_snack': 'Melakukan penyegerakan data...',
      'nama_tidak_diketahui': 'Nama Tidak Diketahui',
      'brand_tidak_diketahui': 'Jenama Tidak Diketahui',
      'notifikasi': 'Pemberitahuan',
      'notif_push': 'Pemberitahuan Tolak',
      'notif_subtitle': 'Terima berita & kemas kini perbandingan',
      'privasi_keamanan': 'Privasi & Keselamatan',
      'tidak_ada_brand': 'Tiada Jenama tersedia.',
    }
  };

  static String currentLanguageCode = 'id'; 
  
  static String get(String key) {
    return _localizedValues[currentLanguageCode]?[key] ?? _localizedValues['id']![key] ?? key;
  }
}

class Smartphone {
  final String name;
  final String brand;

  Smartphone({required this.name, required this.brand});

  factory Smartphone.fromJson(Map<String, dynamic> json) {
    return Smartphone(
      name: json['name'] as String? ?? AppLanguage.get('nama_tidak_diketahui'),
      brand: json['brand'] as String? ?? AppLanguage.get('brand_tidak_diketahui'),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  
  // --- STATE VARIABLES ---
  List<String> brands = [];
  bool loading = true; 
  String errorMessage = '';
  List<Smartphone> searchResults = [];
  bool isSearchingProducts = false; 
  final TextEditingController searchController = TextEditingController();
  String query = '';
  bool _sessionLoaded = false;
  String? _lastProfileImageUrl;
  int _profileImageCacheKey = 0;
  List<String> _searchHints = []; 
  int _currentHintIndex = 0;
  Timer? _hintTimer;
  bool _isDarkModeActive = false; 

  // --- KONSTANTA WARNA DINAMIS BERDASARKAN TEMA ---
  Color _getPrimaryColor() => _isDarkModeActive ? const Color(0xFF9370DB) : const Color(0xFF4B0082); 
  Color _getAccentColor() => _isDarkModeActive ? const Color(0xFF1E90FF) : const Color(0xFF6A5ACD); 
  Color _getTextColor() => _isDarkModeActive ? Colors.white : Colors.white;
  Color _getSubTextColor() => _isDarkModeActive ? Colors.white70 : Colors.white70;
  Color _getCardColor() => _isDarkModeActive ? const Color(0xFF2C2C2C) : Colors.white; 
  Color _getBrandTextColor() => _isDarkModeActive ? Colors.white : const Color(0xFF333333); 
  Color _getBrandSubTextColor() => _isDarkModeActive ? Colors.grey.shade400 : const Color(0xFF888888); 
  Color _getBackgroundColor() => _isDarkModeActive ? const Color(0xFF121212) : _getPrimaryColor(); 
  Color _getErrorIconColor() => _getPrimaryColor().withOpacity(0.7);
  Color _getShimmerBaseColor() => _isDarkModeActive ? Colors.grey.shade800 : Colors.grey.shade200;
  Color _getShimmerHighlightColor() => _isDarkModeActive ? Colors.grey.shade700 : Colors.grey.shade100;
  
  static const String BASE_URL =
      'http://192.168.1.4/api_hp'; 

  // Animasi Background Gradient
  late AnimationController _animationController;
  late Animation<AlignmentGeometry> _topAlignmentAnimation;
  late Animation<AlignmentGeometry> _bottomAlignmentAnimation;
  late Animation<Color?> _color1Animation;
  late Animation<Color?> _color2Animation;

  final List<List<Color>> _gradientColorPairs = [
    [const Color(0xFF4B0082).withOpacity(0.9), const Color(0xFF6A5ACD).withOpacity(0.9)],
    [const Color(0xFF2C0B4F), const Color(0xFF1E90FF)],
    [const Color(0xFF6A0DAD), const Color(0xFF483D8B)],
  ];
  int _currentColorPairIndex = 0;
  Timer? _gradientTimer;

  // --- LOGIKA SETTINGS & LOKALISASI ---
  String _getTranslatedText(String key) {
    return AppLanguage.get(key);
  }

  // MEMUAT SEMUA SETTINGS (Bahasa & Tema)
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Language
    final code = prefs.getString(AppLanguage.keyLanguageCode) ?? 'id';
    AppLanguage.currentLanguageCode = code; 
    
    // Load Theme
    final isDark = prefs.getBool(AppLanguage.keyDarkMode) ?? false; 
    
    _updateSearchHints();

    if (mounted) {
      setState(() {
        _isDarkModeActive = isDark; 
      });
    }
  }

  void _updateSearchHints() {
     _searchHints = [
      _getTranslatedText('cari_hint_1'),
      _getTranslatedText('cari_hint_2'),
      _getTranslatedText('cari_hint_3'),
      _getTranslatedText('cari_hint_4'),
    ];
  }


  @override
  void initState() {
    super.initState();
    // Panggil _loadSettings di awal
    _loadSettings().then((_) {
      _loadSessionData(); // Memuat sesi setelah settings
      fetchBrands();
      _startGradientAnimation(); 
    });
    
    searchController.addListener(() {
      final newQuery = searchController.text;
      setState(() {
        query = newQuery;
      });
      if (newQuery.trim().isNotEmpty) {
        searchProducts(newQuery); 
      } else {
        setState(() {
          searchResults = [];
          isSearchingProducts = false;
        });
        _startHintTimer();
      }
    });
    
    _startHintTimer(); 

    // Inisialisasi Animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addListener(() {
      setState(() {});
    });
    
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
    _hintTimer?.cancel(); 
    if (_searchHints.isEmpty) {
      _updateSearchHints();
    }

    _hintTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (searchController.text.isEmpty) {
        setState(() {
          _currentHintIndex = (_currentHintIndex + 1) % _searchHints.length;
        });
      } else {
        timer.cancel();
      }
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

  // ==========================================================
  // PERBAIKAN: Fungsi untuk memuat ulang data sesi dan URL gambar
  // ==========================================================
  Future<void> _loadSessionData() async {
    // Memuat ulang data sesi, termasuk profileImageUrl terbaru
    await UserSession.loadData(); 
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() {
      _sessionLoaded = true;
      // Update cached profile image info with normalized URL
      if (_lastProfileImageUrl != UserSession.profileImageUrl) {
        _lastProfileImageUrl = UserSession.profileImageUrl;
        if (_lastProfileImageUrl != null) {
          // remove any existing cache-busting args
          _lastProfileImageUrl = _lastProfileImageUrl!.split('?').first;
        }
        _profileImageCacheKey = DateTime.now().millisecondsSinceEpoch;
      }
    });
  }

  // --- LOGIKA FETCH DATA & API ---
  // ... (searchProducts dan fetchBrands tidak berubah) ...

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

    _hintTimer?.cancel();

    final url = Uri.parse('$BASE_URL/search_products.php?query=$query');
    
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 5));

      if (!mounted) return; 

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
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
          
          brands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          loading = false;
          errorMessage = '';
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = '${_getTranslatedText('gagal_merek')} Status: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = '${_getTranslatedText('error_koneksi')} $BASE_URL';
        loading = false;
      });
    }
  }

  // --- LOGIKA NAVIGASI/DRAWER ---
  Future<void> _logout() async {
    await UserSession.clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // Navigasi ke Settings dan memuat ulang jika ada perubahan (bahasa/tema)
  void _navigateToSettings() async {
    Navigator.pop(context); 
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );

    if (result == true) {
      await _loadSettings(); // Memuat bahasa DAN tema baru dari SharedPreferences
      fetchBrands(); 
      setState(() {});
    }
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

  // ==========================================================
  // PERBAIKAN: Fungsi navigasi ke Profile dan memuat ulang data sesi
  // ==========================================================
  void _navigateToProfile() async {
    // Use maybeOf to avoid exception if Scaffold not in the widget tree for some reason.
    final scaffoldState = Scaffold.maybeOf(context);
    final drawerOpen = scaffoldState?.isDrawerOpen ?? false;

    // If the drawer is open, close it first so the profile page doesn't appear under the drawer.
    if (drawerOpen) {
      Navigator.pop(context); // Tutup drawer jika dipanggil dari drawer
      // Wait for the drawer closing animation to finish.
      await Future.delayed(const Duration(milliseconds: 250));
    }

    // Tunggu hasil dari ProfileScreen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );

    // If the ProfileScreen returned a URL string, use that to update UI immediately
    if (result is String) {
      setState(() {
        _lastProfileImageUrl = result;
        _profileImageCacheKey = DateTime.now().millisecondsSinceEpoch;
      });
    } else if (result == true || result == null) {
      await _loadSessionData(); // Memuat ulang data sesi dan URL gambar profil
    }
  }


  // --- WIDGET BUILDER ---
  @override
  Widget build(BuildContext context) {

    // Mengambil warna berdasarkan tema aktif
    final Color dynamicPrimary = _getPrimaryColor();
    final Color dynamicAccent = _getAccentColor();
    // final Color dynamicCardColor = _getCardColor(); // unused after aesthetic changes
    
    final List<Color> currentGradientColors = _isDarkModeActive
        ? [dynamicPrimary, dynamicAccent] 
        : _gradientColorPairs[_currentColorPairIndex]; 

    _color1Animation = ColorTween(begin: currentGradientColors[0], end: currentGradientColors[0]).animate(_animationController);
    _color2Animation = ColorTween(begin: currentGradientColors[1], end: currentGradientColors[1]).animate(_animationController);

    Widget contentList;
    final trimmedQuery = query.trim();
    
    if (loading) {
      contentList = _buildLoadingShimmer(count: 6, title: _getTranslatedText('loading_merek'));
    } else if (errorMessage.isNotEmpty) {
      contentList = _buildErrorView();
    } else if (trimmedQuery.isNotEmpty) {
      if (isSearchingProducts) {
        contentList = _buildLoadingShimmer(count: 3, title: '${_getTranslatedText('cari_button')}...');
      } else if (searchResults.isNotEmpty) {
        contentList = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${_getTranslatedText('produk_ditemukan')}"${trimmedQuery}" (${searchResults.length} ${_getTranslatedText('ditemukan')})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getBrandTextColor(),
                ),
              ),
            ),
            ...searchResults.map((phone) => _buildPhoneCard(phone)).toList(),
          ],
        );
      } else {
        final List<String> matchingBrands = brands
            .where((b) => b.toLowerCase().contains(trimmedQuery.toLowerCase()))
            .take(3)
            .toList();

        if (matchingBrands.isNotEmpty) {
          contentList = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...matchingBrands.map((b) => _buildBrandCard(b)).toList(),
            ],
          );
        } else {
          contentList = _buildEmptySearchView(isProductSearch: true);
        }
      }
    } else {
      contentList = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _getTranslatedText('pilih_merek_hp'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getBrandTextColor(),
              ),
            ),
          ),
          const SizedBox(height: 15),
          if (brands.isEmpty)
            _buildEmptySearchView(isProductSearch: false)
          else
            ...brands.map((b) => _buildBrandCard(b)).toList(),
        ],
      );
    }
    
    return Scaffold(
      backgroundColor: _getBackgroundColor(), 
      appBar: AppBar(
        title: Text(
          'SPECTRA', 
          style: GoogleFonts.montserrat( 
            fontSize: 22, 
            fontWeight: FontWeight.w900, 
            color: _getTextColor(), 
            letterSpacing: 2,
            shadows: [ 
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.2),
              ),
            ],
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: _getTextColor()), 
        actions: [
          // ==========================================================
          // PERBAIKAN: Aksi tombol profile di AppBar
          // ==========================================================
          IconButton(
            icon: CircleAvatar(
              key: ValueKey(_profileImageCacheKey),
              radius: 15,
              backgroundColor: Colors.white24,
              // Memastikan widget Avatar menggunakan data terbaru dari UserSession
              backgroundImage: (_lastProfileImageUrl != null && _sessionLoaded)
                  ? NetworkImage('$_lastProfileImageUrl?cb=$_profileImageCacheKey')
                  : null,
              child: (_lastProfileImageUrl == null || _lastProfileImageUrl!.isEmpty || !_sessionLoaded)
                  ? Icon(Icons.person, color: _getPrimaryColor(), size: 20)
                  : null,
            ),
            onPressed: _navigateToProfile, // Memanggil fungsi navigasi
          ),
          const SizedBox(width: 10),
        ],
      ),

      drawer: Drawer(
        backgroundColor: _getCardColor(), 
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              decoration: BoxDecoration(
                // Warna gradient dinamis
                gradient: LinearGradient(
                  colors: [dynamicPrimary, dynamicAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    CircleAvatar(
                      key: ValueKey(_profileImageCacheKey),
                    radius: 30,
                    backgroundColor: Colors.white,
                    // Memastikan widget Avatar menggunakan data terbaru dari UserSession
                    backgroundImage:
                      (_lastProfileImageUrl != null && _sessionLoaded)
                      ? NetworkImage('$_lastProfileImageUrl?cb=$_profileImageCacheKey')
                      : null,
                    child:
                      (_lastProfileImageUrl == null ||
                        _lastProfileImageUrl!.isEmpty ||
                        !_sessionLoaded)
                        ? Icon(
                              Icons.person,
                              color: dynamicPrimary,
                              size: 36,
                            )
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    UserSession.namaLengkap ??
                        (_sessionLoaded ? _getTranslatedText('selamat_datang') : 'Memuat...'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    UserSession.username ?? _getTranslatedText('user_aktif'),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            _buildDrawerListTile(Icons.home, _getTranslatedText('beranda'), () => Navigator.pop(context)),
            // ==========================================================
            // PERBAIKAN: Aksi tombol profile di Drawer
            // ==========================================================
            _buildDrawerListTile(Icons.account_circle, _getTranslatedText('profile_saya'), _navigateToProfile),
            _buildDrawerListTile(Icons.settings, _getTranslatedText('pengaturan'), _navigateToSettings), 
            _buildDrawerListTile(Icons.info_outline, _getTranslatedText('tentang_aplikasi'), () {
              Navigator.pop(context);
              _showAboutDialog();
            }),
            Divider(height: 20, thickness: 1, indent: 16, endIndent: 16, color: _getBrandSubTextColor()),
            _buildDrawerListTile(Icons.logout, _getTranslatedText('log_out'), () => _logout(), isLogout: true),
          ],
        ),
      ),

      body: Stack(
        children: [
          // Background Gradient Animation (restored default background - image removed)
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: _topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value,
                    colors: [
                      // Menggunakan dynamic color untuk gradasi animasi
                      _isDarkModeActive ? dynamicPrimary : _color1Animation.value!,
                      _isDarkModeActive ? dynamicAccent : _color2Animation.value!,
                    ],
                  ),
                ),
              );
            },
          ),

          // Content Scrollable
          RefreshIndicator(
            color: dynamicPrimary, 
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
                              _getTranslatedText('bandingkan_semua'),
                              style: GoogleFonts.montserrat(
                                fontSize: 46,
                                fontWeight: FontWeight.w900,
                                color: _getTextColor(),
                                letterSpacing: 1.0,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 4),
                                    blurRadius: 8,
                                    color: Colors.black.withOpacity(0.35),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _getTranslatedText('slogan_hp'),
                              style: TextStyle(
                                fontSize: 18,
                                color: _getSubTextColor(),
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 30),
                            // Larger, more prominent search bar with pill CTA
                            _buildSearchAndCompareBar(),
                            const SizedBox(height: 30),
                            Icon(Icons.keyboard_arrow_down, color: _getTextColor(), size: 30),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                      
                      // Brand/Search Results Section (floating white card)
                      Transform.translate(
                        offset: const Offset(0, -45),
                        child: Container(
                        decoration: BoxDecoration(
                          color: _isDarkModeActive ? _getCardColor() : Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, -6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                        child: contentList,
                      ),
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
    final Color dynamicPrimary = _getPrimaryColor();
    final Color dynamicBrandText = _getBrandTextColor();
    
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.redAccent : dynamicPrimary,
      ),
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

  Widget _buildLoadingShimmer({int count = 6, String title = 'Memuat Data...'}) {
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
              color: _getBrandSubTextColor(),
            ),
          ),
        ),
        Shimmer.fromColors(
          baseColor: _getShimmerBaseColor(), 
          highlightColor: _getShimmerHighlightColor(),
          child: Column(
            children: List.generate(count, (index) => Container(
              height: 90,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _getCardColor(),
                borderRadius: BorderRadius.circular(18),
              ),
            )),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView() {
    final Color dynamicPrimary = _getPrimaryColor();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 72,
              color: _getErrorIconColor(),
            ),
            const SizedBox(height: 20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: _getBrandTextColor()),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: dynamicPrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 6,
                shadowColor: dynamicPrimary.withOpacity(0.4),
              ),
              onPressed: () {
                setState(() {
                  loading = true;
                  errorMessage = '';
                });
                fetchBrands();
              },
              icon: const Icon(Icons.refresh),
              label: Text(
                _getTranslatedText('coba_lagi'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndCompareBar() {
    final Color dynamicPrimary = _getPrimaryColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: _getCardColor(),
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
              style: TextStyle(color: _getBrandTextColor()),
              decoration: InputDecoration(
                hintText: _searchHints.isNotEmpty ? _searchHints[_currentHintIndex] : '', 
                hintStyle: TextStyle(color: _getBrandSubTextColor()),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Icon(Icons.search, color: dynamicPrimary, size: 22),
                ),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: _getBrandSubTextColor()),
                        onPressed: () {
                          searchController.clear();
                          if (_hintTimer == null || !_hintTimer!.isActive) {
                             _startHintTimer();
                          }
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
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
                      content: Text(_getTranslatedText('input_kosong_snack')),
                      backgroundColor: Colors.orange,
                    ),
                  );
              } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BrandScreen(brand: query)), 
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
              _getTranslatedText('cari_button'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneCard(Smartphone phone) {
    final Color dynamicPrimary = _getPrimaryColor();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _isDarkModeActive ? _getCardColor() : Colors.white,
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
                 content: Text('Mengarahkan ke detail ${phone.name} dari brand ${phone.brand} (Implementasi detail screen diperlukan)'),
                 backgroundColor: _getAccentColor(),
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
                      phone.brand.isNotEmpty ? phone.brand[0].toUpperCase() : '?',
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
                          color: _getBrandTextColor(),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Brand: ${phone.brand} - ${_getTranslatedText('brand_detail_ketuk')}',
                        style: TextStyle(
                          fontSize: 13,
                          color: _getBrandSubTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _getBrandSubTextColor(),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandCard(String brand) {
    final Color dynamicPrimary = _getPrimaryColor();
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: _getCardColor(),
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
                    color: dynamicPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      brand.isNotEmpty ? brand[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: dynamicPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: _getBrandTextColor(),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _getTranslatedText('brand_detail_ketuk'),
                        style: TextStyle(
                          fontSize: 13,
                          color: _getBrandSubTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: _getBrandSubTextColor(),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchView({required bool isProductSearch, String? customTitle}) {
    String title = customTitle ?? (isProductSearch 
        ? '${_getTranslatedText('produk_ditemukan')}"${query}" ${_getTranslatedText('ditemukan')}.' 
        : _getTranslatedText('tidak_ada_brand')); 
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
            style: TextStyle(color: _getBrandSubTextColor(), fontSize: 17),
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
}

// ======================================================================
// KELAS UNTUK PENGATURAN (SETTINGS SCREEN)
// ======================================================================

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color primaryPurple = Color(0xFF4B0082); 
  bool _isDarkMode = false; 
  bool _isPushNotificationEnabled = true; 

  late String _currentLanguageCode; 
  final Map<String, String> _languages = {
    'id': 'Bahasa Indonesia',
    'en': 'English',
    'ms': 'Bahasa Melayu',
  };

  @override
  void initState() {
    super.initState();
    _currentLanguageCode = AppLanguage.currentLanguageCode;
    _loadInitialSettings(); 
  }

  // --- FUNGSI TEMA & SETTINGS PERSISTENCE ---

  Future<void> _loadInitialSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isDarkMode = prefs.getBool(AppLanguage.keyDarkMode) ?? false;
      });
    }
  }

  Future<void> _saveLanguage(String newCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppLanguage.keyLanguageCode, newCode);
    AppLanguage.currentLanguageCode = newCode;
  }
  
  // FUNGSI UNTUK SIMPAN TEMA
  Future<void> _saveThemeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppLanguage.keyDarkMode, value);
  }

  String _getTranslatedText(String key) {
    return AppLanguage.get(key);
  }

  Future<void> _showLanguageChooser(BuildContext context) async {
    final selectedCode = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_getTranslatedText('pilih_bahasa')),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: _languages.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value),
                  value: entry.key,
                  groupValue: _currentLanguageCode,
                  onChanged: (String? value) {
                    Navigator.pop(context, value);
                  },
                  activeColor: primaryPurple,
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    if (selectedCode != null && selectedCode != _currentLanguageCode) {
      await _saveLanguage(selectedCode);

      setState(() {
        _currentLanguageCode = selectedCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getTranslatedText('ganti_bahasa_snack')}${_languages[selectedCode]}'),
          duration: const Duration(seconds: 2),
          backgroundColor: primaryPurple,
        ),
      );

      // Kembali ke HomeScreen dan kirimkan sinyal reload
      Navigator.pop(context, true); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTranslatedText('pengaturan')),
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // ==========================================================
          // BAGIAN 1: UMUM
          // ==========================================================
          _buildHeader(_getTranslatedText('umum')),
          
          // Opsi 1: Mode Tampilan 
          ListTile(
            leading: const Icon(Icons.palette, color: primaryPurple),
            title: Text(_getTranslatedText('mode_tampilan')),
            subtitle: Text(
              _getTranslatedText('saat_ini') + ' ' + 
              (_isDarkMode ? _getTranslatedText('mode_gelap') : _getTranslatedText('mode_terang'))
            ),
            trailing: Switch(
              value: _isDarkMode, 
              onChanged: (bool value) async { 
                
                await _saveThemeSetting(value); 
                
                setState(() {
                  _isDarkMode = value;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      _getTranslatedText('mengubah_mode') + ' ' +
                      (value ? _getTranslatedText('mode_gelap_label') : _getTranslatedText('mode_terang_label'))
                    ),
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
                
                // Kembali ke HomeScreen dan kirimkan sinyal reload (true)
                Navigator.pop(context, true); 
              },
              activeColor: primaryPurple,
            ),
          ),
          const Divider(height: 1),

          // Opsi 2: Bahasa Aplikasi 
          ListTile(
            leading: const Icon(Icons.language, color: primaryPurple),
            title: Text(_getTranslatedText('bahasa_aplikasi')),
            subtitle: Text('${_getTranslatedText('saat_ini')} ${_languages[_currentLanguageCode]}'), 
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () => _showLanguageChooser(context), 
          ),
          const Divider(height: 1),

          // ==========================================================
          // BAGIAN 2: NOTIFIKASI
          // ==========================================================
          _buildHeader(_getTranslatedText('notifikasi')),

          // Opsi 3: Notifikasi Push
          ListTile(
            leading: const Icon(Icons.notifications_active, color: primaryPurple),
            title: Text(_getTranslatedText('notif_push')),
            subtitle: Text(_getTranslatedText('notif_subtitle')),
            trailing: Switch(
              value: _isPushNotificationEnabled, 
              onChanged: (bool value) {
                setState(() {
                  _isPushNotificationEnabled = value;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Status notifikasi diubah"
                    ),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              activeColor: primaryPurple,
            ),
          ),
          const Divider(height: 1),


          // ==========================================================
          // BAGIAN 3: PRIVASI & KEAMANAN
          // ==========================================================
          _buildHeader(_getTranslatedText('privasi_keamanan')),
          
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Text(
              'Tidak ada pengaturan privasi tambahan saat ini.',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const Divider(height: 1),


          // ==========================================================
          // BAGIAN 4: DATA & SINKRONISASI
          // ==========================================================
          _buildHeader(_getTranslatedText('data_sinkronisasi')),

          // Opsi 4: Perbarui Data Brand (Sinkronisasi)
          ListTile(
            leading: const Icon(Icons.refresh, color: primaryPurple),
            title: Text(_getTranslatedText('perbarui_data')),
            subtitle: Text(_getTranslatedText('sinkron_subtitle')),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_getTranslatedText('sinkron_snack')),
                  duration: const Duration(seconds: 2),
                  backgroundColor: primaryPurple,
                ),
              );
            },
          ),
          const Divider(height: 1),

        ],
      ),
    );
  }

  // Helper Widget untuk Header
  Widget _buildHeader(String title) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade100,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primaryPurple,
        ),
      ),
    );
  }
}