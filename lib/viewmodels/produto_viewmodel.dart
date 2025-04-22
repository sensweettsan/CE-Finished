import 'package:flutter/material.dart';
import '../models/produto_model.dart';
import '../repositories/produto_repository.dart';

class ProdutoViewModel with ChangeNotifier {
  final ProdutoRepository _produtoRepository = ProdutoRepository();

  List<Produto> _produtos = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _currentFilter = '';

  List<Produto> get produtos {
    List<Produto> filtered = _produtos;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
              (p) => p.nome.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_currentFilter == 'acabando') {
      filtered = filtered.where((p) => p.saldo > 0 && p.saldo <= 5).toList();
    } else if (_currentFilter == 'emFalta') {
      filtered = filtered.where((p) => p.saldo <= 0).toList();
    }

    return filtered;
  }

  bool get isLoading => _isLoading;
  String get currentFilter => _currentFilter;

  Future<void> fetchProdutos() async {
    try {
      _isLoading = true;
      notifyListeners();
      _produtos = await _produtoRepository.fetchAll();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduto(Produto produto) async {
    try {
      await _produtoRepository.insert(produto);
      await fetchProdutos();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduto(Produto produto) async {
    try {
      await _produtoRepository.update(produto);
      await fetchProdutos();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduto(int id) async {
    try {
      await _produtoRepository.delete(id);
      await fetchProdutos();
    } catch (e) {
      rethrow;
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilter(String filter) {
    _currentFilter = filter;
    notifyListeners();
  }

  Future<List<Produto>> fetchLowStockProducts() async {
    try {
      return await _produtoRepository.fetchLowStock();
    } catch (e) {
      debugPrint('Error fetching low stock products: $e');
      rethrow;
    }
  }

  // Helper methods for dashboard
  int get totalProducts => _produtos.length;

  int get outOfStockProducts => _produtos.where((p) => p.saldo <= 0).length;

  int get lowStockProducts =>
      _produtos.where((p) => p.saldo > 0 && p.saldo <= 5).length;

  bool isLowStock(Produto produto) => produto.saldo > 0 && produto.saldo <= 5;

  bool isOutOfStock(Produto produto) => produto.saldo <= 0;
}
