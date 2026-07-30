class Validation {
  static double? parseAmount(String input) {
    return double.tryParse(input.trim());
  }

  static bool isPositive(double amount) {
    return amount > 0;
  }

  static bool isValidAccountNumber(String accountNumber) {
    final clean = accountNumber.trim();
    if (clean.isEmpty) return false;
    final regex = RegExp(r'^\d+$');
    return regex.hasMatch(clean);
  }

  static bool isValidPin(String pin) {
    final clean = pin.trim();
    if (clean.isEmpty) return false;
    final regex = RegExp(r'^\d+$');
    return regex.hasMatch(clean);
  }
}
