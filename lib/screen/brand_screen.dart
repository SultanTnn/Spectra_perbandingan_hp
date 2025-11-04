import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart'; // Pastikan nama file ini benar

class BrandScreen extends StatefulWidget {
  final String brand;
  
  const BrandScreen({super.key, required this.brand});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen>{
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  String errorMessage = ''; // Untuk menampilkan pesan error

  @override
  void initState(){ 
    super.initState(); 
    fetchPhones(); 
  }

  Future<void> fetchPhones() async {
    // INI YANG DIPERBARUI: (Diganti ke localhost untuk Windows/Web)
    final url = Uri.parse('http://localhost/api_hp/get_phones.php?brand=${widget.brand}');

    try {
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (!mounted) return;

        setState(() {
          items = List<Map<String, dynamic>>.from(data);
          loading = false;
        });
      } else {
        // Handle jika server error
        if (!mounted) return;
        setState(() {
          errorMessage = 'Gagal memuat data. Status: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
      // Handle jika tidak ada koneksi
      if (!mounted) return;
      setState(() {
        errorMessage = 'Terjadi kesalahan koneksi: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text(widget.brand.toUpperCase())),
      body: loading 
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage)) 
              : ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (_, i){
                    final it = items[i];
                    return ListTile(
                      title: Text(it['nama_model'] ?? 'Nama tidak ada'),
                      subtitle: Text(it['price'] ?? 'Harga tidak ada'),
                      onTap: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => DetailScreen(brand: widget.brand, id: it['id'].toString())
                      )),
                    );
                  }
                ),
    );
  }
}