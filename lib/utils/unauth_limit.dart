// FILE: lib/utils/unauth_limit.dart

class UnauthComparisonLimit {
  // Batas maksimal 2 kali
  static const int maxAttempts = 2;
  static int attemptsUsed = 0;

  static bool checkAndIncrement() {
    if (attemptsUsed < maxAttempts) {
      attemptsUsed++;
      return true;
    }
    return false;
  }

  static void reset() {
    attemptsUsed = 0;
  }
}
