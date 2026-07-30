# Bank Simulation Console Application

A Dart console application that simulates a simple banking system. This application is built following Object-Oriented Programming (OOP) principles, clean architecture, strict business rule validations, and transaction management.

## Key Features

1. **User Login**: Secure card/account entry with a limit of 3 incorrect attempts to prevent login process abuse.
2. **Check Account Balance**: View current balance (encapsulated read-only property).
3. **Deposit Money**: Deposit any amount greater than 0.
4. **Withdraw Money**: Withdraw any amount greater than 0, up to the current account balance limit.
5. **Transfer Money**: Transfer any amount greater than 0, up to the current balance limit, to any existing target account.
6. **Transaction History**: View a formatted list of all account deposits, withdrawals, and transfers with unique transaction IDs and timestamps.
7. **Security / PIN Authorization**: Users must re-enter their secret PIN before authorizing *every single banking operation* for enhanced security.
8. **Log Out**: Securely exit the session and return to the main menu.

## OOP & System Architecture

- **Classes & Objects**: Core objects like `Account`, `Bank`, and `Transaction` coordinate the operations.
- **Encapsulation**: Private variables (e.g. `_balance`, `_pin`, `_transactionHistory` in `Account`) can only be modified through validated, public class methods (`deposit`, `withdraw`, `transferTo`). Direct access is blocked. Transaction lists are returned as `List.unmodifiable` views to preserve data integrity.
- **Validation**: Centralized `Validation` class parses inputs, checks numerical bounds, and verifies format structures.
- **Transaction Management**: Every action creates a self-contained `Transaction` object that keeps track of the type, amount, final balance, and operational metadata.
