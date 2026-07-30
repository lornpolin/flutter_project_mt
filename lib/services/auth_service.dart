import '../models/account.dart';
import 'account_service.dart';

class AuthService {
  final AccountService _accountService;
  int _loginAttempts = 0;
  static const int maxAttempts = 3;

  AuthService(this._accountService);

  Account? authenticate(String accountNumber, String pin) {
    if (isLocked) return null;

    final account = _accountService.getAccount(accountNumber);
    if (account != null && account.verifyPin(pin)) {
      _loginAttempts = 0; // reset attempts on success
      return account;
    }

    _loginAttempts++;
    return null;
  }

  bool get isLocked => _loginAttempts >= maxAttempts;
  int get loginAttempts => _loginAttempts;
  int get attemptsRemaining => maxAttempts - _loginAttempts;

  void resetAttempts() {
    _loginAttempts = 0;
  }
}
