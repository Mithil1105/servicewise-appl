import 'package:flutter/material.dart';
import 'package:servicewiseapplication/app_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ServiceWiseApp());
}

class ServiceWiseApp extends StatelessWidget {
  const ServiceWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ServiceWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const AppScaffold(),
    );
  }
}
