import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gestor_paipfood/app/controller/messages.dart';
import 'package:gestor_paipfood/app/controller/printer_controller.dart';
import 'package:gestor_paipfood/app/models/pedido_model.dart';
import 'package:gestor_paipfood/app/repositories/printer_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:audioplayers/audioplayers.dart';

class WebsocketController extends StatefulWidget {
  final player = AudioPlayer();
  String ipPort = "";
  BuildContext context;
  WebsocketController({super.key, required this.context});
  late IOWebSocketChannel channel;
  late final PrinterRepository printerRepository = PrinterRepositorySharedPreferences();
  late final controller = PrinterController(printerRepository);

  @override
  State<StatefulWidget> createState() {
    throw UnimplementedError();
  }

  Future<void> playSound(String tocar) async {
    while (tocar == "play") {
      player.play(AssetSource('sound/somalert.mp3'), volume: 1);
      await player.onPlayerComplete.first;
    }

    if (tocar == "stop") {
      await player.stop();
      player.dispose();
    }

    if (tocar == "onePlay") {
      player.play(AssetSource('sound/somalert.mp3'), volume: 1);
      await Future.delayed(const Duration(seconds: 2), () async {
        await player.stop();
        player.dispose();
      });
    }
  }

  Future<void> addSlug(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("slug", value);
  }

  Future<String> getSlug() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('slug') ?? "nomerest";
  }

  Future<String> getIpPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ipPort') ?? "144.91.88.240:1769";
  }

  Future<void> addIpPort(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("IpPort", value);
  }

  void init(String slug) {
    // print("init");
    initConnection(slug);
    broadcastNotifications(slug);
  }

  Future initConnection(
    String slug,
  ) async {
    // print("--------initConnection---------");
    if (slug != "nomerest") {
      ipPort = await getIpPort();
      channel = IOWebSocketChannel.connect("ws://$ipPort", pingInterval: const Duration(seconds: 5));
      Future.delayed(const Duration(seconds: 1), () {
        // print("--------ENVIANDO ID---------");
        channel.sink.add('{"idSave": "$slug"}');
        broadcastNotifications(slug);
        var conectado = channel.innerWebSocket;
        conectado != null ? Messages.of(context).showSucess("CONECTADO COM SUCESSO") : null;
      });
    }
  }

  Future broadcastNotifications(String slug) async {
    channel.stream.listen(
      (event) async {
        String result = replaceAccents(event);
        var pedido = PedidoModel.fromJson(result);
        if (pedido.tipo == "pedido") {
          controller.printText(pedido: pedido);
          await player.stop();
          await player.dispose();
        } else {
          await playSound(pedido.tipo);
        }
      },
      onError: (_) async {
        // print("onError");
        //Uma mensagem com erro
        Messages.of(context).showError("INTERNET INSTÁVEL TENTANDO RECONECTAR ⚠️");
        _retryConnectio(slug);
      },
      onDone: () async {
        // print("onDone");
        Messages.of(context).showError("INTERNET INSTÁVEL TENTANDO RECONECTAR ⚠️");
        //Quando fecha a conexão
        _retryConnectio(slug);
      },
      cancelOnError: true,
    );
  }

  Future _retryConnectio(String slug) async {
    // print("retry");
    await Future.delayed(const Duration(seconds: 5));
    await initConnection(slug);
    await broadcastNotifications(slug);
  }

  String replaceAccents(String map) {
    map = map.replaceAll('á', 'a');
    map = map.replaceAll('á', 'a');
    map = map.replaceAll('á', 'a');
    map = map.replaceAll('á', 'a');
    map = map.replaceAll('à', 'a');
    map = map.replaceAll('â', 'a');
    map = map.replaceAll('ã', 'a');
    map = map.replaceAll('é', 'e');
    map = map.replaceAll('ê', 'e');
    map = map.replaceAll('í', 'i');
    map = map.replaceAll('ó', 'o');
    map = map.replaceAll('ô', 'o');
    map = map.replaceAll('õ', 'o');
    map = map.replaceAll('ú', 'u');
    map = map.replaceAll('ç', 'c');
    map = map.replaceAll('Á', 'A');
    map = map.replaceAll('À', 'A');
    map = map.replaceAll('Â', 'A');
    map = map.replaceAll('Ã', 'A');
    map = map.replaceAll('É', 'E');
    map = map.replaceAll('Ê', 'E');
    map = map.replaceAll('Í', 'I');
    map = map.replaceAll('Ó', 'O');
    map = map.replaceAll('Ô', 'O');
    map = map.replaceAll('Õ', 'O');
    map = map.replaceAll('Ú', 'U');
    map = map.replaceAll('Ç', 'C');
    return map;
  }

  void showSnackb(String mensagem, BuildContext context) {
    Future.delayed(const Duration(milliseconds: 100), () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    });
  }
}
