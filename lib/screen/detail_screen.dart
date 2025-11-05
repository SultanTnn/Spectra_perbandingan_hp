import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'session.dart'; // <-- IMPORT "CATATAN" KITA

class DetailScreen extends StatefulWidget {
  final String brand;
  final String id;
  
  // Kita tidak perlu 'userRole' di sini lagi
  const DetailScreen({super.key, required this.brand, required this.id});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>{
  Map<String, dynamic>? data;
  bool loading = true;
  String errorMessage = '';

  @override
  void initState(){ 
    super.initState(); 
    fetchDetail(); 
  }

  Future<void> fetchDetail() async {
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

  // --- FUNGSI BARU UNTUK HAPUS DATA ---
  Future<void> _deletePhone() async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      final url = Uri.parse('http://localhost/api_hp/delete_phone.php');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'brand': widget.brand,
          'id': widget.id,
        }),
      );

      if (!mounted) return;
      final data = json.decode(response.body);

      // Tutup dialog loading
      Navigator.pop(context); 

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil dihapus')),
        );
        // Kembali ke halaman sebelumnya (BrandScreen)
        Navigator.pop(context); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${data['message']}')),
        );
      }
    } catch (e) {
      // Tutup dialog loading
      Navigator.pop(context); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error koneksi: $e')),
      );
    }
  }

  // --- FUNGSI BARU UNTUK KONFIRMASI HAPUS ---
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus data ${data?['nama_model']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx), // Tutup dialog
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Tutup dialog
                _deletePhone(); // Panggil fungsi hapus
              },
              child: Text('Hapus', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text(data?['nama_model'] ?? 'Detail'),
        
        // --- INI BAGIAN PENTING UNTUK ADMIN ---
        actions: [
          // Tampilkan tombol Hapus HANYA JIKA role adalah 'admin'
          if (UserSession.role == 'admin')
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showDeleteDialog(context); // Panggil konfirmasi
              },
            ),
          // Nanti kita akan tambahkan tombol Edit di sini juga
        ],
        // --- AKHIR BAGIAN ADMIN ---
      ),
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
                    // Ini 2 kolom barumu, sesuaikan jika namanya beda
                    Text('Comms:\n${data?['comms'] ?? '-'}'),
                    SizedBox(height:12),
                    Text('Features:\n${data?['features'] ?? '-'}'),
                    SizedBox(height:12),
                    Text('Battery:\n${data?['battery'] ?? '-'}'),
                  ]),
                ),
    );
  }
}