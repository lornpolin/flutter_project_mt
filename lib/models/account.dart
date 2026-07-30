import 'user.dart';
import 'transaction.dart';

class Account {
  final User owner;
  double _balance;
  final List<Transaction> _transactionHistory = [];

  Account(this.owner, this._balance);

  String get accountNumber => owner.accountNumber;
  String get cardHolderName => owner.name;
  double get balance => _balance;

  List<Transaction> get transactionHistory => List.unmodifiable(_transactionHistory);

  bool verifyPin(String inputPin) => owner.pin == inputPin;

  bool deposit(double amount) {
    if (amount <= 0) return false;
    _balance += amount;
    _transactionHistory.add(Transaction(
      type: TransactionType.deposit,
      amount: amount,
      balanceAfter: _balance,
    ));
    return true;
  }

  bool withdraw(double amount) {
    if (amount <= 0 || amount > _balance) return false;
    _balance -= amount;
    _transactionHistory.add(Transaction(
      type: TransactionType.withdrawal,
      amount: amount,
      balanceAfter: _balance,
    ));
    return true;
  }

  bool transferTo(Account targetAccount, double amount) {
    if (amount <= 0 || amount > _balance) return false;

    _balance -= amount;
    targetAccount._balance += amount;

    _transactionHistory.add(Transaction(
      type: TransactionType.transferOut,
      amount: amount,
      balanceAfter: _balance,
      details: 'To Account: ${targetAccount.accountNumber} (${targetAccount.cardHolderName})',
    ));

    targetAccount._transactionHistory.add(Transaction(
      type: TransactionType.transferIn,
      amount: amount,
      balanceAfter: targetAccount._balance,
      details: 'From Account: $accountNumber ($cardHolderName)',
    ));

    return true;
  }
}
