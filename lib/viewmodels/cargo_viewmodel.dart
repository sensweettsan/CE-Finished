import '../models/cargo_model.dart';
import '../repositories/cargo_repository.dart';

class CargoViewModel {
  final CargoRepository _repository = CargoRepository();
  List<Cargo> cargos = [];

  Future<void> fetchAllCargos() async {
    cargos = await _repository.fetchAll();
  }

  Future<bool> insertCargo(Cargo cargo) async {
    try {
      await _repository.insert(cargo);
      await fetchAllCargos(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateCargo(Cargo cargo) async {
    try {
      await _repository.update(cargo);
      await fetchAllCargos(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteCargo(int id) async {
    try {
      await _repository.delete(id);
      await fetchAllCargos(); // Refresh the list
      return true;
    } catch (e) {
      return false;
    }
  }
}
