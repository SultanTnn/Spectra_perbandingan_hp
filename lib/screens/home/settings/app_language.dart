import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  static const String keyLanguageCode = 'app_language_code';
  static const String keyDarkMode = 'is_dark_mode';
  static ValueNotifier<String> languageNotifier = ValueNotifier('id');

  static final Map<String, Map<String, String>> _localizedValues = {
    'id': {
      'beranda': 'Beranda',
      'profile_saya': 'Profile Saya',
      'pengaturan': 'Pengaturan',
      'tentang_aplikasi': 'Tentang Aplikasi',
      'font_size': 'Ukuran Font', // Ditambahkan
      'storage_cache': 'Penyimpanan / Hapus Cache', // Ditambahkan
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
      'urutkan_dengan': 'Urutkan dengan',
      'semua_merk_az': 'Semua Merk (A-Z)',
      'harga_tertinggi': 'Harga Tertinggi',
      'harga_terendah': 'Harga Terendah',
      'rekomendasi_terbaik': 'Rekomendasi Terbaik',
      'penyimpanan_judul': 'Penyimpanan & Cache',
      'total_cache': 'Total Sampah Cache',
      'hapus_cache': 'Bersihkan Cache',
      'menghitung': 'Menghitung...',
      'bersihkan_konfirmasi': 'Bersihkan Sekarang',
      'cache_dibersihkan': 'Cache berhasil dibersihkan!',
      'rincian_cache': 'Rincian Penyimpanan',
      'gambar_cache': 'Cache Gambar',
      'data_sementara': 'Data Sementara',
      'versi': 'Versi',
      'dibuat_oleh': 'Dikembangkan oleh',
      'deskripsi_singkat':
          'SPECTRA adalah aplikasi perbandingan spesifikasi smartphone terlengkap untuk membantu Anda menemukan gadget impian.',
      'riwayat_pembaruan': 'Riwayat Pembaruan',
      'hak_cipta': 'Hak Cipta',
      'ukuran_font': 'Ukuran Font',
      'pratinjau': 'Pratinjau Tampilan',
      'contoh_judul': 'Judul Artikel',
      'contoh_teks':
          'Ini adalah contoh bagaimana teks akan terlihat pada perangkat Anda. Sesuaikan slider di bawah untuk kenyamanan membaca.',
      'kecil': 'Kecil',
      'besar': 'Besar',
      'reset': 'Reset',
      'jenis_font': 'Jenis Font',
      'pilih_gaya': 'Pilih Gaya Huruf',
      'font_standar': 'Standar',
    },
    'en': {
      'beranda': 'Home',
      'profile_saya': 'My Profile',
      'pengaturan': 'Settings',
      'tentang_aplikasi': 'About App',
      'font_size': 'Font Size', // Ditambahkan
      'storage_cache': 'Storage / Clear Cache', // Ditambahkan
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
      'urutkan_dengan': 'Sort by',
      'semua_merk_az': 'All Brands (A-Z)',
      'harga_tertinggi': 'Highest Price',
      'harga_terendah': 'Lowest Price',
      'rekomendasi_terbaik': 'Best Recommendation',
      'penyimpanan_judul': 'Storage & Cache',
      'total_cache': 'Total Cache Junk',
      'hapus_cache': 'Clear Cache',
      'menghitung': 'Calculating...',
      'bersihkan_konfirmasi': 'Clean Now',
      'cache_dibersihkan': 'Cache cleared successfully!',
      'rincian_cache': 'Storage Details',
      'gambar_cache': 'Image Cache',
      'data_sementara': 'Temporary Data',
      'versi': 'Version',
      'dibuat_oleh': 'Developed by',
      'deskripsi_singkat':
          'SPECTRA is the most complete smartphone specification comparison app to help you find your dream gadget.',
      'riwayat_pembaruan': 'Changelog History',
      'hak_cipta': 'Copyright',
      'ukuran_font': 'Font Size',
      'pratinjau': 'Display Preview',
      'contoh_judul': 'Article Headline',
      'contoh_teks':
          'This is an example of how text will appear on your device. Adjust the slider below for reading comfort.',
      'kecil': 'Small',
      'besar': 'Large',
      'reset': 'Reset',
      'jenis_font': 'Font Family',
      'pilih_gaya': 'Choose Typeface',
      'font_standar': 'Default',
    },
    'ms': {
      'beranda': 'Laman Utama',
      'profile_saya': 'Profil Saya',
      'pengaturan': 'Tetapan',
      'tentang_aplikasi': 'Mengenai Aplikasi',
      'font_size': 'Saiz Fon', // Ditambahkan
      'storage_cache': 'Penyimpanan / Kosongkan Cache', // Ditambahkan
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
      'urutkan_dengan': 'Disusun mengikut',
      'semua_merk_az': 'Semua Jenama (A-Z)',
      'harga_tertinggi': 'Harga Tertinggi',
      'harga_terendah': 'Harga Terendah',
      'rekomendasi_terbaik': 'Cadangan Terbaik',
      'penyimpanan_judul': 'Penyimpanan & Cache',
      'total_cache': 'Jumlah Cache',
      'hapus_cache': 'Bersihkan Cache',
      'menghitung': 'Mengira...',
      'bersihkan_konfirmasi': 'Bersihkan Sekarang',
      'cache_dibersihkan': 'Cache berjaya dibersihkan!',
      'rincian_cache': 'Butiran Penyimpanan',
      'gambar_cache': 'Cache Imej',
      'data_sementara': 'Data Sementara',
      'versi': 'Versi',
      'dibuat_oleh': 'Dibangunkan oleh',
      'deskripsi_singkat':
          'SPECTRA adalah aplikasi perbandingan spesifikasi telefon pintar terlengkap untuk membantu anda mencari gajet impian.',
      'riwayat_pembaruan': 'Sejarah Kemaskini',
      'hak_cipta': 'Hak Cipta',
      'ukuran_font': 'Saiz Fon',
      'pratinjau': 'Pratonton Paparan',
      'contoh_judul': 'Tajuk Artikel',
      'contoh_teks':
          'Ini adalah contoh bagaimana teks akan kelihatan pada peranti anda. Laraskan gelangsar di bawah untuk keselesaan membaca.',
      'kecil': 'Kecil',
      'besar': 'Besar',
      'reset': 'Set Semula',
      'jenis_font': 'Jenis Fon',
      'pilih_gaya': 'Pilih Gaya Huruf',
      'font_standar': 'Lalai',
    },
  };

  // Getter untuk mengambil text
  static String get(String key) {
    return _localizedValues[languageNotifier.value]?[key] ??
        _localizedValues['id']![key] ??
        key;
  }

  // Fungsi untuk memuat bahasa yang tersimpan saat aplikasi mulai
  static Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedLang = prefs.getString(keyLanguageCode);
    if (savedLang != null && _localizedValues.containsKey(savedLang)) {
      languageNotifier.value = savedLang;
    }
  }

  // Fungsi untuk mengganti bahasa dan menyimpannya
  static Future<void> changeLanguage(String languageCode) async {
    if (_localizedValues.containsKey(languageCode)) {
      languageNotifier.value = languageCode;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyLanguageCode, languageCode);
    }
  }
}
