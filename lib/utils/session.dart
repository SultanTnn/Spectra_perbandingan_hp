import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  // Static variables untuk akses cepat di seluruh aplikasi
  static String? id;
  static String? username;
  static String? namaLengkap;
  static String? role;
  static String? profileImageUrl;
  
  // *** TAMBAHAN PENTING: Untuk memaksa UI reload gambar profil ***
  static int cacheKey = 0; 
  // -------------------------------------------------------------

  // Key untuk SharedPreferences (Private agar tidak salah ketik di tempat lain)
  static const String _kId = 'user_id';
  static const String _kUsername = 'user_username';
  static const String _kNamaLengkap = 'user_nama_lengkap';
  static const String _kRole = 'user_role';
  static const String _kProfileImageUrl = 'user_profile_image_url';
  // *** Kunci untuk cacheKey ***
  static const String _kCacheKey = 'user_cache_key'; 
  // -----------------------------

  // Getter praktis untuk mengecek status login
  static bool get isLoggedIn => id != null && id!.isNotEmpty;

  // Fungsi untuk memuat data dari memori HP ke variabel Static (Panggil di main.dart / Splash Screen)
  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    id = prefs.getString(_kId);
    username = prefs.getString(_kUsername);
    namaLengkap = prefs.getString(_kNamaLengkap);
    role = prefs.getString(_kRole);
    profileImageUrl = prefs.getString(_kProfileImageUrl);
    
    // *** Load cacheKey, defaultnya 0 jika belum ada ***
    cacheKey = prefs.getInt(_kCacheKey) ?? 0;

    // Debugging: Cek di console apakah data termuat
    print('--- Session Loaded ---');
    print('ID: $id');
    print('User: $username');
    print('Img: $profileImageUrl');
    print('Cache Key: $cacheKey');
  }

  // Fungsi untuk menyimpan perubahan variabel Static ke memori HP (Panggil setelah update profil)
  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Logika: Jika ada data, simpan. Jika null, hapus dari memori agar sinkron.
    if (id != null) {
      await prefs.setString(_kId, id!);
    } else {
      await prefs.remove(_kId);
    }

    if (username != null) {
      await prefs.setString(_kUsername, username!);
    } else {
      await prefs.remove(_kUsername);
    }

    if (namaLengkap != null) {
      await prefs.setString(_kNamaLengkap, namaLengkap!);
    } else {
      await prefs.remove(_kNamaLengkap);
    }

    if (role != null) {
      await prefs.setString(_kRole, role!);
    } else {
      await prefs.remove(_kRole);
    }

    if (profileImageUrl != null) {
      await prefs.setString(_kProfileImageUrl, profileImageUrl!);
    } else {
      await prefs.remove(_kProfileImageUrl);
    }
    
    // *** Simpan cacheKey ***
    await prefs.setInt(_kCacheKey, cacheKey); 

    print('--- Session Saved ---');
  }

  // Fungsi khusus saat Login agar lebih rapi (Opsional, tapi disarankan dipakai di LoginScreen)
  static Future<void> createSession({
    required String userId,
    required String userName,
    required String fullName,
    required String userRole,
    String? userProfileImage,
  }) async {
    id = userId;
    username = userName;
    namaLengkap = fullName;
    role = userRole;
    profileImageUrl = userProfileImage;
    // Saat login, cacheKey dipertahankan atau di-reset ke 0
    cacheKey = 0; // Mulai dari 0 saat sesi baru dibuat

    await saveData(); // Simpan ke storage
  }

  // Fungsi Logout (Hapus semua data)
  static Future<void> clearSession() async {
    // 1. Kosongkan variabel static
    id = null;
    username = null;
    namaLengkap = null;
    role = null;
    profileImageUrl = null;
    // *** Reset cacheKey ***
    cacheKey = 0; 

    // 2. Hapus dari memori HP
    final prefs = await SharedPreferences.getInstance();
    // Gunakan prefs.clear() karena Anda ingin menghapus semua data sesi
    await prefs.clear(); 

    print('--- Session Cleared (Logout) ---');
  }
}