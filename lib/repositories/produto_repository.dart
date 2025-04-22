import '../core/database_helper.dart';
import '../models/produto_model.dart';

class ProdutoRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insert(Produto produto) async {
    final db = await _databaseHelper.database;
    return await db.insert('produtos', produto.toMap());
  }

  Future<Produto?> fetchByName(String nome) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'nome = ?',
      whereArgs: [nome],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return Produto.fromMap(maps.first);
  }

  Future<List<Produto>> fetchAll() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('produtos');
    return List.generate(maps.length, (i) => Produto.fromMap(maps[i]));
  }

  Future<List<Produto>> fetchLowStock() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'produtos',
      where: 'saldo <= ?',
      whereArgs: [5],
    );
    return List.generate(maps.length, (i) => Produto.fromMap(maps[i]));
  }

  Future<int> update(Produto produto) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'produtos',
      produto.toMap(),
      where: 'idProdutos = ?',
      whereArgs: [produto.idProdutos],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;
    return await db
        .delete('produtos', where: 'idProdutos = ?', whereArgs: [id]);
  }
}
