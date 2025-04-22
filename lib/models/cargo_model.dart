class Cargo {
  int? idCargos;
  String cargo;
  String? matricula;

  Cargo({
    this.idCargos,
    required this.cargo,
    this.matricula,
  });

  Map<String, dynamic> toMap() {
    return {
      'idCargos': idCargos,
      'cargo': cargo,
      'matricula': matricula,
    };
  }

  factory Cargo.fromMap(Map<String, dynamic> map) {
    return Cargo(
      idCargos: map['idCargos'],
      cargo: map['cargo'],
      matricula: map['matricula'],
    );
  }
}
