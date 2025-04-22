import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/usuario_model.dart';
import '../../models/notificacoes_model.dart';
import '../../viewmodels/notificacoes_viewmodel.dart';

class NotificacoesPage extends StatefulWidget {
  final Usuario currentUser;

  const NotificacoesPage({
    super.key,
    required this.currentUser,
  });

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  final NotificacoesViewModel _viewModel = NotificacoesViewModel();
  List<Notificacao> _notificacoesFiltradas = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotificacoes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadNotificacoes() async {
    setState(() => _isLoading = true);
    try {
      await _viewModel.fetchAllNotificacoes();
      setState(() {
        _notificacoesFiltradas = _viewModel.notificacoes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar notificações')),
        );
      }
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _notificacoesFiltradas = _viewModel.notificacoes.where((n) {
        final produto = n.produtoNome.toLowerCase();
        final solicitante = n.solicitanteNome.toLowerCase();
        final cargo = n.solicitanteCargo.toLowerCase();
        return produto.contains(query) ||
            solicitante.contains(query) ||
            cargo.contains(query);
      }).toList();
    });
  }

  Future<void> _markAsRead(Notificacao notificacao) async {
    final success = await _viewModel.markAsRead(
        notificacao.idNotificacao!); // Changed from id to idNotificacao
    if (success) {
      await _loadNotificacoes();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao marcar como lida')),
        );
      }
    }
  }

  Future<void> _clearAllNotifications() async {
    if (_viewModel.notificacoes.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Notificações'),
        content:
            const Text('Tem certeza que deseja excluir todas as notificações?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _viewModel.deleteAllNotificacoes();
      if (success) {
        await _loadNotificacoes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Todas as notificações foram excluídas')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao excluir notificações')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue[700]!, Colors.blue[500]!],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Notificações',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep, color: Colors.white),
                      onPressed: _clearAllNotifications,
                      tooltip: 'Limpar todas as notificações',
                    ),
                  ],
                ),
              ),
              // Campo de busca
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar notificações...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _notificacoesFiltradas.isEmpty
                          ? const Center(
                              child: Text('Nenhuma notificação encontrada'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _notificacoesFiltradas.length,
                              itemBuilder: (context, index) {
                                final notificacao =
                                    _notificacoesFiltradas[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: notificacao.lida
                                          ? Colors.grey
                                          : Colors.orange,
                                      child: const Icon(
                                        Icons.notifications,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      '${notificacao.solicitanteNome} solicitou ${notificacao.quantidade} unidades de ${notificacao.produtoNome}',
                                      style: TextStyle(
                                        fontWeight: notificacao.lida
                                            ? FontWeight.normal
                                            : FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Text(
                                          'Cargo: ${notificacao.solicitanteCargo}',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                        Text(
                                          'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(notificacao.dataSolicitacao)}',
                                          style: TextStyle(
                                              color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                    trailing: !notificacao.lida
                                        ? IconButton(
                                            icon: const Icon(
                                                Icons.check_circle_outline),
                                            onPressed: () =>
                                                _markAsRead(notificacao),
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
