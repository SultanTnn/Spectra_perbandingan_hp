import 'package:flutter/material.dart';
import 'dart:developer';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

// Import file lokal
import 'api_service.dart';
import 'smartphone.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'session.dart';

// --- KELAS BANTUAN UNTUK PENCARIAN ---
class SearchOption {
  final String label;
  final String type; // 'brand' atau 'phone'
  final dynamic data; // Bisa String (nama brand) atau Smartphone (objek hp)

  SearchOption({required this.label, required this.type, required this.data});

  @override
  String toString() => label;
}
// -------------------------------------

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

  String? _selectedBrandName;
  List<Smartphone> _phoneList = [];
  final List<Smartphone> _listUntukDibandingkan = [];

  // State UI
  bool _tampilkanHasilPerbandingan = false;
  bool _isBrandLoading = false;
  bool _isPhoneLoading = false;
  bool _isSearchIndexReady = false;
  String? _errorMessage;

  // State Mode Gelap
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
      _isBrandLoading = true;
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
        if (mounted)
          setState(
            () => _errorMessage =
                "Gagal load brands: HTTP ${response.statusCode}",
          );
      }
    } catch (e) {
      log("Error Brands: $e");
      if (mounted)
        setState(() => _errorMessage = "Gagal Koneksi: Pastikan Server Nyala");
    } finally {
      if (mounted) setState(() => _isBrandLoading = false);
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
          _isSearchIndexReady = true;
        });
      }
    } catch (e) {
      log("Search Index Error: $e");
    }
  }

  Future<void> _fetchPhonesFromAPI(String brand) async {
    setState(() {
      _isPhoneLoading = true;
      _selectedBrandName = brand;
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
      if (mounted)
        setState(() => _errorMessage = "Koneksi Gagal: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _isPhoneLoading = false);
    }
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme);
    final glassColor = _isDarkMode
        ? Colors.black.withOpacity(0.4)
        : Colors.white.withOpacity(0.2);
    final borderColor = _isDarkMode
        ? Colors.white.withOpacity(0.1)
        : Colors.white.withOpacity(0.3);

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

          // --- HEADER KIRI (LOGO & NAMA) ---
          // Diperlebar agar teks "SPECTRA" tidak terpotong
          leadingWidth: 220,
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 24.0,
            ), // Padding kiri sedikit ditambah
            child: Row(
              children: [
                // ICON HP
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: glassColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor),
                  ),
                  // GANTI PETIR JADI HP
                  child: const Icon(
                    Icons.smartphone_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                // TEKS SPECTRA
                Expanded(
                  child: Text(
                    'SPECTRA',
                    style: GoogleFonts.fredoka(
                      color: Colors.white,
                      fontSize: 22, // Ukuran font disesuaikan agar pas
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // --- HEADER TENGAH (MENU SERAGAM) ---
          title: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 1. MENU MERK (Dropdown)
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
                        offset: const Offset(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        onSelected: (String brand) {
                          setState(() {
                            _selectedBrandName = brand;
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
                                  color: _isDarkMode
                                      ? Colors.white
                                      : Colors.grey[800],
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

                    const SizedBox(width: 8),

                    // 2. TIM DEV
                    _buildTooltipMenuButton(
                      label: "Tim Dev",
                      icon: Icons.group_rounded,
                      message:
                          "1. Sultan\n2. Anggota 2\n3. Anggota 3\n4. Anggota 4\n5. Anggota 5",
                      glassColor: glassColor,
                      borderColor: borderColor,
                    ),

                    const SizedBox(width: 8),

                    // 3. TENTANG
                    _buildTooltipMenuButton(
                      label: "Tentang",
                      icon: Icons.info_outline_rounded,
                      message:
                          "Aplikasi perbandingan spesifikasi smartphone.\n© 2025 Kelompok 3",
                      glassColor: glassColor,
                      borderColor: borderColor,
                    ),

                    const SizedBox(width: 8),

                    // 4. VERSI
                    _buildTooltipMenuButton(
                      label: "Versi",
                      icon: Icons.verified_rounded,
                      message: "Versi Aplikasi: v1.0.0+1",
                      glassColor: glassColor,
                      borderColor: borderColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // --- HEADER KANAN (MODE GELAP + LOGIN) ---
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 24.0),
              child: Row(
                children: [
                  // TOMBOL MODE GELAP
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _isDarkMode = !_isDarkMode;
                      });
                    },
                    tooltip: _isDarkMode ? "Mode Terang" : "Mode Gelap",
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) =>
                          RotationTransition(turns: anim, child: child),
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
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Daftar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  if (_isLoggedIn)
                    IconButton(
                      icon: const Icon(
                        Icons.logout_rounded,
                        color: Colors.white,
                      ),
                      tooltip: "Keluar",
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

        // --- BODY UTAMA ---
        body: AnimatedGradientBackground(
          isDarkMode: _isDarkMode,
          child: SafeArea(
            child: Column(
              children: [
                // CONTAINER TENGAH (PENCARIAN)
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 30,
                  ),
                  decoration: BoxDecoration(
                    color: _isDarkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      color: _isDarkMode
                          ? Colors.white.withOpacity(0.1)
                          : Colors.white.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Ikon Animasi (HP)
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 1.0, end: 1.1),
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        builder: (context, double scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.6),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.smartphone_rounded,
                            color: Colors.orange,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Judul SPECTRA
                      Text(
                        'SPECTRA',
                        style: GoogleFonts.fredoka(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Bandingkan spesifikasi ribuan handphone dengan mudah.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // --- SMART SEARCH (AUTOCOMPLETE) ---
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return Autocomplete<SearchOption>(
                            optionsBuilder:
                                (TextEditingValue textEditingValue) {
                                  if (textEditingValue.text == '')
                                    return const Iterable<SearchOption>.empty();
                                  return _searchOptions.where((
                                    SearchOption option,
                                  ) {
                                    return option.label.toLowerCase().contains(
                                      textEditingValue.text.toLowerCase(),
                                    );
                                  });
                                },
                            displayStringForOption: (SearchOption option) =>
                                option.label,
                            onSelected: (SearchOption selection) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              if (selection.type == 'brand') {
                                _fetchPhonesFromAPI(selection.data as String);
                              } else if (selection.type == 'phone') {
                                final phone = selection.data as Smartphone;
                                setState(() {
                                  _selectedBrandName = phone.brand;
                                  _phoneList = [phone];
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
                                  textEditingController,
                                  focusNode,
                                  onFieldSubmitted,
                                ) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isDarkMode
                                          ? const Color(0xFF2C2C3E)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(50),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.search_rounded,
                                          color: _isDarkMode
                                              ? Colors.white70
                                              : const Color(0xFF6C63FF),
                                          size: 26,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: TextField(
                                            controller: textEditingController,
                                            focusNode: focusNode,
                                            style: TextStyle(
                                              color: _isDarkMode
                                                  ? Colors.white
                                                  : const Color(0xFF553C9A),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: _isSearchIndexReady
                                                  ? "Ketik Merk / Model HP..."
                                                  : "Memuat data...",
                                              hintStyle: TextStyle(
                                                color: _isDarkMode
                                                    ? Colors.white38
                                                    : Colors.grey[400],
                                                fontWeight: FontWeight.normal,
                                              ),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        if (_isBrandLoading)
                                          const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Align(
                                alignment: Alignment.topLeft,
                                child: Material(
                                  elevation: 8.0,
                                  borderRadius: BorderRadius.circular(20),
                                  color: _isDarkMode
                                      ? const Color(0xFF2C2C3E)
                                      : Colors.white,
                                  child: Container(
                                    width: constraints.maxWidth,
                                    constraints: const BoxConstraints(
                                      maxHeight: 320,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: _isDarkMode
                                          ? const Color(0xFF2C2C3E)
                                          : Colors.white,
                                    ),
                                    child: ListView.separated(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      itemCount: options.length,
                                      separatorBuilder: (ctx, i) => Divider(
                                        height: 1,
                                        color: _isDarkMode
                                            ? Colors.white10
                                            : Colors.grey[100],
                                      ),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                            final SearchOption option = options
                                                .elementAt(index);
                                            return ListTile(
                                              leading: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: option.type == 'brand'
                                                      ? (_isDarkMode
                                                            ? Colors.blue
                                                                  .withOpacity(
                                                                    0.2,
                                                                  )
                                                            : Colors.blue[50])
                                                      : (_isDarkMode
                                                            ? Colors.orange
                                                                  .withOpacity(
                                                                    0.2,
                                                                  )
                                                            : Colors
                                                                  .orange[50]),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: Icon(
                                                  option.type == 'brand'
                                                      ? Icons.business_rounded
                                                      : Icons
                                                            .smartphone_rounded,
                                                  color: option.type == 'brand'
                                                      ? Colors.blue
                                                      : Colors.orange,
                                                  size: 20,
                                                ),
                                              ),
                                              title: Text(
                                                option.label,
                                                style: TextStyle(
                                                  color: _isDarkMode
                                                      ? Colors.white
                                                      : Colors.grey[800],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                option.type == 'phone'
                                                    ? "Model HP"
                                                    : "Merk",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: _isDarkMode
                                                      ? Colors.white54
                                                      : Colors.grey[500],
                                                ),
                                              ),
                                              onTap: () => onSelected(option),
                                            );
                                          },
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

                // Content Area (List HP)
                Expanded(
                  child: Container(
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
                      child: _buildBodyContent(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  // --- WIDGET HELPER AGAR UKURAN TOMBOL SERAGAM ---

  Widget _buildTooltipMenuButton({
    required String label,
    required IconData icon,
    required String message,
    required Color glassColor,
    required Color borderColor,
  }) {
    return Tooltip(
      message: message,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade900.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        height: 1.4,
      ),
      triggerMode: TooltipTriggerMode.tap,
      child: _buildGlassMenuButton(
        label: label,
        icon: icon,
        isDropdown: false,
        glassColor: glassColor,
        borderColor: borderColor,
      ),
    );
  }

  // WIDGET TOMBOL MENU (SERAGAM)
  Widget _buildGlassMenuButton({
    required String label,
    required IconData icon,
    required bool isDropdown,
    required Color glassColor,
    required Color borderColor,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Material(
        color: glassColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  isDropdown
                      ? Icons.keyboard_arrow_down_rounded
                      : Icons.keyboard_arrow_up_rounded,
                  color: Colors.white70,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- SISA WIDGET (FAB, CONTENT, DLL) ---

  Widget? _buildFloatingActionButton() {
    if (_tampilkanHasilPerbandingan) {
      return FloatingActionButton.extended(
        onPressed: () => setState(() {
          _tampilkanHasilPerbandingan = false;
          _listUntukDibandingkan.clear();
          _phoneList.clear();
          _selectedBrandName = null;
          _fetchBrandsFromAPI();
        }),
        label: const Text("Reset"),
        icon: const Icon(Icons.refresh_rounded),
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      );
    } else if (_listUntukDibandingkan.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton.extended(
          onPressed: _tampilkanDialogPerbandingan,
          label: Text(
            'Bandingkan (${_listUntukDibandingkan.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          icon: const Icon(Icons.compare_arrows_rounded),
          backgroundColor: const Color(0xFF6C63FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 5,
        ),
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

  Widget _buildKontenKosong() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: _isDarkMode ? Colors.white10 : Colors.blue[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.touch_app_rounded,
            size: 60,
            color: _isDarkMode
                ? Colors.white54
                : const Color(0xFF0175C2).withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "Siap Membandingkan?",
          style: GoogleFonts.fredoka(
            fontSize: 22,
            color: _isDarkMode ? Colors.white : const Color(0xFF553C9A),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            "Pilih dari menu atau cari langsung di atas!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _isDarkMode ? Colors.grey[400] : Colors.grey,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 250,
          childAspectRatio: 0.7,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: _isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
          highlightColor: _isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHasilPencarian() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
          child: Row(
            children: [
              Text(
                '$_selectedBrandName',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: _isDarkMode ? Colors.white : const Color(0xFF553C9A),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      (_isDarkMode
                              ? Colors.blueAccent
                              : const Color(0xFF0175C2))
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  '${_phoneList.length} Unit',
                  style: TextStyle(
                    color: _isDarkMode
                        ? Colors.blueAccent
                        : const Color(0xFF0175C2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              childAspectRatio: 0.68,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
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
    );
  }

  Widget _buildPhoneCard(Smartphone phone, bool isSelected) {
    final cardColor = _isDarkMode ? const Color(0xFF2C2C3E) : Colors.white;
    final borderColor = _isDarkMode ? Colors.grey[700]! : Colors.grey.shade100;
    final textColor = _isDarkMode ? Colors.white : Colors.grey[800];

    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(25),
          border: isSelected
              ? Border.all(color: const Color(0xFF6C63FF), width: 3)
              : Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF6C63FF).withOpacity(0.3)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 15 : 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.black26 : Colors.grey[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: phone.imageUrl.isNotEmpty
                    ? Hero(
                        tag: 'phone_${phone.id}_${phone.namaModel}',
                        child: Image.network(
                          phone.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (ctx, err, _) => Icon(
                            Icons.image_not_supported_rounded,
                            color: Colors.grey[300],
                          ),
                        ),
                      )
                    : Icon(
                        Icons.phone_android_rounded,
                        size: 50,
                        color: Colors.grey[300],
                      ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phone.namaModel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        phone.price.isNotEmpty ? phone.price : "Harga N/A",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (!isSelected) {
                      if (!_isLoggedIn && _listUntukDibandingkan.length >= 3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Login untuk membandingkan lebih banyak!",
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      if (_listUntukDibandingkan.length >= 3) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Maksimal 3 HP"),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      _listUntukDibandingkan.add(phone);
                    } else {
                      _listUntukDibandingkan.remove(phone);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : (_isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Center(
                    child: Text(
                      isSelected ? "Terpilih" : "Pilih",
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (_isDarkMode ? Colors.white60 : Colors.grey[600]),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        Expanded(
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
    final bgColor = _isDarkMode ? const Color(0xFF2C2C3E) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF553C9A);

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 16, bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: _isDarkMode ? Colors.grey[800]! : Colors.grey[100]!,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 140,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isDarkMode ? Colors.black26 : Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
              ),
              child: phone.imageUrl.isNotEmpty
                  ? Image.network(phone.imageUrl, fit: BoxFit.contain)
                  : const Icon(
                      Icons.phone_android_rounded,
                      size: 50,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(height: 15),
            Text(
              phone.namaModel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildSpecPill("Harga", phone.price, Colors.green),
            _buildSpecPill(
              "Layar",
              _parseSpec(phone.display, "Type:"),
              Colors.blue,
            ),
            _buildSpecPill(
              "Chipset",
              _parseSpec(phone.platform, "Chipset:"),
              Colors.orange,
            ),
            _buildSpecPill(
              "Memori",
              _parseSpec(phone.memory, "Internal:"),
              Colors.purple,
            ),
            _buildSpecPill(
              "Kamera",
              _parseSpec(phone.mainCamera, "Triple:") ?? "Lihat detail",
              Colors.pink,
            ),
            _buildSpecPill(
              "Baterai",
              _parseSpec(phone.battery, "Type:"),
              Colors.teal,
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
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
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

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: Colors.red[400], size: 50),
            const SizedBox(height: 16),
            Text(
              'Ups, ada masalah!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.red[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchBrandsFromAPI,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }

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

  void _tampilkanDialogPerbandingan() {
    setState(() {
      _tampilkanHasilPerbandingan = true;
    });
  }
}

// --- ANIMATED BACKGROUND ---
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final bool isDarkMode; // Terima status Dark Mode
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
    // Warna Light Mode
    const lightColors = [
      Color(0xFF553C9A),
      Color(0xFF6C63FF),
      Color(0xFF0175C2),
    ];
    // Warna Dark Mode (Lebih Gelap/Deep)
    const darkColors = [
      Color(0xFF1A103C),
      Color(0xFF2D1B4E),
      Color(0xFF003366),
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _topAlignmentAnimation.value,
              end: _bottomAlignmentAnimation.value,
              colors: widget.isDarkMode ? darkColors : lightColors,
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
