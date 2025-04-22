import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database_helper.dart';
import '../../models/notificacoes_model.dart';
import '../../models/usuario_model.dart';
import '../../repositories/notificacao_repository.dart';
import '../../repositories/produto_repository.dart';
import '../../models/movimentacao_model.dart';
import '../../repositories/movimentacao_repository.dart';
import 'dashboard.dart';

class ProgressoPage extends StatefulWidget {
  final Usuario currentUser;

  const ProgressoPage({
    super.key,
    required this.currentUser,
  });

  @override
  State<ProgressoPage> createState() => _ProgressoPageState();
}

class _ProgressoPageState extends State<ProgressoPage> {
  final NotificacoesRepository _repository = NotificacoesRepository();
  List<Notificacao> solicitacoes = [];
  List<Notificacao> filteredSolicitacoes = [];
  bool isLoading = true;
  String searchQuery = '';
  String statusFilter = 'todas';

  @override
  void initState() {
    super.initState();
    _loadSolicitacoes();
  }

  void _filterSolicitacoes() {
    setState(() {
      filteredSolicitacoes = solicitacoes.where((solicitacao) {
        bool matchesSearch = true;
        bool matchesStatus = true;

        if (searchQuery.isNotEmpty) {
          matchesSearch = solicitacao.produtoNome
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ||
              solicitacao.solicitanteNome
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase());
        }

        if (statusFilter != 'todas') {
          matchesStatus = solicitacao.status == statusFilter;
        }

        return matchesSearch && matchesStatus;
      }).toList();
    });
  }

  Future<void> _loadSolicitacoes() async {
    try {
      final List<Notificacao> userSolicitacoes;
      if (widget.currentUser.status == 'admin') {
        userSolicitacoes = await _repository.fetchAll();
      } else {
        userSolicitacoes =
            await _repository.fetchByUser(widget.currentUser.nome);
      }

      setState(() {
        solicitacoes = userSolicitacoes;
        _filterSolicitacoes();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading solicitações: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _clearAllSolicitacoes() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Solicitações'),
        content:
            const Text('Tem certeza que deseja limpar todas as solicitações?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _repository.deleteAll();
        await _loadSolicitacoes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todas as solicitações foram limpas')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao limpar solicitações: $e')),
          );
        }
      }
    }
  }

  Future<void> _updateSolicitacaoStatus(Notificacao solicitacao) async {
    if (widget.currentUser.status != 'admin') return;

    final produto =
        await ProdutoRepository().fetchByName(solicitacao.produtoNome);
    if (produto == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto não encontrado')),
        );
      }
      return;
    }

    String selectedStatus = solicitacao.status;
    final quantidadeController = TextEditingController(
      text: solicitacao.quantidadeAprovada?.toString() ?? '',
    );
    final observacaoController = TextEditingController(
      text: solicitacao.observacao,
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Atualizar Solicitação'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produto: ${solicitacao.produtoNome}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('Quantidade solicitada: ${solicitacao.quantidade}'),
                Text('Saldo disponível: ${produto.saldo}'),
                const SizedBox(height: 16),
                const Text('Status:'),
                RadioListTile<String>(
                  title: const Text('Aprovado'),
                  value: 'aprovado',
                  groupValue: selectedStatus,
                  onChanged: (value) => setState(() => selectedStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Aprovado Parcialmente'),
                  value: 'parcial',
                  groupValue: selectedStatus,
                  onChanged: (value) => setState(() => selectedStatus = value!),
                ),
                RadioListTile<String>(
                  title: const Text('Recusado'),
                  value: 'recusado',
                  groupValue: selectedStatus,
                  onChanged: (value) => setState(() => selectedStatus = value!),
                ),
                if (selectedStatus == 'parcial') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: quantidadeController,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade aprovada',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
                const SizedBox(height: 16),
                TextField(
                  controller: observacaoController,
                  decoration: const InputDecoration(
                    labelText: 'Observação',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final formData = {
                  'status': selectedStatus,
                  'quantidadeAprovada': selectedStatus == 'parcial'
                      ? int.tryParse(quantidadeController.text)
                      : null,
                  'observacao': observacaoController.text,
                };
                Navigator.pop(context, formData);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() {
        isLoading =
            true; // Show loading indicator while the transaction is in progress
      });
      try {
        // Start a transaction to update both the notification and product
        final db = await DatabaseHelper().database;
        await db.transaction((txn) async {
          // Update notification status
          await txn.update(
            'notificacoes',
            {
              'status': result['status'],
              'observacao': result['observacao'],
              'quantidade_aprovada': result['quantidadeAprovada'],
              'lida': 1,
            },
            where: 'idNotificacao = ?',
            whereArgs: [solicitacao.idNotificacao],
          );

          // Only update product quantity if approved or partially approved
          if (result['status'] == 'aprovado' || result['status'] == 'parcial') {
            final quantidadeAprovada = result['status'] == 'aprovado'
                ? solicitacao.quantidade
                : result['quantidadeAprovada'];

            if (quantidadeAprovada == null ||
                quantidadeAprovada > produto.saldo) {
              throw Exception(
                  'Quantidade aprovada inválida ou saldo insuficiente');
            }

            // Update product quantity
            await txn.update(
              'produtos',
              {
                'saldo': produto.saldo - quantidadeAprovada,
                'saida': produto.saida + quantidadeAprovada,
              },
              where: 'idProdutos = ?',
              whereArgs: [produto.idProdutos],
            );

            // Create movement record using the same transaction
            final movimentacao = Movimentacao(
              idProdutos: produto.idProdutos!,
              idUsuarios: widget.currentUser.idUsuarios!,
              quantidade: quantidadeAprovada,
              tipo: 'saida',
              dataSaida: DateTime.now(),
            );

            await MovimentacaoRepository().insert(movimentacao, txn: txn);
          }
        });

        await _loadSolicitacoes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Solicitação atualizada com sucesso'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error updating solicitação: $e'); // Added for debugging
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar solicitação: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
      }
    }
  }

  String _getCargoName(String? cargo) {
    if (cargo == null) return 'Desconhecido';

    try {
      // Se o cargo for um número (ID), converta para nome
      final cargoId = int.tryParse(cargo);
      if (cargoId != null) {
        switch (cargoId) {
          case 1:
            return 'Staff';
          case 2:
            return 'Admin';
          case 3:
            return 'Instrutor(a)';
          default:
            return 'Desconhecido';
        }
      }
      return cargo; // Se não for número, retorna o valor original
    } catch (e) {
      return cargo; // Em caso de erro, retorna o valor original
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardPage(
                                  currentUser: widget.currentUser,
                                ),
                              ),
                            );
                          },
                        ),
                        Expanded(
                          child: Text(
                            widget.currentUser.status == 'admin'
                                ? 'Gerenciar Solicitações'
                                : 'Minhas Solicitações',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep,
                              color: Colors.white),
                          onPressed: _clearAllSolicitacoes,
                          tooltip: 'Limpar todas as solicitações',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              _filterSolicitacoes();
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar solicitações...',
                            hintStyle: const TextStyle(color: Colors.white70),
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide:
                                  const BorderSide(color: Colors.white70),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 8),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('Todas'),
                                selected: statusFilter == 'todas',
                                onSelected: (selected) {
                                  setState(() {
                                    statusFilter = 'todas';
                                    _filterSolicitacoes();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Pendentes'),
                                selected: statusFilter == 'pendente',
                                onSelected: (selected) {
                                  setState(() {
                                    statusFilter = 'pendente';
                                    _filterSolicitacoes();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Aprovadas'),
                                selected: statusFilter == 'aprovado',
                                onSelected: (selected) {
                                  setState(() {
                                    statusFilter = 'aprovado';
                                    _filterSolicitacoes();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Parciais'),
                                selected: statusFilter == 'parcial',
                                onSelected: (selected) {
                                  setState(() {
                                    statusFilter = 'parcial';
                                    _filterSolicitacoes();
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Recusadas'),
                                selected: statusFilter == 'recusado',
                                onSelected: (selected) {
                                  setState(() {
                                    statusFilter = 'recusado';
                                    _filterSolicitacoes();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : filteredSolicitacoes.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.inbox_rounded,
                                        size: 64,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Nenhuma solicitação encontrada',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: _loadSolicitacoes,
                                  child: ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filteredSolicitacoes.length,
                                    itemBuilder: (context, index) {
                                      final solicitacao =
                                          filteredSolicitacoes[index];
                                      return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 12),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: InkWell(
                                          onTap: widget.currentUser.status ==
                                                  'admin'
                                              ? () => _updateSolicitacaoStatus(
                                                  solicitacao)
                                              : null,
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            solicitacao
                                                                .produtoNome,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                          if (widget.currentUser
                                                                  .status ==
                                                              'admin')
                                                            Text(
                                                              'Solicitante: ${solicitacao.solicitanteNome} (${_getCargoName(solicitacao.solicitanteCargo)})',
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .grey[600],
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 12,
                                                        vertical: 6,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: _getStatusColor(
                                                                solicitacao
                                                                    .status)
                                                            .withOpacity(0.1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20),
                                                      ),
                                                      child: Text(
                                                        _getStatusDisplay(
                                                            solicitacao.status),
                                                        style: TextStyle(
                                                          color:
                                                              _getStatusColor(
                                                                  solicitacao
                                                                      .status),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Quantidade solicitada: ${solicitacao.quantidade}',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.grey[600],
                                                  ),
                                                ),
                                                if (solicitacao.status ==
                                                        'parcial' &&
                                                    solicitacao
                                                            .quantidadeAprovada !=
                                                        null)
                                                  Text(
                                                    'Quantidade aprovada: ${solicitacao.quantidadeAprovada}',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.orange[700],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Data: ${DateFormat('dd/MM/yyyy HH:mm').format(solicitacao.dataSolicitacao)}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[500],
                                                  ),
                                                ),
                                                if (solicitacao.observacao !=
                                                        null &&
                                                    solicitacao.observacao!
                                                        .isNotEmpty) ...[
                                                  const SizedBox(height: 8),
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Observação:',
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[700],
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          solicitacao
                                                              .observacao!,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors
                                                                .grey[600],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  // Helper methods for status display and color (since Notificacao might not have these)
  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pendente':
        return 'Pendente';
      case 'aprovado':
        return 'Aprovado';
      case 'parcial':
        return 'Parcial';
      case 'recusado':
        return 'Recusado';
      default:
        return 'Desconhecido';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pendente':
        return Colors.grey;
      case 'aprovado':
        return Colors.green;
      case 'parcial':
        return Colors.orange;
      case 'recusado':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
