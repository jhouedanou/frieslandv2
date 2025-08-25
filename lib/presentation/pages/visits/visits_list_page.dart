import 'package:flutter/material.dart';

class VisitsListPage extends StatelessWidget {
  const VisitsListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visites'),
      ),
      body: const Center(
        child: Text('Liste des visites'),
      ),
    );
  }
}