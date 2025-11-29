import 'package:flutter/material.dart';

class FontSettingsPage extends StatefulWidget {
  const FontSettingsPage({super.key});

  @override
  State<FontSettingsPage> createState() => _FontSettingsPageState();
}

class _FontSettingsPageState extends State<FontSettingsPage> {
  double fontSize = 16;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Font Size")),
      body: Column(
        children: [
          Slider(
            min: 12,
            max: 30,
            value: fontSize,
            onChanged: (v) => setState(() => fontSize = v),
          ),
          Text(
            "Preview Text",
            style: TextStyle(fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
