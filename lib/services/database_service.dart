import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/maintenance.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'maintenance.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE mantenimientos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tipo_servicio TEXT NOT NULL,
            fecha TEXT NOT NULL,
            kilometraje INTEGER NOT NULL,
            observaciones TEXT
          )
        ''');
      },
    );
  }

  // Crear mantenimiento
  Future<int> createMaintenance(Maintenance maintenance) async {
    final db = await database;
    return await db.insert('mantenimientos', maintenance.toMap());
  }

  // Obtener todos los mantenimientos
  Future<List<Maintenance>> getMaintenances() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'mantenimientos',
      orderBy: 'fecha DESC',
    );

    return List.generate(maps.length, (i) {
      return Maintenance.fromMap(maps[i]);
    });
  }

  // Actualizar mantenimiento
  Future<int> updateMaintenance(Maintenance maintenance) async {
    final db = await database;
    return await db.update(
      'mantenimientos',
      maintenance.toMap(),
      where: 'id = ?',
      whereArgs: [maintenance.id],
    );
  }

  // Eliminar mantenimiento
  Future<int> deleteMaintenance(int id) async {
    final db = await database;
    return await db.delete(
      'mantenimientos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}