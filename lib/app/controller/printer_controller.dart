// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform/flutter_pos_printer_platform.dart';
import 'package:gestor_paipfood/app/models/pedido_model.dart';
import '../models/printer_model.dart';
import '../repositories/printer_repository.dart';

//Função do controller Controlar o "estado"(estado = lista de impressoras e impressora selecionada)
class PrinterController extends ChangeNotifier {
  //Inicio do estado
  List<PrinterModel> _printers = [];
  int _indexSelectedPrinter = -1;
  PrinterModel? _printer;
  //Fim do estado
  List<PrinterModel> get printers => _printers;
  PrinterModel? get printer => _printer;
  bool get hasSelectedPrinter => _indexSelectedPrinter >= 0;
  PrinterModel? get selectedPrinter => hasSelectedPrinter ? _printers[_indexSelectedPrinter] : null;

  final PrinterRepository printerRepository;
  PrinterController(this.printerRepository) {
    _init();
  }
  _init() {
    scanPrinters().then((value) {
      printers = value;
      getLastUsedPrinter().then((value) {
        setSelectedPrinter(value);
      });
    });
  }

  set printers(List<PrinterModel> value) {
    _printers = value;
    notifyListeners();
  }

  setSelectedPrinter(PrinterModel? value) {
    if (value == null) {
      _indexSelectedPrinter = -1;
    } else {
      _indexSelectedPrinter = _printers.indexWhere((printer) => printer.deviceName == value.deviceName);
      saveLastUsedPrinter(value);
      _printer = value;
    }
    notifyListeners();
  }

  Future<PrinterModel?> getLastUsedPrinter() async {
    final printer = await printerRepository.get();
    return printer;
  }

  Future<void> printText({required PedidoModel pedido}) async {
    // print("-----------TEXTE RESULT --------------");
    List<int> bytes = [];
    PrinterModel? selectedPrinter;
    String separador = "------------------------------------------------";
    // String separadorDuplo = "================================================================";
    if (_printer == null) {
      var lastUsedPrinter = await getLastUsedPrinter();
      _printer = lastUsedPrinter;
    }

    // Xprinter XP-N160I
    final profile = await CapabilityProfile.load(name: 'XP-N160I');
    // PaperSize.mm80 or PaperSize.mm58
    final generator = Generator(PaperSize.mm80, profile);
    bytes += generator.setGlobalCodeTable('CP1252');
    bytes += generator.reset();
    bytes += generator.text("PEDIDO ${pedido.numeroPedido}", //& NUMERO PEDIDO
        styles: const PosStyles(
            height: PosTextSize.size2, width: PosTextSize.size2, fontType: PosFontType.fontA, align: PosAlign.center));
    bytes += generator.text(pedido.data, //& DATA DO PEDIDO
        styles: const PosStyles(
            height: PosTextSize.size2, fontType: PosFontType.fontA, width: PosTextSize.size2, align: PosAlign.center));
    bytes += generator.text(separador, styles: const PosStyles(align: PosAlign.center)); //& ------

    bytes += generator.text(pedido.tipoPedido.toUpperCase(), //& TIPO DO PEDIDO
        styles: const PosStyles(width: PosTextSize.size2, align: PosAlign.center, height: PosTextSize.size2));
    bytes += generator.text(separador, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('NOME: ${pedido.nomeCliente!.toUpperCase()}'); //&NOME CLIENTE
    bytes += generator.text('TELEFONE: ${pedido.telefone}'); //& TELEFONE

    pedido.end != ""
        ? bytes += generator.text('ENDERECO: ${pedido.end!.toUpperCase()}\n') //& ENDERECO
        : null;
    bytes += generator.text(separador, styles: const PosStyles(align: PosAlign.center)); //& ------

    if (pedido.sacola != null) {
      //* SACOLA
      for (var produto in pedido.sacola!) {
        bytes += generator.text(produto.nomeProduto, //& NOME DO PRODUTO
            styles: const PosStyles(height: PosTextSize.size1, width: PosTextSize.size2, bold: true),
            containsChinese: true);
        bytes += generator.text("", styles: const PosStyles(bold: true));
        if (produto.tamanho != "  ") {
          bytes += generator.text(" --> OP: ${produto.tamanho!.toUpperCase()}",
              styles: const PosStyles(bold: true, fontType: PosFontType.fontA));
        }

        if (produto.complementos.toString() != "[]") {
          for (var complemento in produto.complementos!) {
            bytes += generator.text("  ${complemento.toUpperCase()}",
                styles: const PosStyles(bold: true, fontType: PosFontType.fontA)); //& COMPLEMENTOS
          }
        }

        produto.observacoes != "" //& OBSERVAÇÕES
            ? bytes += generator.text(
                " OBS: ${produto.observacoes!.toUpperCase()}",
                styles: const PosStyles(
                  bold: true,
                  fontType: PosFontType.fontA,
                  reverse: true,
                ),
              )
            : null;

        bytes += generator.row([
          //& TOTAL PRODUTO
          PosColumn(text: 'TOTAL', width: 6, styles: const PosStyles(align: PosAlign.left, bold: true)),
          PosColumn(text: produto.total, width: 6, styles: const PosStyles(align: PosAlign.right, bold: true)),
        ]);
        bytes += generator.text(separador, styles: const PosStyles(align: PosAlign.center));
      }
    }

    bytes += generator.text(pedido.formaPagamento.toUpperCase(), //& FORMA PAGAMENTO
        styles: const PosStyles(
            align: PosAlign.center, width: PosTextSize.size2, height: PosTextSize.size2, fontType: PosFontType.fontA));

    bytes += generator.text(separador, styles: const PosStyles(align: PosAlign.center));
    bytes += generator.row([
      //& SUBTOTAL
      PosColumn(text: 'SUBTOTAL', width: 6, styles: const PosStyles(align: PosAlign.left, fontType: PosFontType.fontA)),
      PosColumn(text: pedido.subTotal, width: 6, styles: const PosStyles(align: PosAlign.right)),
    ]);
    pedido.taxaEntrega != "" //& TAXA DE ENTREGA
        ? bytes += generator.row([
            PosColumn(text: 'TAXA DE ENTREGA', width: 6, styles: const PosStyles(align: PosAlign.left)),
            PosColumn(text: "+ ${pedido.taxaEntrega}", width: 6, styles: const PosStyles(align: PosAlign.right)),
          ])
        : null;
    pedido.desconto != "" //& DESCONTO
        ? bytes += generator.row([
            PosColumn(text: 'DESCONTO', width: 6, styles: const PosStyles(align: PosAlign.left)),
            PosColumn(text: "- ${pedido.desconto}", width: 6, styles: const PosStyles(align: PosAlign.right)),
          ])
        : null;
    bytes += generator.row([
      //& VALOR TOTAL
      PosColumn(
          text: 'VALOR TOTAL',
          width: 6,
          styles: const PosStyles(
              fontType: PosFontType.fontA,
              align: PosAlign.left,
              width: PosTextSize.size2,
              height: PosTextSize.size2,
              bold: true)),
      PosColumn(
          text: pedido.valorTotal,
          width: 6,
          styles:
              const PosStyles(align: PosAlign.right, width: PosTextSize.size2, height: PosTextSize.size2, bold: true)),
    ]);

    bytes += generator.text(separador, styles: const PosStyles(align: PosAlign.center));
    if (pedido.trocoPara != "") {
      bytes += generator.row([
        //& TROCO HEADER
        PosColumn(
            text: 'TROCO PARA',
            width: 6,
            styles: const PosStyles(fontType: PosFontType.fontA, align: PosAlign.left, bold: true)),
        PosColumn(text: "DEVOLVER TROCO DE", width: 6, styles: const PosStyles(align: PosAlign.right, bold: true)),
      ]);
      bytes += generator.row([
        //& TROCO CONTENT
        PosColumn(
            text: pedido.trocoPara,
            width: 6,
            styles: const PosStyles(fontType: PosFontType.fontA, align: PosAlign.left)),
        PosColumn(
            text: "  ${pedido.devolverTrocoDe}  ",
            width: 6,
            styles: const PosStyles(align: PosAlign.right, bold: true, reverse: true)),
      ]);
      bytes += generator.text("---------------------------DOBRE-AQUI---------------------------",
          styles: const PosStyles(align: PosAlign.center, fontType: PosFontType.fontA));
    }
    // if (pedido.endDestaque == true && pedido.end != "") {
    //   bytes += generator.row([
    //     //& ENDERECO GRANDE
    //     PosColumn(
    //         text: '        ENDERECO        ',
    //         width: 12,
    //         styles: const PosStyles(
    //             fontType: PosFontType.fontA,
    //             reverse: true,
    //             align: PosAlign.center,
    //             width: PosTextSize.size2,
    //             height: PosTextSize.size2)),
    //   ]);
    //   bytes += generator.text(""); //& ENDEREÇO
    //   bytes += generator.text('${pedido.end!.toUpperCase()}\n',
    //       styles: const PosStyles(width: PosTextSize.size2, height: PosTextSize.size2, fontType: PosFontType.fontA));
    //   bytes += generator.text(' PEDIDO ${pedido.numeroPedido} - ${pedido.nomeCliente} ',
    //       styles: const PosStyles(
    //         width: PosTextSize.size2,
    //         height: PosTextSize.size2,
    //         fontType: PosFontType.fontA,
    //         align: PosAlign.center,
    //         reverse: true,
    //       ));

    //   bytes += generator.text(separador, styles: const PosStyles(align: PosAlign.center));
    // }
    bytes += generator.reset();

    selectedPrinter = _printer;
    if (selectedPrinter == null) return;
    var printerManager = PrinterManager.instance;
    var printer = selectedPrinter;
    bytes += generator.feed(2);
    bytes += generator.cut();
    pedido.beep == "true" ? bytes += generator.beep() : null;

    printBytes(qtd: pedido.qtdPrint, printerManager: printerManager, bytes: bytes, printer: printer);
  }

  Future<void> printBytes({
    required int qtd,
    required PrinterManager printerManager,
    required List<int> bytes,
    required PrinterModel printer,
  }) async {
    await printerManager.connect(
      type: printer.typePrinter,
      model: UsbPrinterInput(
        name: printer.deviceName,
        productId: printer.productId,
        vendorId: printer.vendorId,
      ),
    );
    for (int i = 0; i < qtd; i++) {
      printerManager.send(type: printer.typePrinter, bytes: bytes);
    }
  }

  Future<List<PrinterModel>> scanPrinters(
      {PrinterType defaultPrinterType = PrinterType.usb, bool isBle = false}) async {
    final printerManager = PrinterManager.instance;
    final discoveredDevices = <PrinterModel>[];
    final completer = Completer<List<PrinterModel>>();
    StreamSubscription<PrinterDevice> subscription;

    subscription = printerManager.discovery(type: defaultPrinterType, isBle: isBle).listen((device) {
      discoveredDevices.add(PrinterModel(
          deviceName: device.name,
          address: device.address,
          isBle: isBle,
          vendorId: device.vendorId,
          productId: device.productId,
          typePrinter: defaultPrinterType));
    }, onDone: () => completer.complete(discoveredDevices));

    final devices = await completer.future;
    subscription.cancel();
    return devices;
  }

  saveLastUsedPrinter(PrinterModel value) {
    printerRepository.save(value);
  }

  connectPrinter({required PrinterModel selectedPrinter}) async {
    var printerManager = PrinterManager.instance;
    printerManager.disconnect(type: selectedPrinter.typePrinter);
    await Future.delayed(const Duration(microseconds: 500));
    printerManager.connect(
        type: selectedPrinter.typePrinter,
        model: UsbPrinterInput(
            name: selectedPrinter.deviceName,
            productId: selectedPrinter.productId,
            vendorId: selectedPrinter.vendorId));
  }

  desconnectPrinter({required PrinterModel selectedPrinter}) {
    var printerManager = PrinterManager.instance;
    printerManager.disconnect(type: selectedPrinter.typePrinter);
  }
}
