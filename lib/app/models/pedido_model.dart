// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PedidoModel {
  String beep;
  String tipo;
  String idSend;
  bool endDestaque;
  int qtdPrint;
  String numeroPedido;
  String data;
  String tipoPedido;
  String? nomeCliente;
  String? telefone;
  String? end;
  List<SacolaModel>? sacola;
  String formaPagamento;
  String taxaEntrega;
  String desconto;
  String devolverTrocoDe;
  String trocoPara;
  String subTotal;
  String valorTotal;
  String idPedido;
  PedidoModel({
    required this.beep,
    required this.tipo,
    required this.idSend,
    this.endDestaque = false,
    this.qtdPrint = 1,
    required this.numeroPedido,
    required this.data,
    required this.tipoPedido,
    this.nomeCliente,
    this.telefone,
    this.end,
    this.sacola,
    required this.formaPagamento,
    required this.taxaEntrega,
    required this.desconto,
    required this.devolverTrocoDe,
    required this.trocoPara,
    required this.subTotal,
    required this.valorTotal,
    required this.idPedido,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      "beep": beep,
      'tipo': tipo,
      'idSend': idSend,
      'endDestaque': endDestaque,
      'qtdPrint': qtdPrint,
      'numeroPedido': numeroPedido,
      'data': data,
      'tipoPedido': tipoPedido,
      'nomeCliente': nomeCliente,
      'telefone': telefone,
      'end': end,
      'sacola': sacola?.map((x) => x.toMap()).toList(),
      'formaPagamento': formaPagamento,
      'taxaEntrega': taxaEntrega,
      'desconto': desconto,
      'devolverTrocoDe': devolverTrocoDe,
      'trocoPara': trocoPara,
      'subTotal': subTotal,
      'valorTotal': valorTotal,
      'idPedido': idPedido,
    };
  }

  factory PedidoModel.fromMap(Map<String, dynamic> map) {
    return PedidoModel(
      tipo: map['tipo'] ?? "",
      beep: map['beep'] ?? "false",
      idSend: map['idSend'] ?? "",
      endDestaque: map['endDestaque'] ?? false,
      qtdPrint: map['qtdPrint'] ?? 1,
      numeroPedido: map['numeroPedido'] ?? "",
      data: map['data'] ?? "",
      tipoPedido: map['tipoPedido'] ?? "",
      nomeCliente: map['nomeCliente'] != null ? map['nomeCliente'] as String : null,
      telefone: map['telefone'] != null ? map['telefone'] as String : null,
      end: map['end'] != null ? map['end'] as String : null,
      sacola: map["sacola"]?.map<SacolaModel>((element) => SacolaModel.fromMap(element)).toList() ?? <SacolaModel>[],
      formaPagamento: map['formaPagamento'] ?? "",
      taxaEntrega: map['taxaEntrega'] ?? "",
      desconto: map['desconto'] ?? "",
      devolverTrocoDe: map['devolverTrocoDe'] ?? "",
      trocoPara: map['trocoPara'] ?? "",
      subTotal: map['subTotal'] ?? "",
      valorTotal: map['valorTotal'] ?? "",
      idPedido: map['idPedido'] ?? "",
    );
  }

  String toJson() => json.encode(toMap());

  factory PedidoModel.fromJson(String source) => PedidoModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

class SacolaModel {
  String nomeProduto;
  String? tamanho;
  List<String>? complementos;
  String? subtotal;
  String total;
  String? observacoes;
  SacolaModel({
    required this.nomeProduto,
    this.tamanho,
    this.complementos,
    this.subtotal,
    required this.total,
    this.observacoes,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'nomeProduto': nomeProduto,
      'tamanho': tamanho,
      'complementos': complementos,
      'subtotal': subtotal,
      'total': total,
      'observacoes': observacoes,
    };
  }

  factory SacolaModel.fromMap(Map<String, dynamic> map) {
    return SacolaModel(
      nomeProduto: map['nomeProduto'] ?? "",
      tamanho: map['tamanho'] != null ? map['tamanho'] ?? "" : "",
      complementos: List.from((map["complementos"]) ?? []),
      subtotal: map['subtotal'] != null ? map['subtotal'] as String : null,
      total: map['total'] ?? "",
      observacoes: map['observacoes'] != null ? map['observacoes'] ?? "" : "",
    );
  }

  String toJson() => json.encode(toMap());

  factory SacolaModel.fromJson(String source) => SacolaModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
