import 'package:flutter/material.dart';
import '../models/produto_model.dart';

class ProdutoFormDialog extends StatefulWidget {
  final Produto? produto;

  const ProdutoFormDialog({super.key, this.produto});

  @override
  State<ProdutoFormDialog> createState() => _ProdutoFormDialogState();
}

class _ProdutoFormDialogState extends State<ProdutoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _medidaController = TextEditingController();
  final TextEditingController _localController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  DateTime? _dataEntrada;

  @override
  void initState() {
    super.initState();
    if (widget.produto != null) {
      _nomeController.text = widget.produto!.nome;
      _medidaController.text = widget.produto!.medida.toString();
      _localController.text = widget.produto!.local ?? '';
      _codigoController.text = widget.produto!.codigo ?? '';
      _dataEntrada = widget.produto!.dataEntrada;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataEntrada ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dataEntrada) {
      setState(() {
        _dataEntrada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.produto == null ? 'Adicionar Produto' : 'Editar Produto',
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira o nome do produto';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _medidaController,
                decoration: const InputDecoration(labelText: 'Medida'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Insira a medida';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _localController,
                decoration: const InputDecoration(labelText: 'Local'),
              ),
              TextFormField(
                controller: _codigoController,
                decoration: const InputDecoration(labelText: 'Código'),
              ),
              ListTile(
                title: const Text('Data de Entrada'),
                subtitle: Text(
                  _dataEntrada != null
                      ? '${_dataEntrada!.day}/${_dataEntrada!.month}/${_dataEntrada!.year}'
                      : 'Selecione uma data',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final produto = Produto(
                idProdutos: widget.produto?.idProdutos,
                nome: _nomeController.text,
                medida: int.tryParse(_medidaController.text) ?? 0,
                local: _localController.text,
                entrada:
                    0, // Definido como 0 pois será gerenciado na movimentação
                saida:
                    0, // Definido como 0 pois será gerenciado na movimentação
                saldo:
                    0, // Definido como 0 pois será gerenciado na movimentação
                codigo: _codigoController.text,
                dataEntrada: _dataEntrada,
              );
              Navigator.of(context).pop(produto);
            }
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
