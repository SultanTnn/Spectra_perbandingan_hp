import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'detail_screen.dart'; 
import 'session.dart'; // <-- IMPORT "CATATAN" SESSION
import 'create_phone_screen.dart'; // <-- IMPORT HALAMAN FORM BARU

class BrandScreen extends StatefulWidget {
  final String brand;
  
  const BrandScreen({super.key, required this.brand});

  @override
  State<BrandScreen> createState() => _BrandScreenState();
}

class _BrandScreenState extends State<BrandScreen>{
  List<Map<String, dynamic>> items = [];
  bool loading = true;
  String errorMessage = ''; 

  @override
  void initState(){ 
    super.initState(); 
    fetchPhones(); 
  }

  Future<void> fetchPhones() async {
    // ... (Fungsi fetchPhones kamu tidak berubah, biarkan saja) ...
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
        if (!mounted) return;
        setState(() {
          errorMessage = 'Gagal memuat data. Status: ${resp.statusCode}';
          loading = false;
        });
      }
    } catch (e) {
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
                  padding: EdgeInsets.all(8.0), 
                  itemCount: items.length,
                  itemBuilder: (_, i){
                    final it = items[i];
                    return Card(
                      elevation: 3.0,
                      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                        title: Text(it['nama_model'] ?? 'Nama tidak ada'),
                        subtitle: Text(it['price'] ?? 'Harga tidak ada'),
                        trailing: Icon(Icons.phone_android),
                        onTap: () => Navigator.push(context, MaterialPageRoute(
                          builder: (_) => DetailScreen(brand: widget.brand, id: it['id'].toString())
                        )),
                      ),
                    );
                  }
                ),

      // --- INI DIA FITUR CREATE UNTUK ADMIN ---
      floatingActionButton: (UserSession.role == 'admin')
          ? FloatingActionButton(
              onPressed: () {
                // Buka halaman form baru
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Kirim 'brand' agar form tahu HP ini milik siapa
                    builder: (context) => CreatePhoneScreen(brand: widget.brand),
                  ),
                ).then((_) {
                  // Setelah form ditutup, refresh daftar HP
                  fetchPhones();
                });
              },
              tooltip: 'Tambah HP Baru',
              child: Icon(Icons.add),
            )
          : null, // Jika bukan admin, jangan tampilkan apa-apa
      // --- AKHIR FITUR CREATE ---
    );
  }
}