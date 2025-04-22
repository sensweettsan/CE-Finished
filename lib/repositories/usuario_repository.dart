import '../core/database_helper.dart';
import '../models/usuario_model.dart';

class UsuarioRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Usuario usuario) async {
    final db = await _databaseHelper.database;
    return await db.insert('usuarios', usuario.toMap());
  }

  Future<List<Usuario>> fetchAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('usuarios');
    return List.generate(maps.length, (i) => Usuario.fromMap(maps[i]));
  }

  Future<Usuario?> findByEmail(String email) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Usuario.fromMap(maps.first);
  }

  Future<List<Usuario>> fetchByTurma(int turmaId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'turma = ?',
      whereArgs: [turmaId],
    );
    return List.generate(maps.length, (i) => Usuario.fromMap(maps[i]));
  }

  Future<List<Usuario>> fetchByCargo(int cargoId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'cargo = ?',
      whereArgs: [cargoId],
    );
    return List.generate(maps.length, (i) => Usuario.fromMap(maps[i]));
  }

  Future<int> update(Usuario usuario) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'usuarios',
      usuario.toMap(),
      where: 'idUsuarios = ?',
      whereArgs: [usuario.idUsuarios],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db
        .delete('usuarios', where: 'idUsuarios = ?', whereArgs: [id]);
  }

  Future<Usuario?> authenticate(String email, String senha) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'usuarios',
      where: 'email = ? AND senha = ?',
      whereArgs: [email, senha],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Usuario.fromMap(maps.first);
  }
}
