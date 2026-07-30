import '../models/account.dart';

class AccountService {
  final Map<String, Account> _accounts = {};

  void addAccount(Account account) {
    _accounts[account.accountNumber] = account;
  }

  Account? getAccount(String accountNumber) {
    return _accounts[accountNumber];
  }

  bool exists(String accountNumber) => _accounts.containsKey(accountNumber);

  bool deposit(Account account, double amount) {
    return account.deposit(amount);
  }

  bool withdraw(Account account, double amount) {
    return account.withdraw(amount);
  }

  bool transfer(Account sender, String destNumber, double amount) {
    final dest = getAccount(destNumber);
    if (dest == null) return false;
    return sender.transferTo(dest, amount);
  }
}
