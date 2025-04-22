class Turma {
  int? idTurma;
  String turma;
  String? instrutor;
  int? curso;

  Turma({
    this.idTurma,
    required this.turma,
    this.instrutor,
    this.curso,
  });

  Map<String, dynamic> toMap() {
    return {
      'idTurma': idTurma,
      'turma': turma,
      'instrutor': instrutor,
      'curso': curso,
    };
  }

  factory Turma.fromMap(Map<String, dynamic> map) {
    return Turma(
      idTurma: map['idTurma'],
      turma: map['turma'],
      instrutor: map['instrutor'],
      curso: map['curso'],
    );
  }
}
