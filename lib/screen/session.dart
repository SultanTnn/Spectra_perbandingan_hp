// File ini berfungsi sebagai "catatan" global
// untuk menyimpan role user yang sedang login.

class UserSession {
  // 'static' berarti variabel ini bisa diakses dari mana saja
  // tanpa harus membuat object UserSession baru.
  static String? role; 
}
