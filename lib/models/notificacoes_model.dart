import 'package:flutter/material.dart';

class Notificacao {
  int? idNotificacao; // Changed from id to idNotificacao
  String solicitanteNome;
  String solicitanteCargo;
  String produtoNome;
  int quantidade;
  DateTime dataSolicitacao;
  bool lida;
  int? idMovimentacao;
  String? observacao;
  String status;
  int? quantidadeAprovada;

  Notificacao({
    this.idNotificacao, // Changed from id to idNotificacao
    required this.solicitanteNome,
    required this.solicitanteCargo,
    required this.produtoNome,
    required this.quantidade,
    required this.dataSolicitacao,
    this.lida = false,
    this.idMovimentacao,
    this.observacao,
    this.status = 'pendente',
    this.quantidadeAprovada,
  });

  Map<String, dynamic> toMap() {
    return {
      'idNotificacao': idNotificacao, // Changed from id to idNotificacao
      'solicitante_nome': solicitanteNome,
      'solicitante_cargo': solicitanteCargo,
      'produto_nome': produtoNome,
      'quantidade': quantidade,
      'data_solicitacao': dataSolicitacao.toIso8601String(),
      'lida': lida ? 1 : 0,
      'idMovimentacao': idMovimentacao,
      'observacao': observacao,
      'status': status,
      'quantidade_aprovada': quantidadeAprovada,
    };
  }

  factory Notificacao.fromMap(Map<String, dynamic> map) {
    return Notificacao(
      idNotificacao: map['idNotificacao'], // Changed from id to idNotificacao
      solicitanteNome: map['solicitante_nome'],
      solicitanteCargo: map['solicitante_cargo'],
      produtoNome: map['produto_nome'],
      quantidade: map['quantidade'],
      dataSolicitacao: DateTime.parse(map['data_solicitacao']),
      lida: map['lida'] == 1,
      idMovimentacao: map['idMovimentacao'],
      observacao: map['observacao'],
      status: map['status'] ?? 'pendente',
      quantidadeAprovada: map['quantidade_aprovada'],
    );
  }

  String getStatusDisplay() {
    switch (status) {
      case 'aprovado':
        return 'APROVADO';
      case 'parcial':
        return 'APROVADO PARCIALMENTE';
      case 'recusado':
        return 'RECUSADO';
      default:
        return 'PENDENTE';
    }
  }

  Color getStatusColor() {
    switch (status) {
      case 'aprovado':
        return Colors.green;
      case 'parcial':
        return Colors.orange;
      case 'recusado':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
