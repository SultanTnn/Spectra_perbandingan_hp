import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailScreen extends StatefulWidget {
  final String brand;
  final String id;
  
  const DetailScreen({super.key, required this.brand, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>{
  Map<String, dynamic>? data;
  bool loading = true;
  String errorMessage = ''; // Untuk menampilkan pesan error

  @override
  void initState(){ 
    super.initState(); 
    fetchDetail(); 
  }

  Future<void> fetchDetail() async {
    // INI YANG DIPERBARUI: (Diganti ke localhost untuk Windows/Web)
    final url = Uri.parse('http://localhost/api_hp/get_detail.php?brand=${widget.brand}&id=${widget.id}');

    try {
      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final j = json.decode(resp.body);
        if (!mounted) return;

        setState(() {
          data = j as Map<String, dynamic>;
          loading = false;
        });
      } else {
        // Handle jika server error (misal, 404 Not Found)
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
      appBar: AppBar(title: Text(data?['nama_model'] ?? 'Detail')),
      body: loading 
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(errorMessage)))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(data?['nama_model'] ?? 'Nama tidak ada', style: TextStyle(fontSize:20,fontWeight: FontWeight.bold)),
                    SizedBox(height:8),
                    Text('Price: ${data?['price'] ?? '-'}'),
                    SizedBox(height:12),
                    Text('Body:\n${data?['body'] ?? '-'}'),
                    SizedBox(height:12),
                    Text('Display:\n${data?['display'] ?? '-'}'),
                    SizedBox(height:12),
                    Text('Platform:\n${data?['platform'] ?? '-'}'),
                    SizedBox(height:12),
                    Text('Memory:\n${data?['memory'] ?? '-'}'),
                    SizedBox(height:12),
                    Text('Main Camera:\n${data?['main_camera'] ?? '-'}'),
                    SizedBox(height:12),
                    Text('Selfie Camera:\n${data?['selfie_camera'] ?? '-'}'),
                    SizedBox(height:12),
                    Text('Battery:\n${data?['battery'] ?? '-'}'),
                  ]),
                ),
    );
  }
}