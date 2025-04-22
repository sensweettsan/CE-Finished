import '../core/database_helper.dart';
import '../models/curso_model.dart';

class CursoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Curso curso) async {
    final db = await _databaseHelper.database;
    return await db.insert('cursos', curso.toMap());
  }

  Future<List<Curso>> fetchAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('cursos');
    return List.generate(maps.length, (i) => Curso.fromMap(maps[i]));
  }

  Future<int> update(Curso curso) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'cursos',
      curso.toMap(),
      where: 'idCursos = ?',
      whereArgs: [curso.idCursos],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db.delete('cursos', where: 'idCursos = ?', whereArgs: [id]);
  }
}
