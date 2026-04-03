import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/part_model.dart';
import '../models/customer_model.dart';
import '../models/memo_model.dart';
import '../models/memo_item_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mobileshop_pos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE parts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        model TEXT NOT NULL,
        part_name TEXT NOT NULL,
        price REAL,
        customer_price REAL,
        tudo_price REAL,
        category TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE memos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memo_number TEXT UNIQUE,
        customer_id INTEGER,
        customer_name TEXT,
        subtotal REAL,
        discount REAL,
        total REAL,
        note TEXT,
        created_at TEXT,
        FOREIGN KEY(customer_id) REFERENCES customers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE memo_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        memo_id INTEGER,
        part_id INTEGER,
        model TEXT,
        part_name TEXT,
        quantity INTEGER,
        unit_price REAL,
        total_price REAL,
        FOREIGN KEY(memo_id) REFERENCES memos(id),
        FOREIGN KEY(part_id) REFERENCES parts(id)
      )
    ''');
  }

  // ─── PARTS ───────────────────────────────────────────────────────────────

  Future<int> insertPart(PartModel part) async {
    try {
      final db = await database;
      return await db.insert('parts', part.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updatePart(PartModel part) async {
    try {
      final db = await database;
      return await db.update(
        'parts',
        part.toMap(),
        where: 'id = ?',
        whereArgs: [part.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deletePart(int id) async {
    try {
      final db = await database;
      return await db.delete('parts', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<PartModel>> getAllParts({String? search, String? category}) async {
    try {
      final db = await database;
      String where = '1=1';
      List<dynamic> whereArgs = [];

      if (search != null && search.isNotEmpty) {
        where += ' AND (model LIKE ? OR part_name LIKE ?)';
        whereArgs.addAll(['%$search%', '%$search%']);
      }
      if (category != null && category != 'All') {
        where += ' AND category = ?';
        whereArgs.add(category);
      }

      final maps = await db.query(
        'parts',
        where: where,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'model ASC, part_name ASC',
      );
      return maps.map((m) => PartModel.fromMap(m)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getPartsCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM parts');
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> bulkInsertParts(List<PartModel> parts) async {
    try {
      final db = await database;
      int count = 0;
      await db.transaction((txn) async {
        for (final part in parts) {
          await txn.insert('parts', part.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          count++;
        }
      });
      return count;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> bulkUpdateCustomerPrice(double multiplier) async {
    try {
      final db = await database;
      await db.rawUpdate(
          'UPDATE parts SET customer_price = customer_price * ?', [multiplier]);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getPartModels(String query) async {
    try {
      final db = await database;
      final maps = await db.query(
        'parts',
        columns: ['DISTINCT model'],
        where: 'model LIKE ?',
        whereArgs: ['%$query%'],
        limit: 10,
      );
      return maps.map((m) => m['model'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // ─── CUSTOMERS ────────────────────────────────────────────────────────────

  Future<int> insertCustomer(CustomerModel customer) async {
    try {
      final db = await database;
      return await db.insert('customers', customer.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> updateCustomer(CustomerModel customer) async {
    try {
      final db = await database;
      return await db.update(
        'customers',
        customer.toMap(),
        where: 'id = ?',
        whereArgs: [customer.id],
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteCustomer(int id) async {
    try {
      final db = await database;
      return await db.delete('customers', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CustomerModel>> getAllCustomers({String? search}) async {
    try {
      final db = await database;
      String? where;
      List<dynamic>? whereArgs;

      if (search != null && search.isNotEmpty) {
        where = 'name LIKE ? OR phone LIKE ?';
        whereArgs = ['%$search%', '%$search%'];
      }

      final maps = await db.query(
        'customers',
        where: where,
        whereArgs: whereArgs,
        orderBy: 'name ASC',
      );
      return maps.map((m) => CustomerModel.fromMap(m)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getCustomerNames(String query) async {
    try {
      final db = await database;
      final maps = await db.query(
        'customers',
        columns: ['name'],
        where: 'name LIKE ?',
        whereArgs: ['%$query%'],
        limit: 10,
      );
      return maps.map((m) => m['name'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  // ─── MEMOS ────────────────────────────────────────────────────────────────

  Future<String> generateMemoNumber() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
          'SELECT MAX(CAST(REPLACE(memo_number, "#", "") AS INTEGER)) as max_num FROM memos');
      final maxNum = result.first['max_num'] as int? ?? 0;
      final nextNum = maxNum + 1;
      return '#${nextNum.toString().padLeft(4, '0')}';
    } catch (e) {
      return '#0001';
    }
  }

  Future<int> insertMemo(MemoModel memo) async {
    try {
      final db = await database;
      return await db.insert('memos', memo.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> deleteMemo(int id) async {
    try {
      final db = await database;
      await db.delete('memo_items', where: 'memo_id = ?', whereArgs: [id]);
      return await db.delete('memos', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MemoModel>> getAllMemos({
    String? search,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      final db = await database;
      String where = '1=1';
      List<dynamic> whereArgs = [];

      if (search != null && search.isNotEmpty) {
        where += ' AND (customer_name LIKE ? OR memo_number LIKE ?)';
        whereArgs.addAll(['%$search%', '%$search%']);
      }
      if (fromDate != null) {
        where += ' AND created_at >= ?';
        whereArgs.add(fromDate);
      }
      if (toDate != null) {
        where += ' AND created_at <= ?';
        whereArgs.add('${toDate}T23:59:59');
      }

      final maps = await db.query(
        'memos',
        where: where,
        whereArgs: whereArgs.isEmpty ? null : whereArgs,
        orderBy: 'created_at DESC',
      );
      return maps.map((m) => MemoModel.fromMap(m)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MemoModel>> getRecentMemos({int limit = 5}) async {
    try {
      final db = await database;
      final maps = await db.query(
        'memos',
        orderBy: 'created_at DESC',
        limit: limit,
      );
      return maps.map((m) => MemoModel.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<int> getTodayMemosCount() async {
    try {
      final db = await database;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM memos WHERE created_at LIKE ?',
          ['$today%']);
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getMonthMemosCount() async {
    try {
      final db = await database;
      final month = DateTime.now().toIso8601String().substring(0, 7);
      final result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM memos WHERE created_at LIKE ?',
          ['$month%']);
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<MemoModel>> getMemosByCustomer(int customerId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'memos',
        where: 'customer_id = ?',
        whereArgs: [customerId],
        orderBy: 'created_at DESC',
      );
      return maps.map((m) => MemoModel.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }

  // ─── MEMO ITEMS ───────────────────────────────────────────────────────────

  Future<void> insertMemoItems(List<MemoItemModel> items) async {
    try {
      final db = await database;
      await db.transaction((txn) async {
        for (final item in items) {
          await txn.insert('memo_items', item.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MemoItemModel>> getMemoItems(int memoId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'memo_items',
        where: 'memo_id = ?',
        whereArgs: [memoId],
      );
      return maps.map((m) => MemoItemModel.fromMap(m)).toList();
    } catch (e) {
      return [];
    }
  }
}
