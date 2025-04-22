import '../models/medida_model.dart';
import '../repositories/medida_repository.dart';

class MedidaViewModel {
  final MedidaRepository _repository = MedidaRepository();
  List<Medida> medidas = [];

  Future<void> fetchAllMedidas() async {
    medidas = await _repository.fetchAll();
  }

  Future<bool> insertMedida(Medida medida) async {
    try {
      await _repository.insert(medida);
      await fetchAllMedidas(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateMedida(Medida medida) async {
    try {
      await _repository.update(medida);
      await fetchAllMedidas(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMedida(int id) async {
    try {
      await _repository.delete(id);
      await fetchAllMedidas(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }
}
