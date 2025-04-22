class Curso {
  int? idCursos;
  String nome;
  String? turma;

  Curso({
    this.idCursos,
    required this.nome,
    this.turma,
  });

  Map<String, dynamic> toMap() {
    return {
      'idCursos': idCursos,
      'nome': nome,
      'turma': turma,
    };
  }

  factory Curso.fromMap(Map<String, dynamic> map) {
    return Curso(
      idCursos: map['idCursos'],
      nome: map['nome'],
      turma: map['turma'],
    );
  }
}
