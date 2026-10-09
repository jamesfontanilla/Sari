class TransactionRecord {
  final int? id;
  final String type; // 'sale', 'utang', 'payment', 'restock'
  final double totalAmount;
  final int? customerId;
  final String? note;
  final String? rawVoiceTranscript;
  final String? timestamp;

  TransactionRecord({
    this.id,
    required this.type,
    required this.totalAmount,
    this.customerId,
    this.note,
    this.rawVoiceTranscript,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'total_amount': totalAmount,
      'customer_id': customerId,
      'note': note,
      'raw_voice_transcript': rawVoiceTranscript,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      id: map['id'] as int?,
      type: map['type'] as String,
      totalAmount: (map['total_amount'] as num).toDouble(),
      customerId: map['customer_id'] as int?,
      note: map['note'] as String?,
      rawVoiceTranscript: map['raw_voice_transcript'] as String?,
      timestamp: map['timestamp'] as String?,
    );
  }
}

class TransactionItem {
  final int? id;
  final int transactionId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  TransactionItem({
    this.id,
    required this.transactionId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'transaction_id': transactionId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      id: map['id'] as int?,
      transactionId: map['transaction_id'] as int,
      productId: map['product_id'] as int,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
      subtotal: (map['subtotal'] as num).toDouble(),
    );
  }
}
