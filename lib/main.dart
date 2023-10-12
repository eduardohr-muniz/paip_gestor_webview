import 'package:flutter/material.dart';
import 'package:gestor_paipfood/app/modules/config/config_page.dart';
import 'package:gestor_paipfood/app/modules/webview/web_view_page.dart';
import 'package:windows_single_instance/windows_single_instance.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await WindowsSingleInstance.ensureSingleInstance(args, "instance_checker",
      onSecondWindow: (args) {});
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.deepPurple,
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 60),
          ))),
      initialRoute: "webview",
      routes: {
        "webview": (context) => const WebViewPage(),
        "config": (context) => const ConfigPage(),
      },
    );
  }
}
