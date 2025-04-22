class Usuario {
  int? idUsuarios;
  String nome;
  String telefone;
  String email;
  String endereco;
  int cargo;
  String senha;
  String status;
  int? turma;
  String cpf;
  String? foto;
  String? dataNascimento;

  Usuario({
    this.idUsuarios,
    required this.nome,
    required this.telefone,
    required this.email,
    required this.endereco,
    required this.cargo,
    required this.senha,
    required this.status,
    this.turma,
    required this.cpf,
    this.foto,
    this.dataNascimento,
  });

  Map<String, dynamic> toMap() {
    return {
      'idUsuarios': idUsuarios,
      'nome': nome,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'cargo': cargo,
      'senha': senha,
      'status': status,
      'turma': turma,
      'cpf': cpf,
      'foto': foto,
      'dataNascimento': dataNascimento,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuarios: map['idUsuarios'],
      nome: map['nome'],
      telefone: map['telefone'],
      email: map['email'],
      endereco: map['endereco'],
      cargo: map['cargo'],
      senha: map['senha'],
      status: map['status'],
      turma: map['turma'],
      cpf: map['cpf'] ?? '',
      foto: map['foto'],
      dataNascimento: map['dataNascimento'],
    );
  }
}
