import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ======================================================================
// 1. CLASS UNTUK LOGIKA LOKALISASI DAN KEYS (AppLanguage)
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
      'error_koneksi':
          'Terjadi kesalahan koneksi API brand. Pastikan BASE_URL benar:',
      'coba_lagi': 'Coba lagi',
      'produk_ditemukan': 'Hasil Produk untuk "',
      'ditemukan': ' ditemukan)',
      'brand_detail_ketuk': 'Lihat semua produk & bandingkan',
      'input_kosong_snack':
          'Masukkan nama brand atau produk untuk membandingkan!',
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
      'error_koneksi':
          'API connection error for brands. Make sure BASE_URL is correct:',
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
      'error_koneksi':
          'Ralat sambungan API untuk jenama. Pastikan BASE_URL betul:',
      'coba_lagi': 'Cuba Lagi',
      'produk_ditemukan': 'Keputusan Produk untuk "',
      'ditemukan': ' dijumpai)',
      'brand_detail_ketuk': 'Lihat semua produk & bandingkan',
      'input_kosong_snack':
          'Masukkan nama jenama atau produk untuk membandingkan!',
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
    },
  };

  static String currentLanguageCode = 'id';

  static String get(String key) {
    return _localizedValues[currentLanguageCode]?[key] ??
        _localizedValues['id']![key] ??
        key;
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
          content: Text(
            '${_getTranslatedText('ganti_bahasa_snack')}${_languages[selectedCode]}',
          ),
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
              _getTranslatedText('saat_ini') +
                  ' ' +
                  (_isDarkMode
                      ? _getTranslatedText('mode_gelap')
                      : _getTranslatedText('mode_terang')),
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
                      _getTranslatedText('mengubah_mode') +
                          ' ' +
                          (value
                              ? _getTranslatedText('mode_gelap_label')
                              : _getTranslatedText('mode_terang_label')),
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
            subtitle: Text(
              '${_getTranslatedText('saat_ini')} ${_languages[_currentLanguageCode]}',
            ),
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () => _showLanguageChooser(context),
          ),
          const Divider(height: 1),

          // ==========================================================
          // BAGIAN 2: NOTIFIKASI
          // ==========================================================
          _buildHeader(_getTranslatedText('notifikasi')),

          // Opsi 3: Notifikasi Push
          ListTile(
            leading: const Icon(
              Icons.notifications_active,
              color: primaryPurple,
            ),
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
                    content: Text("Status notifikasi diubah"),
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
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
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