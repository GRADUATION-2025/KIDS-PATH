// 1. Create Transaction Model
class TransactionRecord {
  final String orderId;
  final String parentId;
  final String parentName;
  final String bookingId;
  final DateTime timestamp;

  TransactionRecord({
    required this.orderId,
    required this.parentId,
    required this.parentName,
    required this.bookingId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'parentId': parentId,
      'parentName': parentName,
      'bookingId': bookingId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}