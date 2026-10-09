class Product {
  final int? id;
  final String name;
  final String category;
  final double buyPrice;
  final double sellPrice;
  final int quantity;
  final int reorderThreshold;
  final String? barcode;
  final String? createdAt;

  Product({
    this.id,
    required this.name,
    required this.category,
    required this.buyPrice,
    required this.sellPrice,
    required this.quantity,
    this.reorderThreshold = 5,
    this.barcode,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'buy_price': buyPrice,
      'sell_price': sellPrice,
      'quantity': quantity,
      'reorder_threshold': reorderThreshold,
      'barcode': barcode,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      buyPrice: (map['buy_price'] as num).toDouble(),
      sellPrice: (map['sell_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      reorderThreshold: (map['reorder_threshold'] as int?) ?? 5,
      barcode: map['barcode'] as String?,
      createdAt: map['created_at'] as String?,
    );
  }

  bool get isLowStock => quantity <= reorderThreshold;
}
