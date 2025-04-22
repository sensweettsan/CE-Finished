import '../core/database_helper.dart';
import '../models/cargo_model.dart';

class CargoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Cargo cargo) async {
    final db = await _databaseHelper.database;
    return await db.insert('cargos', cargo.toMap());
  }

  Future<List<Cargo>> fetchAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cargos');
    return List.generate(maps.length, (i) => Cargo.fromMap(maps[i]));
  }

  Future<int> update(Cargo cargo) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'cargos',
      cargo.toMap(),
      where: 'idCargos = ?',
      whereArgs: [cargo.idCargos],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('cargos', where: 'idCargos = ?', whereArgs: [id]);
  }
}
