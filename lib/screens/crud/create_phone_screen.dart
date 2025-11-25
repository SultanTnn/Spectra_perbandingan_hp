import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../service/api_service.dart'; // pastikan import

class CreatePhoneScreen extends StatefulWidget {
  final String brand;
  const CreatePhoneScreen({super.key, required this.brand});

  @override
  State<CreatePhoneScreen> createState() => _CreatePhoneScreenState();
}

class _CreatePhoneScreenState extends State<CreatePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controller
  final _namaModelController = TextEditingController();
  final _bodyController = TextEditingController();
  final _displayController = TextEditingController();
  final _platformController = TextEditingController();
  final _memoryController = TextEditingController();
  final _mainCameraController = TextEditingController();
  final _selfieCameraController = TextEditingController();
  final _commsController = TextEditingController();
  final _featuresController = TextEditingController();
  final _batteryController = TextEditingController();
  final _priceController = TextEditingController();

  Future<void> _savePhone() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(ApiService.createPhone); // <--- FIX DI SINI
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'brand': widget.brand,
          'nama_model': _namaModelController.text,
          'body': _bodyController.text,
          'display': _displayController.text,
          'platform': _platformController.text,
          'memory': _memoryController.text,
          'main_camera': _mainCameraController.text,
          'selfie_camera': _selfieCameraController.text,
          'comms': _commsController.text,
          'features': _featuresController.text,
          'battery': _batteryController.text,
          'price': _priceController.text,
        }),
      );

      if (!mounted) return;

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data HP baru berhasil ditambahkan')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambah data: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error koneksi: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaModelController.dispose();
    _bodyController.dispose();
    _displayController.dispose();
    _platformController.dispose();
    _memoryController.dispose();
    _mainCameraController.dispose();
    _selfieCameraController.dispose();
    _commsController.dispose();
    _featuresController.dispose();
    _batteryController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah HP ${widget.brand.toUpperCase()}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Form Isian Data HP',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),

              TextFormField(
                controller: _namaModelController,
                decoration: InputDecoration(labelText: 'Nama Model', border: OutlineInputBorder()),
                validator: (v) => v == null || v.isEmpty ? 'Nama Model tidak boleh kosong' : null,
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _bodyController,
                decoration: InputDecoration(labelText: 'Body', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _displayController,
                decoration: InputDecoration(labelText: 'Display', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _platformController,
                decoration: InputDecoration(labelText: 'Platform', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _memoryController,
                decoration: InputDecoration(labelText: 'Memory', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _mainCameraController,
                decoration: InputDecoration(labelText: 'Main Camera', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _selfieCameraController,
                decoration: InputDecoration(labelText: 'Selfie Camera', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _commsController,
                decoration: InputDecoration(labelText: 'Comms', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _featuresController,
                decoration: InputDecoration(labelText: 'Features', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 12),

              TextFormField(
                controller: _batteryController,
                decoration: InputDecoration(labelText: 'Battery', border: OutlineInputBorder()),
                maxLines: 3,
              ),

              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _savePhone,
                style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16)),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Simpan Data Baru', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
