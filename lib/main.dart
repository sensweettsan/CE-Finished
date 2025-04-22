import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'presentation/pages/dashboard.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/notificacoes_page.dart';
import 'presentation/pages/produto_page.dart';
import 'presentation/pages/progresso_page.dart';
import 'presentation/pages/register_page.dart';
import 'presentation/pages/solicitacao_page.dart';
import 'presentation/pages/usuario_page.dart';
import 'models/usuario_model.dart';

void main() async {
  // Inicialize o FFI para o SQLite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Controle de Estoque',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (context) => const LoginPage());
            case '/dashboard':
              final Usuario currentUser = settings.arguments as Usuario;
              return MaterialPageRoute(
                builder: (context) => DashboardPage(currentUser: currentUser),
              );
            case '/solicitacoes':
              final Usuario currentUser = settings.arguments as Usuario;
              return MaterialPageRoute(
                builder: (context) => SolicitacaoPage(currentUser: currentUser),
              );
            case '/usuarios':
              final Usuario currentUser = settings.arguments as Usuario;
              return MaterialPageRoute(
                builder: (context) => UsuarioPage(currentUser: currentUser),
              );
            case '/notificacoes':
              final Usuario currentUser = settings.arguments as Usuario;
              return MaterialPageRoute(
                builder: (context) =>
                    NotificacoesPage(currentUser: currentUser),
              );
            case '/registro':
              return MaterialPageRoute(
                  builder: (context) => const RegisterPage());
            case '/produtos':
              final Usuario currentUser = settings.arguments as Usuario;
              return MaterialPageRoute(
                  builder: (context) => ProdutoPage(currentUser: currentUser));
            case '/progresso':
              final Usuario currentUser = settings.arguments as Usuario;
              return MaterialPageRoute(
                builder: (context) => ProgressoPage(currentUser: currentUser),
              );
            default:
              return MaterialPageRoute(builder: (context) => const LoginPage());
          }
        });
  }
}
