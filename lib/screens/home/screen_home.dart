import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'home_widgets.dart';
import '../auth/login_screen.dart';
import '../../utils/session.dart';
import '../profile_screen.dart';
import '../../screens/home/settings/app_language.dart';
import '../home/settings/settings_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
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
  
  // --- BARU DITAMBAH: State untuk Sorting ---
  String _currentSortBy = 'alphabetical'; 

  // --- KONSTANTA WARNA DINAMIS BERDASARKAN TEMA ---
  Color _getPrimaryColor() =>
      _isDarkModeActive ? const Color(0xFF9370DB) : const Color(0xFF4B0082);
  Color _getAccentColor() =>
      _isDarkModeActive ? const Color(0xFF1E90FF) : const Color(0xFF6A5ACD);
  Color _getTextColor() => _isDarkModeActive ? Colors.white : Colors.white;
  Color _getSubTextColor() =>
      _isDarkModeActive ? Colors.white70 : Colors.white70;
  Color _getCardColor() =>
      _isDarkModeActive ? const Color(0xFF2C2C2C) : Colors.white;
  Color _getBrandTextColor() =>
      _isDarkModeActive ? Colors.white : const Color(0xFF333333);
  Color _getBrandSubTextColor() =>
      _isDarkModeActive ? Colors.grey.shade400 : const Color(0xFF888888);
  Color _getBackgroundColor() =>
      _isDarkModeActive ? const Color(0xFF121212) : _getPrimaryColor();
  Color _getErrorIconColor() => _getPrimaryColor().withOpacity(0.7);
  Color _getShimmerBaseColor() =>
      _isDarkModeActive ? Colors.grey.shade800 : Colors.grey.shade200;
  Color _getShimmerHighlightColor() =>
      _isDarkModeActive ? Colors.grey.shade700 : Colors.grey.shade100;

  static const String BASE_URL = 'http://192.168.0.2/api_hp';

  // Animasi Background Gradient
  late AnimationController _animationController;
  late Animation<AlignmentGeometry> _topAlignmentAnimation;
  late Animation<AlignmentGeometry> _bottomAlignmentAnimation;
  late Animation<Color?> _color1Animation;
  late Animation<Color?> _color2Animation;

  final List<List<Color>> _gradientColorPairs = [
    [
      const Color(0xFF4B0082).withOpacity(0.9),
      const Color(0xFF6A5ACD).withOpacity(0.9),
    ],
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
    _loadSettings().then((_) {
      _loadSessionData();
      // DIPERBAIKI: Panggil fetchBrands dengan sorting saat ini
      fetchBrands(sortBy: _currentSortBy); 
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
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..addListener(() {
            setState(() {});
          });

    _topAlignmentAnimation = TweenSequence<AlignmentGeometry>([
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.bottomLeft,
          end: Alignment.topLeft,
        ),
        weight: 1,
      ),
    ]).animate(_animationController);

    _bottomAlignmentAnimation = TweenSequence<AlignmentGeometry>([
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.bottomRight,
          end: Alignment.bottomLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.bottomLeft,
          end: Alignment.topLeft,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.topLeft,
          end: Alignment.topRight,
        ),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween<AlignmentGeometry>(
          begin: Alignment.topRight,
          end: Alignment.bottomRight,
        ),
        weight: 1,
      ),
    ]).animate(_animationController);

    _animationController.forward();
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
        _currentColorPairIndex =
            (_currentColorPairIndex + 1) % _gradientColorPairs.length;
        _animationController.reset();
        _animationController.forward();
      });
    });
    _animationController.forward();
  }

  // --- LOGIKA SESI & PROFILE ---
  Future<void> _loadSessionData() async {
    await UserSession.loadData();
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    setState(() {
      _sessionLoaded = true;
      if (_lastProfileImageUrl != UserSession.profileImageUrl) {
        _lastProfileImageUrl = UserSession.profileImageUrl;
        // Bersihkan query param lama jika ada
        if (_lastProfileImageUrl != null) {
          _lastProfileImageUrl = _lastProfileImageUrl!.split('?').first;
        }
        _profileImageCacheKey = DateTime.now().millisecondsSinceEpoch;
      }
    });
  }

  Future<void> _logout() async {
    await UserSession.clearSession();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _navigateToProfile() async {
    final scaffoldState = Scaffold.maybeOf(context);
    final drawerOpen = scaffoldState?.isDrawerOpen ?? false;

    if (drawerOpen) {
      Navigator.pop(context);
      await Future.delayed(const Duration(milliseconds: 250));
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );

    if (result is String) {
      setState(() {
        _lastProfileImageUrl = result;
        _profileImageCacheKey = DateTime.now().millisecondsSinceEpoch;
      });
    } else if (result == true || result == null) {
      await _loadSessionData();
    }
  }

  void _navigateToSettings() async {
    Navigator.pop(context);

    // DIPERBAIKI: Gunakan SettingsScreen dan ambil return value (true jika ada perubahan)
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()), 
    );

    if (result == true) {
      await _loadSettings();
      // Panggil fetchBrands dengan sorting saat ini agar data dimuat ulang dengan bahasa baru
      fetchBrands(sortBy: _currentSortBy); 
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

  // --- LOGIKA FETCH DATA & API ---
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
          searchResults = data
              .map((json) => Smartphone.fromJson(json))
              .toList();
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

  // DIPERBAIKI: Menerima parameter sorting
  Future<void> fetchBrands({String sortBy = 'alphabetical'}) async {
    // BARU: Tambahkan parameter sort ke URL
    final url = Uri.parse('$BASE_URL/get_brands.php?sort=$sortBy'); 
    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        if (!mounted) return;
        setState(() {
          brands = List<String>.from(data.map((b) => b.toString()));

          // Lakukan sorting A-Z di Flutter HANYA jika mode 'alphabetical'
          if (sortBy == 'alphabetical') {
             brands.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
          }
          
          loading = false;
          errorMessage = '';
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage =
              '${_getTranslatedText('gagal_merek')} Status: ${resp.statusCode}';
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

  // Helper untuk mendapatkan URL gambar dengan Cache Buster yang aman
  String? _getProfileImageUrl() {
    if (_lastProfileImageUrl == null ||
        _lastProfileImageUrl!.isEmpty ||
        !_sessionLoaded) {
      return null;
    }
    final separator = _lastProfileImageUrl!.contains('?') ? '&' : '?';
    return '$_lastProfileImageUrl$separator'
        'cb=$_profileImageCacheKey';
  }

  // --- BARU DITAMBAH: LOGIKA & WIDGET SORTING DI FRONT-END ---

  void _showSortOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _getCardColor(),
          title: Text(
            _getTranslatedText('urutkan_dengan'),
            style: TextStyle(color: _getBrandTextColor()),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Opsi 1: Alphabetical (A-Z)
              _buildSortOption(context, 'alphabetical', _getTranslatedText('semua_merk_az'), Icons.sort_by_alpha),
              
              // Opsi 2: Harga Tertinggi
              _buildSortOption(context, 'highest_price', _getTranslatedText('harga_tertinggi'), Icons.trending_up),
              
              // Opsi 3: Harga Terendah
              _buildSortOption(context, 'lowest_price', _getTranslatedText('harga_terendah'), Icons.trending_down),
              
              // Opsi 4: Rekomendasi Terbaik
              _buildSortOption(context, 'best_recommendation', _getTranslatedText('rekomendasi_terbaik'), Icons.star),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
      BuildContext context, String value, String title, IconData icon) {
    final bool isSelected = _currentSortBy == value;
    final Color dynamicPrimary = _getPrimaryColor();
    final Color dynamicTextColor = _getBrandTextColor();

    return ListTile(
      leading: Icon(icon, color: isSelected ? dynamicPrimary : dynamicTextColor.withOpacity(0.7)),
      title: Text(
        title,
        style: TextStyle(
          color: dynamicTextColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check, color: dynamicPrimary) : null,
      onTap: () {
        if (!isSelected) {
          setState(() {
            _currentSortBy = value;
            loading = true; // Aktifkan loading/shimmer
          });
          // Panggil API dengan sorting baru
          fetchBrands(sortBy: value); 
        }
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSortBar() {
    final Color dynamicPrimary = _getPrimaryColor();
    final Color dynamicTextColor = _getBrandTextColor();
    
    // Tentukan teks yang akan ditampilkan
    String getCurrentSortTitle() {
      switch (_currentSortBy) {
        case 'highest_price':
          return _getTranslatedText('harga_tertinggi');
        case 'lowest_price':
          return _getTranslatedText('harga_terendah');
        case 'best_recommendation':
          return _getTranslatedText('rekomendasi_terbaik');
        case 'alphabetical':
        default:
          return _getTranslatedText('semua_merk_az');
      }
    }

    // Tampilkan tombol drop-down sederhana untuk sorting
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${_getTranslatedText('urutkan_dengan')}: ',
            style: TextStyle(
              color: _getBrandSubTextColor(),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          InkWell(
            onTap: _showSortOptionsDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getCardColor(),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: dynamicPrimary.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  Text(
                    getCurrentSortTitle(),
                    style: TextStyle(
                      color: dynamicPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.arrow_drop_down, color: dynamicPrimary, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- BAGIAN BUILD (REVISI TATA LETAK) ---
  @override
  Widget build(BuildContext context) {
    final Color dynamicPrimary = _getPrimaryColor();
    final Color dynamicAccent = _getAccentColor();
    final Color dynamicCardColor = _getCardColor();

    final List<Color> currentGradientColors = _isDarkModeActive
        ? [dynamicPrimary, dynamicAccent]
        : _gradientColorPairs[_currentColorPairIndex];

    _color1Animation = ColorTween(
      begin: currentGradientColors[0],
      end: currentGradientColors[0],
    ).animate(_animationController);
    _color2Animation = ColorTween(
      begin: currentGradientColors[1],
      end: currentGradientColors[1],
    ).animate(_animationController);

    final widgets = HomeWidgets(
      context: context,
      brands: brands,
      searchResults: searchResults,
      query: query,
      isSearchingProducts: isSearchingProducts,
      dynamicPrimary: dynamicPrimary,
      dynamicAccent: dynamicAccent,
      dynamicCardColor: dynamicCardColor,
      brandTextColor: _getBrandTextColor(),
      brandSubTextColor: _getBrandSubTextColor(),
      errorIconColor: _getErrorIconColor(),
      shimmerBaseColor: _getShimmerBaseColor(),
      shimmerHighlightColor: _getShimmerHighlightColor(),
      searchController: searchController,
      getTranslatedText: _getTranslatedText,
      searchHints: _searchHints,
      currentHintIndex: _currentHintIndex,
      startHintTimer: _startHintTimer,
    );

    Widget contentList;
    final trimmedQuery = query.trim();
    
    // Tentukan apakah Sort Bar dan Konten List utama tampil
    final bool showBrandListContent = trimmedQuery.isEmpty && !loading && errorMessage.isEmpty;

    if (loading) {
      contentList = widgets.buildLoadingShimmer(
        count: 6,
        title: _getTranslatedText('loading_merek'),
      );
    } else if (errorMessage.isNotEmpty) {
      contentList = widgets.buildErrorView(
        errorMessage: errorMessage,
        onTryAgain: () {
          setState(() {
            loading = true;
            errorMessage = '';
          });
          fetchBrands(sortBy: _currentSortBy); // Panggil ulang dengan sort state saat ini
        },
      );
    } else if (trimmedQuery.isNotEmpty) {
      // Logika Search tetap sama
      // ... (Search implementation)
      if (isSearchingProducts) {
        contentList = widgets.buildLoadingShimmer(
          count: 3,
          title: '${_getTranslatedText('cari_button')}...',
        );
      } else if (searchResults.isNotEmpty) {
        contentList = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                '${_getTranslatedText('produk_ditemukan')}"$trimmedQuery" (${searchResults.length} ${_getTranslatedText('ditemukan')})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _getBrandTextColor(),
                ),
              ),
            ),
            ...searchResults
                .map((phone) => widgets.buildPhoneCard(phone))
                .toList(),
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
              ...matchingBrands.map((b) => widgets.buildBrandCard(b)).toList(),
            ],
          );
        } else {
          contentList = widgets.buildEmptySearchView(isProductSearch: true);
        }
      }
    } else {
      // Mode Tampil Merek (dengan Sorting)
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
            widgets.buildEmptySearchView(isProductSearch: false)
          else
            ...brands.map((b) => widgets.buildBrandCard(b)).toList(),
        ],
      );
    }
    
    // Tentukan header content yang akan ditampilkan di bagian bawah area gradient
    final headerContent = [
      // 1. Header (Area Gradient)
      Container(
        width: double.infinity,
        padding: const EdgeInsets.only(
          left: 24,
          right: 24,
          top: 50,
          bottom: 40, // Kurangi padding bawah agar konten utama naik
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getTranslatedText('bandingkan_semua'),
              style: GoogleFonts.montserrat(
                fontSize: 40,
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
                fontSize: 16,
                color: _getSubTextColor(),
                fontWeight: FontWeight.w400,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            widgets.buildSearchAndCompareBar(),
            const SizedBox(height: 20),
            Icon(
              Icons.keyboard_arrow_down,
              color: _getTextColor(),
              size: 30,
            ),
          ],
        ),
      ),
      
      // 2. Sorting Bar (Disisipkan di antara Header dan Konten Utama)
      if (showBrandListContent)
        _buildSortBar(),
    ];
    
    // Konten utama list (brand list / search results)
    final mainContent = Container(
      decoration: BoxDecoration(
        color: _isDarkModeActive ? dynamicCardColor : Colors.white,
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: contentList,
    );

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
          IconButton(
            icon: CircleAvatar(
              key: ValueKey(_profileImageCacheKey),
              radius: 15,
              backgroundColor: Colors.white24,
              backgroundImage: _getProfileImageUrl() != null
                  ? NetworkImage(_getProfileImageUrl()!)
                  : null,
              child: _getProfileImageUrl() == null
                  ? Icon(Icons.person, color: _getPrimaryColor(), size: 20)
                  : null,
            ),
            onPressed: _navigateToProfile,
          ),
          const SizedBox(width: 10),
        ],
      ),

      // --- DRAWER (Tetap Sama) ---
      drawer: Drawer(
        backgroundColor: _getCardColor(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              margin: EdgeInsets.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 15.0,
              ),
              decoration: BoxDecoration(
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
                    backgroundImage: _getProfileImageUrl() != null
                        ? NetworkImage(_getProfileImageUrl()!)
                        : null,
                    child: _getProfileImageUrl() == null
                        ? Icon(Icons.person, color: dynamicPrimary, size: 36)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    UserSession.namaLengkap ??
                        (_sessionLoaded
                            ? _getTranslatedText('selamat_datang')
                            : 'Memuat...'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    UserSession.username ?? _getTranslatedText('user_aktif'),
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            widgets.buildDrawerListTile(
              Icons.home,
              _getTranslatedText('beranda'),
              () => Navigator.pop(context),
            ),
            widgets.buildDrawerListTile(
              Icons.account_circle,
              _getTranslatedText('profile_saya'),
              _navigateToProfile,
            ),
            widgets.buildDrawerListTile(
              Icons.settings,
              _getTranslatedText('pengaturan'),
              _navigateToSettings,
            ),
            widgets.buildDrawerListTile(
              Icons.info_outline,
              _getTranslatedText('tentang_aplikasi'),
              () {
                Navigator.pop(context);
                _showAboutDialog();
              },
            ),
            Divider(
              height: 20,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: _getBrandSubTextColor(),
            ),
            widgets.buildDrawerListTile(
              Icons.logout,
              _getTranslatedText('log_out'),
              () => _logout(),
              isLogout: true,
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: _topAlignmentAnimation.value,
                    end: _bottomAlignmentAnimation.value,
                    colors: [
                      _isDarkModeActive
                          ? dynamicPrimary
                          : _color1Animation.value!,
                      _isDarkModeActive
                          ? dynamicAccent
                          : _color2Animation.value!,
                    ],
                  ),
                ),
              );
            },
          ),
          RefreshIndicator(
            color: dynamicPrimary,
            onRefresh: () => fetchBrands(sortBy: _currentSortBy),
            child: CustomScrollView(
              slivers: [
                // 1. Header dan Sort Bar
                SliverList(
                  delegate: SliverChildListDelegate(headerContent),
                ),
                
                // 2. Konten Utama (Daftar Merek/Hasil Pencarian)
                SliverToBoxAdapter(
                  child: mainContent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}