// lib/utils/unauth_limit.dart
// Class untuk melacak sisa percobaan perbandingan bagi pengguna yang belum login.

class UnauthComparisonLimit {
  static int maxAttempts = 3;
  // Perhatikan: Karena ini adalah variabel statis, nilainya akan reset
  // setiap kali aplikasi di-restart, yang bagus untuk tujuan demo.
  static int attemptsUsed = 0;

  static int get remainingAttempts => maxAttempts - attemptsUsed;

  static void useAttempt() {
    if (attemptsUsed < maxAttempts) {
      attemptsUsed++;
    }
  }

  static bool isLimitReached() {
    return attemptsUsed >= maxAttempts;
  }
}