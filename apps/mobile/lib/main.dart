import 'package:flutter/material.dart';

void main() {
  runApp(const IsharaApp());
}

class IsharaApp extends StatelessWidget {
  const IsharaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ishara',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ishara'),
      ),
      body: const Center(
        child: Text('Nepali Sign Language dictionary'),
      ),
    );
  }
}
