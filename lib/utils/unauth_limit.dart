class UnauthComparisonLimit {
  static int maxAttempts = 3;
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
