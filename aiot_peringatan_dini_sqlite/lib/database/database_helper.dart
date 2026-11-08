
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/pembacaan_sensor.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('aiot_peringatan_dini.db');
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
    await db.execute('''
      CREATE TABLE pembacaan_sensor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis_sensor TEXT NOT NULL,
        nilai REAL NOT NULL,
        lokasi_pos TEXT NOT NULL,
        waktu TEXT NOT NULL
      )
    ''');
  }

  // CREATE: Menambahkan pembacaan sensor
  Future<int> insertSensor(PembacaanSensor sensor) async {
    final db = await instance.database;

    return await db.insert(
      'pembacaan_sensor',
      sensor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ: Mengambil seluruh riwayat sensor
  Future<List<PembacaanSensor>> getAllSensors() async {
    final db = await instance.database;

    final result = await db.query(
      'pembacaan_sensor',
      orderBy: 'waktu DESC, id DESC',
    );

    return result.map((data) {
      return PembacaanSensor.fromMap(data);
    }).toList();
  }

  // READ: Mengambil pembacaan terbaru setiap jenis sensor
  Future<List<PembacaanSensor>> getLatestSensors() async {
    final db = await instance.database;

    final result = await db.rawQuery('''
      SELECT * FROM pembacaan_sensor
      WHERE id IN (
        SELECT id FROM pembacaan_sensor AS p
        WHERE waktu = (
          SELECT MAX(waktu)
          FROM pembacaan_sensor
          WHERE jenis_sensor = p.jenis_sensor
        )
        AND id = (
          SELECT MAX(id)
          FROM pembacaan_sensor
          WHERE jenis_sensor = p.jenis_sensor
          AND waktu = p.waktu
        )
      )
    ''');

    return result.map((data) {
      return PembacaanSensor.fromMap(data);
    }).toList();
  }

  // UPDATE: Mengoreksi nilai pembacaan sensor
  Future<int> updateSensor(int id, double nilai) async {
    final db = await instance.database;

    return await db.update(
      'pembacaan_sensor',
      {'nilai': nilai},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE: Menghapus satu pembacaan sensor
  Future<int> deleteSensor(int id) async {
    final db = await instance.database;

    return await db.delete(
      'pembacaan_sensor',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
