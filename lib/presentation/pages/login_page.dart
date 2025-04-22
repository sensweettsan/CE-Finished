import 'package:flutter/material.dart';
import '../../models/usuario_model.dart';
import '../../repositories/usuario_repository.dart';
import 'dashboard.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Added for form handling
  bool isLoading = false;
  bool showRegisterButton = true;
  Usuario? currentUser;

  Future<void> _checkUserAccess() async {
    try {
      final usuarios = await UsuarioRepository().fetchAll();
      final hasAdmin = usuarios.any((user) => user.status == 'admin');

      // If no admin exists, show register button
      if (!hasAdmin) {
        setState(() {
          showRegisterButton = true;
          currentUser = null;
        });
        return;
      }

      // Check if current user is admin
      if (emailController.text.isNotEmpty && senhaController.text.isNotEmpty) {
        final user = usuarios.firstWhere(
          (user) =>
              user.email == emailController.text &&
              user.senha == senhaController.text,
          orElse: () => Usuario(
            nome: '',
            email: '',
            telefone: '',
            endereco: '',
            cargo: 0,
            senha: '',
            status: '',
            cpf: '',
          ),
        );

        setState(() {
          currentUser = user;
          showRegisterButton = user.status == 'admin';
        });
      } else {
        setState(() {
          showRegisterButton = false;
          currentUser = null;
        });
      }
    } catch (e) {
      debugPrint('Error checking user access: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUserAccess();
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || senhaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final usuarios = await UsuarioRepository().fetchAll();
      final usuario = usuarios.firstWhere(
        (user) =>
            user.email == emailController.text &&
            user.senha == senhaController.text,
        orElse: () => Usuario(
          nome: '',
          email: '',
          telefone: '',
          endereco: '',
          cargo: 0,
          senha: '',
          status: '',
          cpf: '',
        ),
      );

      await _checkUserAccess(); // Update register button visibility

      setState(() {
        isLoading = false;
      });

      if (usuario.email.isNotEmpty) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(currentUser: usuario),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email ou senha inválidos'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao fazer login: $e'),
          backgroundColor: Colors.red,
        ),
      );
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
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/senac.png',
                            height: 80,
                            width: 80,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Controle de Estoque',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: const Icon(Icons.email),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) => _checkUserAccess(),
                            onSubmitted: (_) =>
                                login(), // Trigger login on Enter
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: senhaController,
                            decoration: InputDecoration(
                              labelText: 'Senha',
                              prefixIcon: const Icon(Icons.lock),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            obscureText: true,
                            onChanged: (_) => _checkUserAccess(),
                            onSubmitted: (_) =>
                                login(), // Trigger login on Enter
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Entrar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (showRegisterButton) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        currentUser?.status == 'admin'
                            ? 'Registrar novo usuário'
                            : 'Criar conta de administrador',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
