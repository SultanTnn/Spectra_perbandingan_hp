// FILE: lib/screens/comparison/compare_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/smartphone.dart';

class CompareScreen extends StatefulWidget {
  final List<Smartphone> phones;

  const CompareScreen({super.key, required this.phones});

  @override
  State<CompareScreen> createState() => _CompareScreenState();
}

class _CompareScreenState extends State<CompareScreen>
    with SingleTickerProviderStateMixin {
  Future<void> _launchMarketplace(String? url, String storeName) async {
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Link $storeName belum tersedia")));
      return;
    }
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal membuka link: $e")));
    }
  }

  void _showStoreOptions(Smartphone phone) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Beli ${phone.namaModel}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.shopping_bag, color: Colors.orange),
                title: const Text("Shopee"),
                onTap: () {
                  Navigator.pop(context);
                  _launchMarketplace(phone.shopeeUrl, "Shopee");
                },
              ),
              ListTile(
                leading: const Icon(Icons.store, color: Colors.green),
                title: const Text("Tokopedia"),
                onTap: () {
                  Navigator.pop(context);
                  _launchMarketplace(phone.tokopediaUrl, "Tokopedia");
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // PENTING: Agar konten di belakang AppBar
      appBar: AppBar(
        title: Text(
          "Perbandingan",
          style: GoogleFonts.fredoka(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // PENTING: Menggunakan Stack atau Container full size untuk background
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.phones
                        .map((phone) => _buildCard(phone))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(Smartphone phone) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: phone.imageUrl.isNotEmpty
                  ? Image.network(
                      phone.imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, _) => const Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.phone_android,
                      size: 60,
                      color: Colors.grey,
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              phone.namaModel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _showStoreOptions(phone),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
              child: const Text("Beli Sekarang"),
            ),
            const Divider(height: 30),
            _specRow("Harga", phone.price, Colors.green),
            _specRow("Layar", _cleanSpec(phone.display, "Type:"), Colors.blue),
            _specRow(
              "Chipset",
              _cleanSpec(phone.platform, "Chipset:"),
              Colors.orange,
            ),
            _specRow(
              "Memori",
              _cleanSpec(phone.memory, "Internal:"),
              Colors.purple,
            ),
            _specRow(
              "Kamera",
              _cleanSpec(phone.mainCamera, "Triple:"),
              Colors.pink,
            ),
            _specRow(
              "Baterai",
              _cleanSpec(phone.battery, "Type:"),
              Colors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _specRow(String label, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  String _cleanSpec(String val, String prefix) {
    if (val.isEmpty) return "N/A";
    var lines = val.split('\n');
    var match = lines.firstWhere(
      (l) => l.trim().startsWith(prefix),
      orElse: () => "N/A",
    );
    return match == "N/A" ? val : match.substring(prefix.length).trim();
  }
}

// Background Full Screen
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});
  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _top;
  late Animation<Alignment> _bottom;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _top = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
    ]).animate(_controller);
    _bottom = TweenSequence<Alignment>([
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.bottomLeft, end: Alignment.topLeft),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topLeft, end: Alignment.topRight),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: Alignment.topRight, end: Alignment.bottomRight),
        weight: 1,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: double.infinity, // FULL WIDTH
        height: double.infinity, // FULL HEIGHT
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: _top.value,
            end: _bottom.value,
            colors: const [
              Color(0xFF553C9A),
              Color(0xFF6C63FF),
              Color(0xFF0175C2),
            ],
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
