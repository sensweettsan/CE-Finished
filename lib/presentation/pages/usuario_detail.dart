import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/cargo_model.dart';
import '../../repositories/cargo_repository.dart';
import '../../repositories/usuario_repository.dart';
import '../../widgets/confirmation_dialog.dart';

// Formatter classes
class _TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length > 11) text = text.substring(0, 11);

    String formattedText = '';
    if (text.isNotEmpty) {
      formattedText = '(${text.substring(0, text.length.clamp(0, 2))}';
      if (text.length > 2) {
        formattedText += ') ';
        if (text.length <= 6) {
          formattedText += text.substring(2);
        } else {
          formattedText += text.substring(2, 6);
          if (text.length > 6) {
            formattedText += '-${text.substring(6)}';
          }
        }
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _CpfInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length > 11) text = text.substring(0, 11);

    String formattedText = '';
    if (text.isNotEmpty) {
      formattedText = text.substring(0, text.length.clamp(0, 3));
      if (text.length > 3) {
        formattedText += '.${text.substring(3, text.length.clamp(3, 6))}';
        if (text.length > 6) {
          formattedText += '.${text.substring(6, text.length.clamp(6, 9))}';
          if (text.length > 9) {
            formattedText += '-${text.substring(9)}';
          }
        }
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class _DataNascimentoInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (text.length > 8) text = text.substring(0, 8);

    String formattedText = '';
    if (text.isNotEmpty) {
      formattedText = text.substring(0, text.length.clamp(0, 2));
      if (text.length > 2) {
        formattedText += '/${text.substring(2, text.length.clamp(2, 4))}';
        if (text.length > 4) {
          formattedText += '/${text.substring(4)}';
        }
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class UsuarioDetailPage extends StatefulWidget {
  final dynamic usuario;
  final void Function(bool)? onUserDeleted;

  const UsuarioDetailPage({
    super.key,
    required this.usuario,
    this.onUserDeleted,
  });

  @override
  UsuarioDetailPageState createState() => UsuarioDetailPageState();
}

class UsuarioDetailPageState extends State<UsuarioDetailPage> {
  File? _foto;
  final _formKey = GlobalKey<FormState>();
  final CargoRepository cargoRepository = CargoRepository();
  List<Cargo> cargos = [];
  late Cargo cargoAtual;
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _enderecoController;
  late TextEditingController _cpfController;
  late TextEditingController _dataNascimentoController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadCargos();
    cargoAtual = Cargo(cargo: 'Carregando...', idCargos: -1);
  }

  Future<void> _selecionarFoto() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null && mounted) {
        setState(() {
          _foto = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao selecionar imagem'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadCargos() async {
    try {
      final loadedCargos = await cargoRepository.fetchAll();
      if (mounted) {
        setState(() {
          cargos = loadedCargos;
          cargoAtual = cargos.firstWhere(
            (c) => c.idCargos == widget.usuario.cargo,
            orElse: () => Cargo(cargo: 'Não definido', idCargos: -1),
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao carregar cargos'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _initializeControllers() {
    _nomeController = TextEditingController(text: widget.usuario.nome);
    _emailController = TextEditingController(text: widget.usuario.email);
    _telefoneController = TextEditingController(text: widget.usuario.telefone);
    _enderecoController = TextEditingController(text: widget.usuario.endereco);
    _cpfController = TextEditingController(text: widget.usuario.cpf ?? '');
    _dataNascimentoController = TextEditingController(
      text: widget.usuario.dataNascimento ?? '',
    );
  }

  Future<void> _deleteUsuario() async {
    final confirm = await showConfirmationDialog(
      context: context,
      title: 'Confirmar Exclusão',
      content: 'Tem certeza que deseja excluir este usuário?',
      confirmText: 'Excluir',
      cancelText: 'Cancelar',
    );

    if (confirm && mounted) {
      try {
        await UsuarioRepository().delete(widget.usuario.idUsuarios!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário excluído com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          if (widget.onUserDeleted != null) {
            widget.onUserDeleted!(true);
          }
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir usuário: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editarUsuario() async {
    final cargoResult = await showDialog<Cargo>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Usuário'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo obrigatório' : null,
                ),
                TextFormField(
                  controller: _telefoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    _TelefoneInputFormatter(),
                  ],
                ),
                TextFormField(
                  controller: _enderecoController,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                ),
                DropdownButtonFormField<int>(
                  value: widget.usuario.cargo,
                  decoration: const InputDecoration(labelText: 'Cargo'),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Staff')),
                    DropdownMenuItem(value: 2, child: Text('Admin')),
                    DropdownMenuItem(value: 3, child: Text('Instrutor(a)')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        widget.usuario.cargo = value;
                        cargoAtual = Cargo(
                          cargo: value == 1
                              ? 'Staff'
                              : value == 2
                                  ? 'Admin'
                                  : 'Instrutor(a)',
                          idCargos: value,
                        );
                      });
                    }
                  },
                ),
                TextFormField(
                  controller: _cpfController,
                  decoration: const InputDecoration(labelText: 'CPF'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                    _CpfInputFormatter(),
                  ],
                ),
                TextFormField(
                  controller: _dataNascimentoController,
                  decoration: const InputDecoration(
                    labelText: 'Data de Nascimento',
                  ),
                  keyboardType: TextInputType.datetime,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                    _DataNascimentoInputFormatter(),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.pop(context, cargoAtual);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (cargoResult != null && mounted) {
      try {
        widget.usuario.nome = _nomeController.text;
        widget.usuario.email = _emailController.text;
        widget.usuario.telefone = _telefoneController.text;
        widget.usuario.endereco = _enderecoController.text;
        widget.usuario.cargo = cargoResult.idCargos;
        widget.usuario.cpf = _cpfController.text;
        widget.usuario.dataNascimento = _dataNascimentoController.text;

        await UsuarioRepository().update(widget.usuario);
        if (mounted) {
          setState(() {
            cargoAtual = cargoResult;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Usuário atualizado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao atualizar usuário: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Widget _buildInfoCard(String label, String? value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForLabel(label),
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value ?? "Não informado",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Email':
        return Icons.email;
      case 'Telefone':
        return Icons.phone;
      case 'Endereço':
        return Icons.location_on;
      case 'Cargo':
        return Icons.work;
      case 'CPF':
        return Icons.badge;
      case 'Data de Nascimento':
        return Icons.cake;
      default:
        return Icons.info;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _enderecoController.dispose();
    _cpfController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _selecionarFoto,
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 56,
                                  backgroundImage: _foto != null
                                      ? FileImage(_foto!)
                                      : widget.usuario.foto != null
                                          ? FileImage(
                                              File(widget.usuario.foto!))
                                          : null,
                                  child: _foto == null &&
                                          widget.usuario.foto == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 60,
                                          color: Colors.blue,
                                        )
                                      : null,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.orange,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          widget.usuario.nome,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cargoAtual.cargo,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _editarUsuario,
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              label: const Text(
                                'Editar',
                                style: TextStyle(color: Colors.blue),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            ElevatedButton.icon(
                              onPressed: _deleteUsuario,
                              icon:
                                  const Icon(Icons.delete, color: Colors.white),
                              label: const Text(
                                'Excluir',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInfoCard('Email', widget.usuario.email),
                        _buildInfoCard('Telefone', widget.usuario.telefone),
                        _buildInfoCard('Endereço', widget.usuario.endereco),
                        _buildInfoCard('Cargo', cargoAtual.cargo),
                        _buildInfoCard('CPF', widget.usuario.cpf),
                        _buildInfoCard(
                          'Data de Nascimento',
                          widget.usuario.dataNascimento,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
