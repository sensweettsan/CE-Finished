import 'package:flutter/material.dart';
import '../../models/produto_model.dart';
import '../../models/usuario_model.dart';
import '../../repositories/produto_repository.dart';
import '../../widgets/animated_card.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/summary_card.dart';
import 'login_page.dart';

class DashboardPage extends StatefulWidget {
  final Usuario currentUser;

  const DashboardPage({
    super.key,
    required this.currentUser,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int totalProdutos = 0;
  int produtosEmFalta = 0;
  int produtosAcabando = 0;
  List<Produto> produtos = [];
  List<Produto> filteredProdutos = [];
  bool isLoading = true;
  String currentFilter = '';
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEstoqueResumo();
    _showNotification();
  }

  Future<void> _fetchEstoqueResumo() async {
    try {
      final List<Produto> produtosList = await ProdutoRepository().fetchAll();

      if (!mounted) return;

      setState(() {
        produtos = produtosList;
        _applyFilters();
        totalProdutos = produtosList.length;
        produtosEmFalta = produtosList.where((p) => p.saldo <= 0).length;
        produtosAcabando =
            produtosList.where((p) => p.saldo > 0 && p.saldo <= 5).length;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching estoque resumo: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao carregar dados do estoque'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filterProducts(String filter) {
    setState(() {
      currentFilter = filter;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Produto> tempList = List.from(produtos);

    // Apply category filter
    switch (currentFilter) {
      case 'acabando':
        tempList = tempList.where((p) => p.saldo > 0 && p.saldo <= 5).toList();
        break;
      case 'emFalta':
        tempList = tempList.where((p) => p.saldo <= 0).toList();
        break;
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      tempList = tempList
          .where(
              (p) => p.nome.toLowerCase().contains(searchQuery.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredProdutos = tempList;
    });
  }

  Future<void> _showNotification() async {
    await Future.delayed(const Duration(seconds: 1));

    if (produtosEmFalta > 0 || produtosAcabando > 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Produtos em falta: $produtosEmFalta\nProdutos acabando: $produtosAcabando',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _fetchEstoqueResumo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Controle'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showConfirmationDialog(
                context: context,
                title: 'Confirmar Logout',
                content: 'Tem certeza que deseja sair?',
              );

              if (confirm) {
                Navigator.pushReplacement(
                  // ignore: use_build_context_synchronously
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Visão Geral',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _filterProducts(''),
                                child: SummaryCard(
                                  label: 'Total de Produtos',
                                  value: totalProdutos,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _filterProducts('emFalta'),
                                child: SummaryCard(
                                  label: 'Produtos em Falta',
                                  value: produtosEmFalta,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () => _filterProducts('acabando'),
                                child: SummaryCard(
                                  label: 'Produtos Acabando',
                                  value: produtosAcabando,
                                  color: Colors.yellow,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Center(
                        child: Text(
                          'Ações Rápidas',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Show admin options only for admin users
                            if (widget.currentUser.status == 'admin') ...[
                              AnimatedActionCard(
                                icon: Icons.inventory,
                                label: 'Gerenciar\nEstoque',
                                color: Colors.blue,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/produtos',
                                    arguments: widget.currentUser,
                                  ).then((_) => _refreshData());
                                },
                              ),
                              AnimatedActionCard(
                                icon: Icons.people_alt_rounded,
                                label: 'Staff',
                                color: Colors.red,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/usuarios',
                                    arguments: widget.currentUser,
                                  ).then((_) => _refreshData());
                                },
                              ),
                              AnimatedActionCard(
                                icon: Icons.notifications,
                                label: 'Notificações',
                                color: Colors.purple,
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/notificacoes',
                                    arguments: widget.currentUser,
                                  ).then((_) => _refreshData());
                                },
                              ),
                            ],
                            // Show progress page for everyone
                            AnimatedActionCard(
                              icon: Icons.track_changes,
                              label: 'Progresso',
                              color: Colors.blue,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/progresso',
                                  arguments: widget.currentUser,
                                ).then((_) => _refreshData());
                              },
                            ),
                            // Show solicitations for everyone
                            AnimatedActionCard(
                              icon: Icons.shopping_cart,
                              label: 'Solicitações',
                              color: Colors.green,
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/solicitacoes',
                                  arguments: widget.currentUser,
                                ).then((_) => _refreshData());
                              },
                            ),
                          ],
                        ),
                      ),
                      if (currentFilter.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Produtos ${currentFilter == "acabando" ? "Acabando" : "em Falta"}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => _filterProducts(''),
                              tooltip: 'Limpar filtro',
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Pesquisar produtos...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() {
                                        searchQuery = '';
                                        _applyFilters();
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                              _applyFilters();
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredProdutos.length,
                          itemBuilder: (context, index) {
                            final produto = filteredProdutos[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(produto.nome),
                                subtitle: Text('Saldo: ${produto.saldo}'),
                                trailing: Icon(
                                  produto.saldo <= 0
                                      ? Icons.error
                                      : Icons.warning,
                                  color: produto.saldo <= 0
                                      ? Colors.red
                                      : Colors.orange,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
