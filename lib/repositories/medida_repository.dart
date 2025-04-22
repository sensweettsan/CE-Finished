import '../core/database_helper.dart';
import '../models/medida_model.dart';

class MedidaRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Medida medida) async {
    final db = await _databaseHelper.database;
    return await db.insert('medida', medida.toMap());
  }

  Future<List<Medida>> fetchAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('medida');
    return List.generate(maps.length, (i) => Medida.fromMap(maps[i]));
  }

  Future<int> update(Medida medida) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'medida',
      medida.toMap(),
      where: 'idMedida = ?',
      whereArgs: [medida.idMedida],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('medida', where: 'idMedida = ?', whereArgs: [id]);
  }
}
