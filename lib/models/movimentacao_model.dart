class Movimentacao {
  int? idMovimentacao;
  int idProdutos;
  int idUsuarios;
  int quantidade;
  DateTime? dataSaida;
  String tipo;

  Movimentacao({
    this.idMovimentacao,
    required this.idProdutos,
    required this.idUsuarios,
    required this.quantidade,
    this.dataSaida,
    required this.tipo,
  });

  Map<String, dynamic> toMap() {
    return {
      'idMovimentacao': idMovimentacao,
      'idProdutos': idProdutos,
      'idUsuarios': idUsuarios,
      'quantidade': quantidade,
      'dataSaida': dataSaida?.toIso8601String(),
      'tipo': tipo,
    };
  }

  factory Movimentacao.fromMap(Map<String, dynamic> map) {
    return Movimentacao(
      idMovimentacao: map['idMovimentacao'],
      idProdutos: map['idProdutos'],
      idUsuarios: map['idUsuarios'],
      quantidade: map['quantidade'] ?? 0,
      dataSaida:
          map['dataSaida'] != null ? DateTime.parse(map['dataSaida']) : null,
      tipo: map['tipo'] ?? 'entrada',
    );
  }
}
