import 'package:flutter/material.dart';
import 'package:gestor_paipfood/app/controller/websocket_controller.dart';
import 'package:gestor_paipfood/app/core/ui/widgets/printer_drop_down.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  WebsocketController? _controller;
  final slugEC = TextEditingController();
  final ipPortEC = TextEditingController();

  @override
  void initState() {
    _controller = WebsocketController(context: context);
    _loadSlug();
    _loadIpPort();
    super.initState();
  }

  @override
  void dispose() {
    slugEC.dispose();
    ipPortEC.dispose();
    super.dispose();
  }

  Future<void> _loadSlug() async {
    var result = await _controller!.getSlug();
    setState(() {
      slugEC.text = result;
    });
  }

  Future<void> _loadIpPort() async {
    var result = await _controller!.getIpPort();
    setState(() {
      ipPortEC.text = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 400, child: PrinterDropDown()),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 300,
                    child: TextField(
                      controller: slugEC,
                      decoration: const InputDecoration(
                        helperText: """ID SLUG no final do seu link: nomerest👇
         https://paipfood.com/menu/(nomerest)\n""",
                        label: Text("ID SLUG"),
                        border: OutlineInputBorder(),
                      ),
                    )),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          "SALVO COM SUCESSO!",
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Colors.greenAccent,
                      ));
                      _controller!.addSlug(slugEC.text);
                    },
                    child: const Text("Salvar")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 300,
                    child: TextField(
                      controller: ipPortEC,
                      decoration: const InputDecoration(
                        label: Text("IP + PORT"),
                        border: OutlineInputBorder(),
                      ),
                    )),
                const SizedBox(width: 10),
                ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          "SALVO COM SUCESSO!",
                          style: TextStyle(color: Colors.black),
                        ),
                        backgroundColor: Colors.greenAccent,
                      ));
                      _controller!.addIpPort(ipPortEC.text);
                    },
                    child: const Text("Salvar")),
              ],
            ),
            const SizedBox(height: 30),
            OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Voltar")),
          ],
        ),
      ),
    );
  }
}
