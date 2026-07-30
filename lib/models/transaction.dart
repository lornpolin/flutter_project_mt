enum TransactionType { deposit, withdrawal, transferOut, transferIn }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final double balanceAfter;
  final DateTime timestamp;
  final String details;

  Transaction({
    required this.type,
    required this.amount,
    required this.balanceAfter,
    this.details = '',
  })  : id = 'TXN-${DateTime.now().microsecondsSinceEpoch}',
        timestamp = DateTime.now();

  @override
  String toString() {
    final typeStr = type.toString().split('.').last.toUpperCase();
    final detailsStr = details.isNotEmpty ? ' ($details)' : '';
    final amountFormatted = amount.toStringAsFixed(2);
    final balanceFormatted = balanceAfter.toStringAsFixed(2);
    
    final timeStr = _formatTimestamp(timestamp);
    
    return '[$timeStr] ID: $id | $typeStr | Amount: \$$amountFormatted | Balance: \$$balanceFormatted$detailsStr';
  }

  String _formatTimestamp(DateTime dt) {
    String pad(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${pad(dt.month)}-${pad(dt.day)} ${pad(dt.hour)}:${pad(dt.minute)}:${pad(dt.second)}';
  }
}
