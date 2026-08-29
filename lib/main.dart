import 'package:flutter/material.dart';

/// DocDr application entry point.
///
/// Scope note: this is the P0 application shell only. It exists so the
/// repository is buildable, analysable and testable. The document workspace,
/// reader, scanner, OCR and generation features arrive in later phases; see
/// ROADMAP.md and docs/PRODUCT_BACKLOG.md.
void main() {
  runApp(const DocDrApp());
}

/// Root application widget.
class DocDrApp extends StatelessWidget {
  /// Creates the DocDr application shell.
  const DocDrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DocDr',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E57)),
        useMaterial3: true,
      ),
      home: const DocDrHomePage(),
    );
  }
}

/// Placeholder home surface for the P0 application shell.
class DocDrHomePage extends StatelessWidget {
  /// Creates the home page.
  const DocDrHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DocDr')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Your documents, taken care of.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
