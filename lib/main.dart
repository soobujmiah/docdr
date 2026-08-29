import 'package:flutter/material.dart';

void main() {
  runApp(const DocDrApp());
}

class DocDrApp extends StatelessWidget {
  const DocDrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocDr',
      theme: ThemeData(useMaterial3: true),
      home: const _HomePage(),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DocDr')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Text('Your documents, taken care of.'),
          SizedBox(height: 24),
          _ActionTile(label: 'Documents', icon: Icons.description_outlined),
          _ActionTile(label: 'Scan', icon: Icons.document_scanner_outlined),
          _ActionTile(label: 'Templates', icon: Icons.dashboard_customize_outlined),
          _ActionTile(label: 'Create', icon: Icons.add_box_outlined),
          _ActionTile(label: 'Recent', icon: Icons.history_outlined),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final IconData icon;

  const _ActionTile({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(leading: Icon(icon), title: Text(label)),
    );
  }
}
