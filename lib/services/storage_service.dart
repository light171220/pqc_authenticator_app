import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/account.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'authenticator.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE accounts (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            issuer TEXT NOT NULL,
            secret TEXT NOT NULL,
            digits INTEGER DEFAULT 6,
            period INTEGER DEFAULT 30,
            algorithm TEXT DEFAULT 'SHA1',
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
    );
  }

  static Future<void> saveAccount(Account account) async {
    final db = await database;
    await _storage.write(key: 'secret_${account.id}', value: account.secret);
    
    await db.insert(
      'accounts',
      {
        ...account.toJson(),
        'secret': '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<Account>> getAccounts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('accounts');
    
    final accounts = <Account>[];
    for (final map in maps) {
      final secret = await _storage.read(key: 'secret_${map['id']}') ?? '';
      accounts.add(Account.fromJson({...map, 'secret': secret}));
    }
    
    return accounts;
  }

  static Future<void> deleteAccount(String accountId) async {
    final db = await database;
    await _storage.delete(key: 'secret_$accountId');
    await db.delete('accounts', where: 'id = ?', whereArgs: [accountId]);
  }

  static Future<void> saveSecurely(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> readSecurely(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteSecurely(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clearAll() async {
    final db = await database;
    await db.delete('accounts');
    await _storage.deleteAll();
  }
}