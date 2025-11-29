import 'package:flutter/material.dart';

class StorageSettingsPage extends StatelessWidget {
  const StorageSettingsPage({super.key});

  Future<void> clearCache(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 1)); // simulasi
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cache cleared")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Storage Settings")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => clearCache(context),
          child: const Text("Clear Cache"),
        ),
      ),
    );
  }
}
