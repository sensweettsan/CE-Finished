import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/database_helper.dart';
import '../../models/movimentacao_model.dart';
import '../../models/produto_model.dart';
import '../../models/usuario_model.dart';
import '../../repositories/movimentacao_repository.dart';
import '../../repositories/produto_repository.dart';

class MovimentacaoPage extends StatefulWidget {
  final Usuario currentUser;
  final Produto produto;

  const MovimentacaoPage({
    super.key,
    required this.currentUser,
    required this.produto,
  });

  @override
  State<MovimentacaoPage> createState() => _MovimentacaoPageState();
}

class _MovimentacaoPageState extends State<MovimentacaoPage> {
  final MovimentacaoRepository _repository = MovimentacaoRepository();
  final ProdutoRepository produtoRepository = ProdutoRepository();
  List<Movimentacao> movimentacoes = [];
  bool isLoading = true;
  final TextEditingController _quantidadeController = TextEditingController();
  String _operationType = 'entrada';

  @override
  void initState() {
    super.initState();
    _loadMovimentacoes();
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _loadMovimentacoes() async {
    setState(() => isLoading = true);
    try {
      final List<Movimentacao> result = await _repository.fetchAll();
      setState(() {
        movimentacoes = result
            .where((m) => m.idProdutos == widget.produto.idProdutos)
            .toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar movimentações: $e')),
        );
      }
    }
  }

  Future<void> _registrarMovimentacao() async {
    if (_quantidadeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira uma quantidade')),
      );
      return;
    }

    final quantidade = int.tryParse(_quantidadeController.text);
    if (quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantidade inválida')),
      );
      return;
    }

    // For saída, check if there's enough stock
    if (_operationType == 'saida' && quantidade > widget.produto.saldo) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Quantidade maior que o saldo disponível')),
      );
      return;
    }

    try {
      final db = await DatabaseHelper().database;
      await db.transaction((txn) async {
        // Update produto
        final novoSaldo = _operationType == 'entrada'
            ? widget.produto.saldo + quantidade
            : widget.produto.saldo - quantidade;

        final novaEntrada = _operationType == 'entrada'
            ? widget.produto.entrada + quantidade
            : widget.produto.entrada;

        final novaSaida = _operationType == 'saida'
            ? widget.produto.saida + quantidade
            : widget.produto.saida;

        await txn.update(
          'produtos',
          {
            'saldo': novoSaldo,
            'entrada': novaEntrada,
            'saida': novaSaida,
          },
          where: 'idProdutos = ?',
          whereArgs: [widget.produto.idProdutos],
        );

        // Create movimentacao record
        final movimentacao = {
          'idProdutos': widget.produto.idProdutos,
          'idUsuarios': widget.currentUser.idUsuarios,
          'quantidade': quantidade,
          'dataSaida': DateTime.now().toIso8601String(),
          'tipo': _operationType,
        };

        await txn.insert('movimentacao', movimentacao);
      });

      _quantidadeController.clear();
      await _loadMovimentacoes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Movimentação registrada com sucesso'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar movimentação: $e'),
            backgroundColor: Colors.red,
          ),
        );
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
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            widget.produto.nome,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Saldo atual: ${widget.produto.saldo}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nova Movimentação',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Entrada'),
                                        value: 'entrada',
                                        groupValue: _operationType,
                                        onChanged: (value) {
                                          setState(
                                              () => _operationType = value!);
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: RadioListTile<String>(
                                        title: const Text('Saída'),
                                        value: 'saida',
                                        groupValue: _operationType,
                                        onChanged: (value) {
                                          setState(
                                              () => _operationType = value!);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _quantidadeController,
                                  decoration: InputDecoration(
                                    labelText: 'Quantidade',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    prefixIcon: const Icon(Icons.inventory),
                                  ),
                                  keyboardType: TextInputType.number,
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _registrarMovimentacao,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: const Text(
                                      'Registrar Movimentação',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : movimentacoes.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.history,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Nenhuma movimentação registrada',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.all(16),
                                    itemCount: movimentacoes.length,
                                    itemBuilder: (context, index) {
                                      final movimentacao = movimentacoes[index];
                                      return Card(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.blue
                                                .withValues(alpha: 0.1),
                                            child: Icon(
                                              movimentacao.tipo == 'saida'
                                                  ? Icons.remove
                                                  : Icons.add,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          title: Text(
                                            movimentacao.tipo == 'saida'
                                                ? 'Saída'
                                                : 'Entrada',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          subtitle: Text(
                                            DateFormat('dd/MM/yyyy HH:mm')
                                                .format(
                                              movimentacao.dataSaida ??
                                                  DateTime.now(),
                                            ),
                                          ),
                                          trailing: Text(
                                            'Qtd: ${movimentacao.quantidade}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
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
