import '../models/curso_model.dart';
import '../repositories/curso_repository.dart';

class CursoViewModel {
  final CursoRepository _repository = CursoRepository();
  List<Curso> cursos = [];

  Future<void> fetchAllCursos() async {
    cursos = await _repository.fetchAll();
  }

  Future<bool> insertCurso(Curso curso) async {
    try {
      await _repository.insert(curso);
      await fetchAllCursos(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCurso(Curso curso) async {
    try {
      await _repository.update(curso);
      await fetchAllCursos(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCurso(int id) async {
    try {
      await _repository.delete(id);
      await fetchAllCursos(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }
}
