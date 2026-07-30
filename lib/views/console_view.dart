import 'dart:io';

class ConsoleView {
  final String Function()? inputProvider;
  final void Function(String)? outputPrinter;

  ConsoleView({this.inputProvider, this.outputPrinter});

  void printLine(String msg) {
    if (outputPrinter != null) {
      outputPrinter!(msg);
    } else {
      print(msg);
    }
  }

  void writePrompt(String prompt) {
    if (inputProvider == null) {
      stdout.write(prompt);
    }
  }

  String readInput(String prompt) {
    writePrompt(prompt);
    if (inputProvider != null) {
      final input = inputProvider!();
      printLine('> Input: $input');
      return input;
    }
    return stdin.readLineSync() ?? '';
  }

  void printDivider() {
    printLine('==============================================');
  }

  void printWelcomeHeader() {
    printDivider();
    printLine('       WELCOME TO THE BANK SIMULATION          ');
    printDivider();
  }

  void printWelcomeMenu() {
    printLine('\n--- Welcome Menu ---');
    printLine('1. Log In');
    printLine('2. Exit');
  }

  void printMainMenuHeader(String name, String accountNumber) {
    printLine('\n==============================================');
    printLine('  Logged In: $name ($accountNumber)');
    printDivider();
  }

  void printMainMenuBody() {
    printLine('1. Check Account Balance');
    printLine('2. Deposit Money');
    printLine('3. Withdraw Money');
    printLine('4. Transfer Money');
    printLine('5. View Transaction History');
    printLine('6. Log Out');
    printDivider();
  }
}
