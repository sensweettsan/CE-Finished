import 'package:flutter/material.dart';
import '../models/notificacoes_model.dart';
import '../repositories/notificacao_repository.dart';

class NotificacoesViewModel {
  final NotificacoesRepository _repository = NotificacoesRepository();
  List<Notificacao> notificacoes = [];
  List<Notificacao> unreadNotificacoes = [];

  Future<void> fetchAllNotificacoes() async {
    notificacoes = await _repository.fetchAll();
  }

  Future<void> fetchUnreadNotificacoes() async {
    unreadNotificacoes = await _repository.fetchUnread();
  }

  Future<List<Notificacao>> fetchByUser(String solicitanteNome) async {
    return await _repository.fetchByUser(solicitanteNome);
  }

  Future<bool> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      await fetchAllNotificacoes();
      await fetchUnreadNotificacoes();
      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  Future<bool> insertNotificacao(Notificacao notificacao) async {
    try {
      await _repository.insert(notificacao);
      await fetchAllNotificacoes();
      await fetchUnreadNotificacoes();
      return true;
    } catch (e) {
      debugPrint('Error inserting notification: $e');
      return false;
    }
  }

  Future<bool> updateStatus(
    int id, {
    required String status,
    String? observacao,
    int? quantidadeAprovada,
  }) async {
    try {
      await _repository.updateStatus(
        id,
        status: status,
        observacao: observacao,
        quantidadeAprovada: quantidadeAprovada,
      );
      await fetchAllNotificacoes();
      await fetchUnreadNotificacoes();
      return true;
    } catch (e) {
      debugPrint('Error updating notification status: $e');
      return false;
    }
  }

  Future<bool> deleteAllNotificacoes() async {
    try {
      await _repository.deleteAll();
      await fetchAllNotificacoes();
      await fetchUnreadNotificacoes();
      return true;
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      return false;
    }
  }

  Future<int> getUnreadCount() async {
    try {
      return await _repository.getUnreadCount();
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      return 0;
    }
  }

  List<Notificacao> filterNotificacoes({
    String? searchQuery,
    String? status,
  }) {
    return notificacoes.where((notificacao) {
      bool matchesSearch = true;
      bool matchesStatus = true;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        matchesSearch = notificacao.produtoNome.toLowerCase().contains(query) ||
            notificacao.solicitanteNome.toLowerCase().contains(query) ||
            notificacao.solicitanteCargo.toLowerCase().contains(query);
      }

      if (status != null && status.isNotEmpty && status != 'todas') {
        matchesStatus = notificacao.status == status;
      }

      return matchesSearch && matchesStatus;
    }).toList();
  }

  String getStatusText(String status) {
    switch (status) {
      case 'aprovado':
        return 'Aprovado';
      case 'parcial':
        return 'Aprovado Parcialmente';
      case 'recusado':
        return 'Recusado';
      default:
        return 'Pendente';
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'aprovado':
        return Colors.green;
      case 'parcial':
        return Colors.orange;
      case 'recusado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
