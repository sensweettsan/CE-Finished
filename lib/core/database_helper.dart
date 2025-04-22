import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'controle_estoque_new.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create tables in dependency order

    // 1. Cargos (no dependencies)
    await db.execute('''
      CREATE TABLE cargos (
        idCargos INTEGER PRIMARY KEY AUTOINCREMENT,
        cargo TEXT NOT NULL,
        matricula TEXT
      )
    ''');

    // 2. Medida (no dependencies)
    await db.execute('''
      CREATE TABLE medida (
        idMedida INTEGER PRIMARY KEY AUTOINCREMENT,
        medida TEXT NOT NULL,
        descricao TEXT
      )
    ''');

    // 3. Cursos (no dependencies)
    await db.execute('''
      CREATE TABLE cursos (
        idCursos INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        turma TEXT
      )
    ''');

    // 4. Turma (depends on cursos)
    await db.execute('''
      CREATE TABLE turma (
        idTurma INTEGER PRIMARY KEY AUTOINCREMENT,
        turma TEXT NOT NULL,
        instrutor TEXT,
        curso INTEGER,
        FOREIGN KEY (curso) REFERENCES cursos(idCursos) ON DELETE SET NULL
      )
    ''');

    // 5. Usuarios (depends on cargos and turma)
    await db.execute('''
      CREATE TABLE usuarios (
        idUsuarios INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        telefone TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        endereco TEXT NOT NULL,
        cargo INTEGER NOT NULL,
        senha TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'ativo',
        turma INTEGER,
        cpf TEXT NOT NULL UNIQUE,
        foto TEXT,
        dataNascimento TEXT,
        FOREIGN KEY (cargo) REFERENCES cargos(idCargos) ON DELETE RESTRICT,
        FOREIGN KEY (turma) REFERENCES turma(idTurma) ON DELETE SET NULL
      )
    ''');

    // 6. Produtos (depends on medida)
    await db.execute('''
      CREATE TABLE produtos (
        idProdutos INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT NOT NULL,
        medida INTEGER NOT NULL,
        local TEXT,
        entrada INTEGER DEFAULT 0,
        saida INTEGER DEFAULT 0,
        saldo INTEGER DEFAULT 0,
        codigo TEXT UNIQUE,
        dataEntrada TEXT,
        FOREIGN KEY (medida) REFERENCES medida(idMedida) ON DELETE RESTRICT
      )
    ''');

    // 7. Movimentacao (depends on produtos, turma, usuarios)
    await db.execute('''
      CREATE TABLE movimentacao (
        idMovimentacao INTEGER PRIMARY KEY AUTOINCREMENT,
        idProdutos INTEGER NOT NULL,
        idTurma INTEGER,
        idUsuarios INTEGER NOT NULL,
        quantidade INTEGER NOT NULL,
        dataSaida TEXT NOT NULL,
        observacao TEXT,
        FOREIGN KEY (idProdutos) REFERENCES produtos(idProdutos) ON DELETE RESTRICT,
        FOREIGN KEY (idTurma) REFERENCES turma(idTurma) ON DELETE SET NULL,
        FOREIGN KEY (idUsuarios) REFERENCES usuarios(idUsuarios) ON DELETE RESTRICT
      )
    ''');

    // 8. Notificacoes (depends on movimentacao)
    await db.execute('''
      CREATE TABLE notificacoes (
        idNotificacao INTEGER PRIMARY KEY AUTOINCREMENT,
        solicitante_nome TEXT NOT NULL,
        solicitante_cargo TEXT NOT NULL,
        produto_nome TEXT NOT NULL,
        quantidade INTEGER NOT NULL,
        data_solicitacao TEXT NOT NULL,
        lida INTEGER DEFAULT 0,
        idMovimentacao INTEGER,
        observacao TEXT,
        status TEXT DEFAULT 'pendente',
        quantidade_aprovada INTEGER,
        FOREIGN KEY (idMovimentacao) REFERENCES movimentacao(idMovimentacao) ON DELETE SET NULL
      )
    ''');
  }

  Future<int> insertMedida(Map<String, dynamic> medida) async {
    final db = await database;
    return await db.insert('medida', medida);
  }

  Future<void> insertInitialMedidaData() async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    List<Map<String, dynamic>> existingMedidas = await db.query('medida');
    if (existingMedidas.isEmpty) {
      await dbHelper.insertMedida(
          {'medida': 'Unidade', 'descricao': 'Quantidade em unidades'});
      await dbHelper.insertMedida(
          {'medida': 'Caixa', 'descricao': 'Quantidade em caixas'});
      await dbHelper.insertMedida(
          {'medida': 'Litro', 'descricao': 'Quantidade em litros'});
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
