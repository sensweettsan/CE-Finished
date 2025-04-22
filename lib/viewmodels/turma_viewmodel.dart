import '../models/turma_model.dart';
import '../repositories/turma_repository.dart';

class TurmaViewModel {
  final TurmaRepository _repository = TurmaRepository();
  List<Turma> turmas = [];

  Future<void> fetchAllTurmas() async {
    turmas = await _repository.fetchAll();
  }

  Future<List<Turma>> fetchByInstrutor(String instrutor) async {
    return await _repository.fetchByInstrutor(instrutor);
  }

  Future<bool> insertTurma(Turma turma) async {
    try {
      await _repository.insert(turma);
      await fetchAllTurmas(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTurma(Turma turma) async {
    try {
      await _repository.update(turma);
      await fetchAllTurmas(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTurma(int id) async {
    try {
      await _repository.delete(id);
      await fetchAllTurmas(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }
}
