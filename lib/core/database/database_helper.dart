import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/customer.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sari.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Customers Table (Utang Ledger)
    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        nickname TEXT,
        phone TEXT,
        utang_balance REAL NOT NULL DEFAULT 0.0,
        last_payment_date TEXT,
        created_at TEXT DEFAULT (datetime('now', 'localtime'))
      )
    ''');

    // 2. Products Table (Inventory)
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        buy_price REAL NOT NULL,
        sell_price REAL NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        reorder_threshold INTEGER NOT NULL DEFAULT 5,
        barcode TEXT,
        created_at TEXT DEFAULT (datetime('now', 'localtime'))
      )
    ''');

    // 3. Transactions Table
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL CHECK (type IN ('sale', 'utang', 'payment', 'restock')),
        total_amount REAL NOT NULL,
        customer_id INTEGER,
        note TEXT,
        raw_voice_transcript TEXT,
        timestamp TEXT DEFAULT (datetime('now', 'localtime')),
        FOREIGN KEY (customer_id) REFERENCES customers(id) ON DELETE SET NULL
      )
    ''');

    // 4. Transaction Items Table
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT
      )
    ''');

    // Indexes
    await db.execute('CREATE INDEX idx_customers_utang ON customers(utang_balance);');
    await db.execute('CREATE INDEX idx_transactions_timestamp ON transactions(timestamp);');
    await db.execute('CREATE INDEX idx_products_quantity ON products(quantity);');

    // Seed Starter Data
    await _seedStarterData(db);
  }

  Future<void> _seedStarterData(Database db) async {
    // 20 Iconic Sari-Sari Store Starter Products
    final starterProducts = [
      {'name': 'Lucky Me! Pancit Canton Kalamansi 60g', 'category': 'Noodles', 'buy_price': 13.0, 'sell_price': 16.0, 'quantity': 24, 'reorder_threshold': 6, 'barcode': '4800016644815'},
      {'name': 'Lucky Me! Pancit Canton Original 60g', 'category': 'Noodles', 'buy_price': 13.0, 'sell_price': 16.0, 'quantity': 18, 'reorder_threshold': 6, 'barcode': '4800016644808'},
      {'name': 'Lucky Me! Pancit Canton Chilimansi 60g', 'category': 'Noodles', 'buy_price': 13.0, 'sell_price': 16.0, 'quantity': 20, 'reorder_threshold': 6, 'barcode': '4800016644839'},
      {'name': 'Lucky Me! Instant Mami Beef 55g', 'category': 'Noodles', 'buy_price': 12.0, 'sell_price': 15.0, 'quantity': 15, 'reorder_threshold': 5, 'barcode': '4800016644013'},
      {'name': 'Lucky Me! Instant Mami Chicken 55g', 'category': 'Noodles', 'buy_price': 12.0, 'sell_price': 15.0, 'quantity': 12, 'reorder_threshold': 5, 'barcode': '4800016644020'},
      {'name': 'Mega Sardines Red (Tomato Sauce) 155g', 'category': 'Canned Goods', 'buy_price': 22.0, 'sell_price': 26.0, 'quantity': 14, 'reorder_threshold': 5, 'barcode': '4806511011116'},
      {'name': 'Mega Sardines Green (Extra Hot) 155g', 'category': 'Canned Goods', 'buy_price': 22.0, 'sell_price': 26.0, 'quantity': 8, 'reorder_threshold': 4, 'barcode': '4806511011123'},
      {'name': 'Argentina Corned Beef 150g', 'category': 'Canned Goods', 'buy_price': 34.0, 'sell_price': 40.0, 'quantity': 10, 'reorder_threshold': 4, 'barcode': '4800092330121'},
      {'name': 'Century Tuna Flakes in Oil 155g', 'category': 'Canned Goods', 'buy_price': 38.0, 'sell_price': 45.0, 'quantity': 7, 'reorder_threshold': 3, 'barcode': '4800092110112'},
      {'name': 'San Marino Corned Tuna 150g', 'category': 'Canned Goods', 'buy_price': 36.0, 'sell_price': 42.0, 'quantity': 6, 'reorder_threshold': 3, 'barcode': '4809011743015'},
      {'name': 'Nescafé Classic Sachet 2g', 'category': 'Coffee & Beverage', 'buy_price': 5.0, 'sell_price': 7.0, 'quantity': 50, 'reorder_threshold': 15, 'barcode': '4800361284201'},
      {'name': 'Kopiko Blanca Twin Pack 52g', 'category': 'Coffee & Beverage', 'buy_price': 13.0, 'sell_price': 16.0, 'quantity': 30, 'reorder_threshold': 10, 'barcode': '8996001414002'},
      {'name': 'Milo Sachet 22g', 'category': 'Coffee & Beverage', 'buy_price': 10.0, 'sell_price': 13.0, 'quantity': 25, 'reorder_threshold': 8, 'barcode': '4800361395013'},
      {'name': 'Bear Brand Fortified Milk Powder 33g', 'category': 'Coffee & Beverage', 'buy_price': 14.0, 'sell_price': 17.0, 'quantity': 20, 'reorder_threshold': 6, 'barcode': '4800361298017'},
      {'name': 'Coca-Cola Mismo 290ml', 'category': 'Beverages', 'buy_price': 15.0, 'sell_price': 20.0, 'quantity': 12, 'reorder_threshold': 6, 'barcode': '4801981113011'},
      {'name': 'Sprite Mismo 290ml', 'category': 'Beverages', 'buy_price': 15.0, 'sell_price': 20.0, 'quantity': 8, 'reorder_threshold': 4, 'barcode': '4801981114018'},
      {'name': 'Sinandomeng Bigas (per Kilo)', 'category': 'Rice & Grains', 'buy_price': 48.0, 'sell_price': 54.0, 'quantity': 50, 'reorder_threshold': 10, 'barcode': '4800000000018'},
      {'name': 'Safeguard White Soap 60g', 'category': 'Personal Care', 'buy_price': 24.0, 'sell_price': 29.0, 'quantity': 10, 'reorder_threshold': 3, 'barcode': '4902430758017'},
      {'name': 'Surf Blossom Fresh Powder Sachet 50g', 'category': 'Household', 'buy_price': 7.0, 'sell_price': 9.0, 'quantity': 35, 'reorder_threshold': 10, 'barcode': '4800888151012'},
      {'name': 'Datu Puti Toyo & Suka Twin Pack 100ml', 'category': 'Condiments', 'buy_price': 12.0, 'sell_price': 15.0, 'quantity': 16, 'reorder_threshold': 5, 'barcode': '4801668601019'},
    ];

    for (var prod in starterProducts) {
      await db.insert('products', prod);
    }

    // Seed Demo Suki Customers (Utang Ledger)
    final starterCustomers = [
      {'name': 'Mang Juan Dela Cruz', 'nickname': 'Juan', 'phone': '09171234567', 'utang_balance': 350.0, 'last_payment_date': '2026-10-05 14:20:00'},
      {'name': 'Aling Rosa Santos', 'nickname': 'Rosa', 'phone': '09289876543', 'utang_balance': 450.0, 'last_payment_date': '2026-09-28 09:15:00'},
      {'name': 'Kuya Jojo Ramos', 'nickname': 'Jojo', 'phone': '09193334444', 'utang_balance': 120.0, 'last_payment_date': '2026-10-07 18:00:00'},
    ];

    for (var cust in starterCustomers) {
      await db.insert('customers', cust);
    }
  }

  // --- CRUD HELPERS ---

  // Products
  Future<List<Product>> getProducts() async {
    final db = await instance.database;
    final result = await db.query('products', orderBy: 'name ASC');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT * FROM products WHERE quantity <= reorder_threshold ORDER BY quantity ASC'
    );
    return result.map((json) => Product.fromMap(json)).toList();
  }

  Future<int> updateProductQuantity(int id, int delta) async {
    final db = await instance.database;
    return await db.rawUpdate(
      'UPDATE products SET quantity = MAX(0, quantity + ?) WHERE id = ?',
      [delta, id]
    );
  }

  // Customers
  Future<List<Customer>> getCustomers() async {
    final db = await instance.database;
    final result = await db.query('customers', orderBy: 'utang_balance DESC, name ASC');
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  Future<Customer> findOrCreateCustomer(String name) async {
    final db = await instance.database;
    final results = await db.query(
      'customers',
      where: 'LOWER(name) LIKE ? OR LOWER(nickname) LIKE ?',
      whereArgs: ['%${name.toLowerCase()}%', '%${name.toLowerCase()}%'],
      limit: 1,
    );

    if (results.isNotEmpty) {
      return Customer.fromMap(results.first);
    } else {
      final newId = await db.insert('customers', {
        'name': name,
        'nickname': name,
        'utang_balance': 0.0,
      });
      return Customer(id: newId, name: name, nickname: name, utangBalance: 0.0);
    }
  }

  Future<void> updateCustomerUtang(int customerId, double delta) async {
    final db = await instance.database;
    await db.rawUpdate(
      'UPDATE customers SET utang_balance = MAX(0.0, utang_balance + ?), last_payment_date = datetime(\'now\', \'localtime\') WHERE id = ?',
      [delta, customerId]
    );
  }

  // Transactions
  Future<int> recordTransaction({
    required String type,
    required double totalAmount,
    int? customerId,
    String? note,
    String? rawTranscript,
    List<Map<String, dynamic>> items = const [],
  }) async {
    final db = await instance.database;
    return await db.transaction((txn) async {
      final txnId = await txn.insert('transactions', {
        'type': type,
        'total_amount': totalAmount,
        'customer_id': customerId,
        'note': note,
        'raw_voice_transcript': rawTranscript,
        'timestamp': DateTime.now().toIso8601String(),
      });

      for (var item in items) {
        await txn.insert('transaction_items', {
          'transaction_id': txnId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'unit_price': item['unit_price'],
          'subtotal': item['subtotal'],
        });
      }

      if (type == 'utang' && customerId != null) {
        await txn.rawUpdate(
          'UPDATE customers SET utang_balance = utang_balance + ? WHERE id = ?',
          [totalAmount, customerId]
        );
      } else if (type == 'payment' && customerId != null) {
        await txn.rawUpdate(
          'UPDATE customers SET utang_balance = MAX(0.0, utang_balance - ?), last_payment_date = datetime(\'now\', \'localtime\') WHERE id = ?',
          [totalAmount, customerId]
        );
      }

      return txnId;
    });
  }

  Future<List<TransactionRecord>> getRecentTransactions({int limit = 20}) async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'timestamp DESC', limit: limit);
    return result.map((json) => TransactionRecord.fromMap(json)).toList();
  }

  // Metrics for Dashboard & Insights
  Future<Map<String, double>> getTodayMetrics() async {
    final db = await instance.database;
    
    // Total today's sales
    final salesRes = await db.rawQuery('''
      SELECT SUM(total_amount) as total 
      FROM transactions 
      WHERE type = 'sale' AND date(timestamp) = date('now', 'localtime')
    ''');
    final todaySales = (salesRes.first['total'] as num?)?.toDouble() ?? 0.0;

    // Total outstanding utang
    final utangRes = await db.rawQuery('SELECT SUM(utang_balance) as total FROM customers');
    final totalUtang = (utangRes.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'today_sales': todaySales,
      'total_utang': totalUtang,
    };
  }

  // Customer Transaction History
  Future<List<TransactionRecord>> getCustomerTransactions(int customerId) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'timestamp DESC',
    );
    return result.map((json) => TransactionRecord.fromMap(json)).toList();
  }

  // Find product by exact barcode
  Future<Product?> findProductByBarcode(String barcode) async {
    final db = await instance.database;
    final results = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode.trim()],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return Product.fromMap(results.first);
    }
    return null;
  }

  // Assign or update barcode for a product
  Future<int> assignBarcodeToProduct(int productId, String barcode) async {
    final db = await instance.database;
    return await db.update(
      'products',
      {'barcode': barcode.trim()},
      where: 'id = ?',
      whereArgs: [productId],
    );
  }

  // Find product by keyword or barcode
  Future<Product?> findProduct(String query) async {
    final db = await instance.database;
    final lower = query.toLowerCase().trim();
    final results = await db.query(
      'products',
      where: 'LOWER(name) LIKE ? OR barcode = ?',
      whereArgs: ['%$lower%', query],
      limit: 1,
    );
    if (results.isNotEmpty) {
      return Product.fromMap(results.first);
    }
    return null;
  }

  // Reset & Re-seed Database (Crucial for Demo Day)
  Future<void> resetAndSeedDatabase() async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('transaction_items');
      await txn.delete('transactions');
      await txn.delete('customers');
      await txn.delete('products');
    });
    await _seedStarterData(db);
  }

  // App settings & Onboarding state
  Future<bool> isOnboarded() async {
    final db = await instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    final res = await db.query('app_settings', where: 'key = ?', whereArgs: ['onboarded']);
    return res.isNotEmpty && res.first['value'] == 'true';
  }

  Future<void> setOnboarded(bool value) async {
    final db = await instance.database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
    await db.insert(
      'app_settings',
      {'key': 'onboarded', 'value': value ? 'true' : 'false'},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
