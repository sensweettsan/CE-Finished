class Produto {
  int? idProdutos;
  String nome;
  int medida;
  String? local;
  int entrada;
  int saida;
  int saldo;
  String? codigo;
  DateTime? dataEntrada;

  Produto({
    this.idProdutos,
    required this.nome,
    required this.medida,
    this.local,
    this.entrada = 0, // Valor padrão 0
    this.saida = 0, // Valor padrão 0
    this.saldo = 0, // Valor padrão 0
    this.codigo,
    this.dataEntrada,
  });

  Map<String, dynamic> toMap() {
    return {
      'idProdutos': idProdutos,
      'nome': nome,
      'medida': medida,
      'local': local,
      'entrada': entrada,
      'saida': saida,
      'saldo': saldo,
      'codigo': codigo,
      'dataEntrada': dataEntrada?.toIso8601String(),
    };
  }

  factory Produto.fromMap(Map<String, dynamic> map) {
    DateTime? parsedDate;
    try {
      if (map['dataEntrada'] != null &&
          map['dataEntrada'].toString().isNotEmpty) {
        parsedDate = DateTime.parse(map['dataEntrada']);
      }
    } catch (e) {
      print("Erro ao converter dataEntrada: ${map['dataEntrada']}");
      parsedDate = null;
    }

    return Produto(
      idProdutos: map['idProdutos'],
      nome: map['nome'] ?? '',
      medida: map['medida'] ?? 0,
      local: map['local'],
      entrada: map['entrada'] ?? 0,
      saida: map['saida'] ?? 0,
      saldo: map['saldo'] ?? 0,
      codigo: map['codigo'],
      dataEntrada: parsedDate,
    );
  }
}
