import '../models/movimentacao_model.dart';
import '../repositories/movimentacao_repository.dart';

class MovimentacaoViewModel {
  final MovimentacaoRepository _repository = MovimentacaoRepository();
  List<Movimentacao> movimentacoes = [];

  Future<void> fetchAllMovimentacoes() async {
    movimentacoes = await _repository.fetchAll();
  }

  Future<List<Movimentacao>> fetchByTurma(int turmaId) async {
    return await _repository.fetchByTurma(turmaId);
  }

  Future<List<Movimentacao>> fetchByUsuario(int usuarioId) async {
    return await _repository.fetchByUsuario(usuarioId);
  }

  Future<bool> insertMovimentacao(Movimentacao movimentacao) async {
    try {
      await _repository.insert(movimentacao);
      await fetchAllMovimentacoes(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMovimentacao(Movimentacao movimentacao) async {
    try {
      await _repository.update(movimentacao);
      await fetchAllMovimentacoes(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMovimentacao(int id) async {
    try {
      await _repository.delete(id);
      await fetchAllMovimentacoes(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }
}
