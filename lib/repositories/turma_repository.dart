import '../core/database_helper.dart';
import '../models/turma_model.dart';

class TurmaRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Turma turma) async {
    final db = await _databaseHelper.database;
    return await db.insert('turma', turma.toMap());
  }

  Future<List<Turma>> fetchAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('turma');
    return List.generate(maps.length, (i) => Turma.fromMap(maps[i]));
  }

  Future<int> update(Turma turma) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'turma',
      turma.toMap(),
      where: 'idTurma = ?',
      whereArgs: [turma.idTurma],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('turma', where: 'idTurma = ?', whereArgs: [id]);
  }

  Future<List<Turma>> fetchByInstrutor(String instrutor) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'turma',
      where: 'instrutor = ?',
      whereArgs: [instrutor],
    );
    return List.generate(maps.length, (i) => Turma.fromMap(maps[i]));
  }
}
