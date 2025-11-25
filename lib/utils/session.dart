// session.dart (Ganti semua isinya)

class UserSession {
  static String? id;
  static String? username;
  static String? namaLengkap;
  static String? role;
  static String? profileImageUrl; // <-- Tambahan baru

  // Fungsi untuk membersihkan session saat logout
  static void clearSession() {
    id = null;
    username = null;
    namaLengkap = null;
    profileImageUrl = null; // <-- Tambahan baru
    role = null;
  }
}