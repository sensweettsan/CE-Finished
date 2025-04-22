import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../models/cargo_model.dart';
import '../repositories/usuario_repository.dart';
import '../repositories/cargo_repository.dart';

class UsuarioViewModel with ChangeNotifier {
  final UsuarioRepository _usuarioRepository = UsuarioRepository();
  final CargoRepository _cargoRepository = CargoRepository();

  List<Usuario> _usuarios = [];
  List<Cargo> _cargos = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Usuario> get usuarios => _usuarios
      .where((usuario) =>
          usuario.nome.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          usuario.email.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  List<Cargo> get cargos => _cargos;
  bool get isLoading => _isLoading;

  Future<void> fetchUsuarios() async {
    try {
      _isLoading = true;
      notifyListeners();

      _usuarios = await _usuarioRepository.fetchAll();
      _cargos = await _cargoRepository.fetchAll();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addUsuario(Usuario usuario) async {
    try {
      await _usuarioRepository.insert(usuario);
      await fetchUsuarios();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUsuario(Usuario usuario) async {
    try {
      await _usuarioRepository.update(usuario);
      await fetchUsuarios();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUsuario(int id) async {
    try {
      await _usuarioRepository.delete(id);
      await fetchUsuarios();
    } catch (e) {
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
