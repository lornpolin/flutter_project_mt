import 'package:test/test.dart';
import 'package:bank_simulation/models/user.dart';
import 'package:bank_simulation/models/account.dart';
import 'package:bank_simulation/models/transaction.dart';
import 'package:bank_simulation/services/account_service.dart';
import 'package:bank_simulation/services/auth_service.dart';
import 'package:bank_simulation/utils/validation.dart';

void main() {
  group('Models Encapsulation Tests', () {
    late User aliceUser;
    late Account aliceAccount;

    setUp(() {
      aliceUser = User(accountNumber: '123456', pin: '1111', name: 'Alice Smith');
      aliceAccount = Account(aliceUser, 1000.0);
    });

    test('Initial values are set correctly', () {
      expect(aliceAccount.accountNumber, equals('123456'));
      expect(aliceAccount.cardHolderName, equals('Alice Smith'));
      expect(aliceAccount.balance, equals(1000.0));
      expect(aliceAccount.transactionHistory, isEmpty);
    });

    test('Verify PIN validation method', () {
      expect(aliceAccount.verifyPin('1111'), isTrue);
      expect(aliceAccount.verifyPin('1234'), isFalse);
    });

    test('Transaction history is unmodifiable from outside', () {
      final history = aliceAccount.transactionHistory;
      expect(() => history.add(Transaction(type: TransactionType.deposit, amount: 100, balanceAfter: 1100)), throwsUnsupportedError);
    });
  });

  group('Services Operation Tests', () {
    late AccountService accountService;
    late AuthService authService;
    late Account alice;
    late Account bob;

    setUp(() {
      accountService = AccountService();
      authService = AuthService(accountService);
      
      alice = Account(User(accountNumber: '123456', pin: '1111', name: 'Alice Smith'), 1000.0);
      bob = Account(User(accountNumber: '654321', pin: '2222', name: 'Bob Jones'), 500.0);
      
      accountService.addAccount(alice);
      accountService.addAccount(bob);
    });

    test('Authentication logic', () {
      expect(authService.authenticate('123456', '1111'), equals(alice));
      expect(authService.isLocked, isFalse);

      authService.resetAttempts();
      expect(authService.authenticate('123456', 'wrong'), isNull);
      expect(authService.loginAttempts, equals(1));
    });

    test('Lockout logic after 3 failures', () {
      authService.resetAttempts();
      expect(authService.authenticate('123456', 'wrong1'), isNull);
      expect(authService.authenticate('123456', 'wrong2'), isNull);
      expect(authService.authenticate('123456', 'wrong3'), isNull);
      expect(authService.isLocked, isTrue);

      expect(authService.authenticate('123456', '1111'), isNull);
    });

    test('Deposit logic and boundaries', () {
      expect(accountService.deposit(alice, -50.0), isFalse);
      expect(accountService.deposit(alice, 0.0), isFalse);
      expect(alice.balance, equals(1000.0));

      expect(accountService.deposit(alice, 200.0), isTrue);
      expect(alice.balance, equals(1200.0));
      expect(alice.transactionHistory.length, equals(1));
      expect(alice.transactionHistory.first.type, equals(TransactionType.deposit));
      expect(alice.transactionHistory.first.amount, equals(200.0));
    });

    test('Withdraw logic and boundaries', () {
      expect(accountService.withdraw(alice, -10.0), isFalse);
      expect(accountService.withdraw(alice, 0.0), isFalse);
      expect(accountService.withdraw(alice, 1200.0), isFalse); // Insufficient funds
      expect(alice.balance, equals(1000.0));

      expect(accountService.withdraw(alice, 400.0), isTrue);
      expect(alice.balance, equals(600.0));
      expect(alice.transactionHistory.length, equals(1));
      expect(alice.transactionHistory.first.type, equals(TransactionType.withdrawal));
      expect(alice.transactionHistory.first.amount, equals(400.0));
    });

    test('Transfer logic and boundaries', () {
      expect(accountService.transfer(alice, '654321', -100.0), isFalse);
      expect(accountService.transfer(alice, '654321', 0.0), isFalse);
      expect(accountService.transfer(alice, '654321', 1500.0), isFalse); // Insufficient funds
      expect(accountService.transfer(alice, 'nonexistent', 100.0), isFalse); // Invalid dest

      expect(accountService.transfer(alice, '654321', 300.0), isTrue);
      expect(alice.balance, equals(700.0));
      expect(bob.balance, equals(800.0));

      expect(alice.transactionHistory.length, equals(1));
      expect(alice.transactionHistory.first.type, equals(TransactionType.transferOut));
      expect(alice.transactionHistory.first.details, contains('654321'));

      expect(bob.transactionHistory.length, equals(1));
      expect(bob.transactionHistory.first.type, equals(TransactionType.transferIn));
      expect(bob.transactionHistory.first.details, contains('123456'));
    });
  });

  group('Validation Helpers Tests', () {
    test('Amount parsing', () {
      expect(Validation.parseAmount(' 150.50 '), equals(150.5));
      expect(Validation.parseAmount('abc'), isNull);
      expect(Validation.parseAmount(''), isNull);
    });

    test('Positive validation', () {
      expect(Validation.isPositive(0.01), isTrue);
      expect(Validation.isPositive(0.0), isFalse);
      expect(Validation.isPositive(-5.0), isFalse);
    });

    test('Account number check', () {
      expect(Validation.isValidAccountNumber('12345'), isTrue);
      expect(Validation.isValidAccountNumber('123a45'), isFalse);
      expect(Validation.isValidAccountNumber(''), isFalse);
    });

    test('PIN check', () {
      expect(Validation.isValidPin('1111'), isTrue);
      expect(Validation.isValidPin('11a1'), isFalse);
      expect(Validation.isValidPin(''), isFalse);
    });
  });
}
