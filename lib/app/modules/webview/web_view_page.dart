import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gestor_paipfood/app/controller/websocket_controller.dart';
import 'package:webview_windows/webview_windows.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class WebViewPage extends StatefulWidget {
  const WebViewPage({
    Key? key,
  }) : super(key: key);

  @override
  State<WebViewPage> createState() => _ExampleBrowser();
}

class _ExampleBrowser extends State<WebViewPage> {
  final _controllerWebView = WebviewController();
  late String slug;
  late WebsocketController _controller;

  @override
  void initState() {
    _controller = WebsocketController(context: context);
    super.initState();
    initPlatformState();
    _loadSlug();

    WebviewPermissionDecision.allow;
  }

  @override
  void dispose() {
    super.dispose();
    _controllerWebView.dispose();
  }

  Future<void> _loadSlug() async {
    var result = await _controller.getSlug();
    setState(() {
      slug = result;
    });
    if (result != "") {
      //& Inicia o WebSocket se o slug foi setado
      _controller.initConnection(result);
    }
  }

  Future<void> initPlatformState() async {
    try {
      await _controllerWebView.initialize();
      _controllerWebView.url.listen((url) {});
      await _controllerWebView.setBackgroundColor(Colors.transparent);
      await _controllerWebView.setPopupWindowPolicy(WebviewPopupWindowPolicy.allow);
      await _controllerWebView.loadUrl('https://paipfood.com/dashboard/$slug');
      if (!mounted) return;
      setState(() {});
    } on PlatformException catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: const Text('Error'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Code: ${e.code}'),
                      Text('Message: ${e.message}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Continue'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  ],
                ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Webview(
          _controllerWebView,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        splashColor: Colors.greenAccent,
        backgroundColor: Colors.deepPurpleAccent,
        mini: true,
        onPressed: () {
          Navigator.of(context).pushNamed("config");
        },
        child: const Icon(Icons.settings),
      ),
    );
  }
}
