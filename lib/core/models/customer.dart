class Customer {
  final int? id;
  final String name;
  final String? nickname;
  final String? phone;
  final double utangBalance;
  final String? lastPaymentDate;
  final String? createdAt;

  Customer({
    this.id,
    required this.name,
    this.nickname,
    this.phone,
    this.utangBalance = 0.0,
    this.lastPaymentDate,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'nickname': nickname,
      'phone': phone,
      'utang_balance': utangBalance,
      'last_payment_date': lastPaymentDate,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      nickname: map['nickname'] as String?,
      phone: map['phone'] as String?,
      utangBalance: (map['utang_balance'] as num).toDouble(),
      lastPaymentDate: map['last_payment_date'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }
}
