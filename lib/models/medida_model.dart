class Medida {
  int? idMedida;
  String medida;
  String? descricao;

  Medida({
    this.idMedida,
    required this.medida,
    this.descricao,
  });

  Map<String, dynamic> toMap() {
    return {
      'idMedida': idMedida,
      'medida': medida,
      'descricao': descricao,
    };
  }

  factory Medida.fromMap(Map<String, dynamic> map) {
    return Medida(
      idMedida: map['idMedida'],
      medida: map['medida'],
      descricao: map['descricao'],
    );
  }
}
