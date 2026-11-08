import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/pesanan.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();
  Database? _database;
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'kantin_kampus.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
 CREATE TABLE pesanan (
 id INTEGER PRIMARY KEY AUTOINCREMENT,
 ringkasan_item TEXT NOT NULL,
 total_item INTEGER NOT NULL,
 total_harga INTEGER NOT NULL,
 tanggal TEXT NOT NULL
 )
 ''');
      },
    );
  }

  Future<int> tambahPesanan(Pesanan pesanan) async {
    final db = await database;
    return db.insert('pesanan', pesanan.toMap());
  }

  Future<List<Pesanan>> ambilSemuaPesanan() async {
    final db = await database;
    final hasil = await db.query('pesanan', orderBy: 'id DESC');
    return hasil.map((baris) => Pesanan.fromMap(baris)).toList();
  }

  Future<int> ubahPesanan(Pesanan pesanan) async {
    final db = await database;
    return db.update(
      'pesanan',
      pesanan.toMap(),
      where: 'id = ?',
      whereArgs: [pesanan.id],
    );
  }

  Future<int> hapusPesanan(int id) async {
    final db = await database;
    return db.delete('pesanan', where: 'id = ?', whereArgs: [id]);
  }
}
