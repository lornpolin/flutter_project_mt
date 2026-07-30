import 'models/user.dart';
import 'models/account.dart';
import 'services/account_service.dart';
import 'services/auth_service.dart';
import 'utils/validation.dart';
import 'views/console_view.dart';

class BankApp {
  final AccountService accountService;
  final AuthService authService;
  late final ConsoleView view;
  Account? _currentAccount;

  factory BankApp({
    AccountService? accountService,
    AuthService? authService,
    String Function()? inputProvider,
    void Function(String)? outputPrinter,
  }) {
    final resolvedAccount = accountService ?? AccountService();
    final resolvedAuth = authService ?? AuthService(resolvedAccount);
    return BankApp._(
        resolvedAccount, resolvedAuth, inputProvider, outputPrinter);
  }

  BankApp._(
    this.accountService,
    this.authService,
    String Function()? inputProvider,
    void Function(String)? outputPrinter,
  ) {
    view =
        ConsoleView(inputProvider: inputProvider, outputPrinter: outputPrinter);
    _prepopulateAccounts();
  }

  void _prepopulateAccounts() {
    if (!accountService.exists('2233')) {
      accountService.addAccount(Account(
        User(accountNumber: '2233', pin: '1111', name: 'Lorn Polin'),
        1000,
      ));
    }
    if (!accountService.exists('3344')) {
      accountService.addAccount(Account(
        User(accountNumber: '3344', pin: '2222', name: 'Sothearith'),
        500,
      ));
    }
  }

  void run() {
    view.printWelcomeHeader();

    while (true) {
      if (_currentAccount == null) {
        final shouldContinue = showWelcomeMenu();
        if (!shouldContinue) break;
      } else {
        showMainMenu();
      }
    }
  }

  bool showWelcomeMenu() {
    view.printWelcomeMenu();
    final choice = view.readInput('Please choose an option (1-2): ');

    switch (choice) {
      case '1':
        handleLogin();
        return true;
      case '2':
        view.printLine('\nThank you for using the Bank Simulation. Goodbye!');
        return false;
      default:
        view.printLine('Invalid option. Please enter 1 or 2.');
        return true;
    }
  }

  void handleLogin() {
    view.printLine('\n--- Log In ---');
    authService.resetAttempts();

    while (!authService.isLocked) {
      final accountNumber = view.readInput('Enter Account Number: ');
      final pin = view.readInput('Enter PIN: ');

      final maxAttempts = AuthService.maxAttempts;

      if (!Validation.isValidAccountNumber(accountNumber)) {
        authService.authenticate('', '');
        final attempts = authService.loginAttempts;
        view.printLine(
            'Invalid account number format. (Attempt $attempts of $maxAttempts)');
        continue;
      }

      if (!Validation.isValidPin(pin)) {
        authService.authenticate('', '');
        final attempts = authService.loginAttempts;
        view.printLine(
            'Invalid PIN format. (Attempt $attempts of $maxAttempts)');
        continue;
      }

      final account = authService.authenticate(accountNumber, pin);
      if (account != null) {
        _currentAccount = account;
        view.printLine(
            '\nLogin successful! Welcome, ${_currentAccount!.cardHolderName}.');
        return;
      } else {
        final attempts = authService.loginAttempts;
        view.printLine(
            'Incorrect Account Number or PIN. (Attempt $attempts of $maxAttempts)');
      }
    }

    view.printLine(
        '\nToo many failed login attempts. The login process has stopped.');
  }

  void showMainMenu() {
    final account = _currentAccount!;
    view.printMainMenuHeader(account.cardHolderName, account.accountNumber);
    view.printMainMenuBody();
    final choice = view.readInput('Please choose an option (1-6): ');

    switch (choice) {
      case '1':
        if (confirmPin()) handleCheckBalance();
        break;
      case '2':
        if (confirmPin()) handleDeposit();
        break;
      case '3':
        if (confirmPin()) handleWithdraw();
        break;
      case '4':
        if (confirmPin()) handleTransfer();
        break;
      case '5':
        if (confirmPin()) handleViewTransactionHistory();
        break;
      case '6':
        handleLogout();
        break;
      default:
        view.printLine('Invalid option. Please select 1 to 6.');
    }
  }

  bool confirmPin() {
    final inputPin =
        view.readInput('For authorization, please enter your PIN: ');
    if (_currentAccount!.verifyPin(inputPin)) {
      return true;
    } else {
      view.printLine('Authorization failed: Incorrect PIN. Operation aborted.');
      return false;
    }
  }

  void handleCheckBalance() {
    view.printLine('\n--- Account Balance ---');
    view.printLine(
        'Current Balance: \$${_currentAccount!.balance.toStringAsFixed(2)}');
  }

  void handleDeposit() {
    view.printLine('\n--- Deposit Money ---');
    final input = view.readInput('Enter amount to deposit: \$');
    final amount = Validation.parseAmount(input);

    if (amount == null) {
      view.printLine('Error: Invalid amount format.');
      return;
    }

    if (!Validation.isPositive(amount)) {
      view.printLine('Error: Deposit amount must be greater than 0.');
      return;
    }

    final success = accountService.deposit(_currentAccount!, amount);
    if (success) {
      view.printLine(
          'Success: \$${amount.toStringAsFixed(2)} deposited successfully.');
      view.printLine(
          'New Balance: \$${_currentAccount!.balance.toStringAsFixed(2)}');
    } else {
      view.printLine('Error: Deposit failed.');
    }
  }

  void handleWithdraw() {
    view.printLine('\n--- Withdraw Money ---');
    final input = view.readInput('Enter amount to withdraw: \$');
    final amount = Validation.parseAmount(input);

    if (amount == null) {
      view.printLine('Error: Invalid amount format.');
      return;
    }

    if (!Validation.isPositive(amount)) {
      view.printLine('Error: Withdraw amount must be greater than 0.');
      return;
    }

    if (amount > _currentAccount!.balance) {
      view.printLine(
          'Error: Withdraw amount cannot exceed account balance (\$${_currentAccount!.balance.toStringAsFixed(2)}).');
      return;
    }

    final success = accountService.withdraw(_currentAccount!, amount);
    if (success) {
      view.printLine(
          'Success: \$${amount.toStringAsFixed(2)} withdrawn successfully.');
      view.printLine(
          'New Balance: \$${_currentAccount!.balance.toStringAsFixed(2)}');
    } else {
      view.printLine('Error: Withdrawal failed.');
    }
  }

  void handleTransfer() {
    view.printLine('\n--- Transfer Money ---');
    final destAccountNumber =
        view.readInput('Enter destination account number: ');

    if (destAccountNumber == _currentAccount!.accountNumber) {
      view.printLine('Error: Cannot transfer to your own account.');
      return;
    }

    final destAccount = accountService.getAccount(destAccountNumber);
    if (destAccount == null) {
      view.printLine('Error: Destination account does not exist.');
      return;
    }

    view.printLine('Destination Account Holder: ${destAccount.cardHolderName}');
    final input = view.readInput('Enter amount to transfer: \$');
    final amount = Validation.parseAmount(input);

    if (amount == null) {
      view.printLine('Error: Invalid amount format.');
      return;
    }

    if (!Validation.isPositive(amount)) {
      view.printLine('Error: Transfer amount must be greater than 0.');
      return;
    }

    if (amount > _currentAccount!.balance) {
      view.printLine(
          'Error: Transfer amount cannot exceed account balance (\$${_currentAccount!.balance.toStringAsFixed(2)}).');
      return;
    }

    final success =
        accountService.transfer(_currentAccount!, destAccountNumber, amount);
    if (success) {
      view.printLine(
          'Success: \$${amount.toStringAsFixed(2)} transferred to ${destAccount.cardHolderName} (${destAccount.accountNumber}) successfully.');
      view.printLine(
          'Your New Balance: \$${_currentAccount!.balance.toStringAsFixed(2)}');
    } else {
      view.printLine('Error: Transfer failed.');
    }
  }

  void handleViewTransactionHistory() {
    view.printLine('\n--- Transaction History ---');
    final history = _currentAccount!.transactionHistory;
    if (history.isEmpty) {
      view.printLine('No transactions found.');
    } else {
      for (final tx in history) {
        view.printLine(tx.toString());
      }
    }
  }

  void handleLogout() {
    view.printLine(
        '\nLogged out successfully. Goodbye, ${_currentAccount!.cardHolderName}!');
    _currentAccount = null;
  }
}
