// session.dart (Ganti semua isinya)

import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? id;
  static String? username;
  static String? namaLengkap;
  static String? role;
  static String? profileImageUrl;

  // Preference keys
  static const String _kId = 'user_id';
  static const String _kUsername = 'user_username';
  static const String _kNamaLengkap = 'user_nama_lengkap';
  static const String _kRole = 'user_role';
  static const String _kProfileImageUrl = 'user_profile_image_url';

  // Fungsi untuk membersihkan session saat logout
  static Future<void> clearSession() async {
    id = null;
    username = null;
    namaLengkap = null;
    profileImageUrl = null;
    role = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kId);
    await prefs.remove(_kUsername);
    await prefs.remove(_kNamaLengkap);
    await prefs.remove(_kRole);
    await prefs.remove(_kProfileImageUrl);
  }

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    id = prefs.getString(_kId);
    username = prefs.getString(_kUsername);
    namaLengkap = prefs.getString(_kNamaLengkap);
    role = prefs.getString(_kRole);
    profileImageUrl = prefs.getString(_kProfileImageUrl);
  }

  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    if (id != null) await prefs.setString(_kId, id!);
    if (username != null) await prefs.setString(_kUsername, username!);
    if (namaLengkap != null) await prefs.setString(_kNamaLengkap, namaLengkap!);
    if (role != null) await prefs.setString(_kRole, role!);
    if (profileImageUrl != null) await prefs.setString(_kProfileImageUrl, profileImageUrl!);
  }
}