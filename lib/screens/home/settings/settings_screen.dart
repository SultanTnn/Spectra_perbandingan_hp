import 'package:flutter/material.dart';
import 'font_settings_page.dart';
import 'storage_settings_page.dart';
import 'about_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Font Size"),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FontSettingsPage()),
            ),
          ),
          ListTile(
            title: const Text("Storage / Clear Cache"),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StorageSettingsPage()),
            ),
          ),
          ListTile(
            title: const Text("About App"),
            trailing: const Icon(Icons.navigate_next),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AboutPage()),
            ),
          ),
        ],
      ),
    );
  }
}
