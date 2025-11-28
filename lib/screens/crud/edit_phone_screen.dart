import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditPhoneScreen extends StatefulWidget {
  final String brand;
  final Map<String, dynamic> initialData; // Data awal HP yang akan diedit

  const EditPhoneScreen({
    super.key,
    required this.brand,
    required this.initialData,
  });

  @override
  State<EditPhoneScreen> createState() => _EditPhoneScreenState();
}

class _EditPhoneScreenState extends State<EditPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // 11 Controller
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

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data awal saat inisialisasi
    _namaModelController.text = widget.initialData['nama_model'] ?? '';
    _bodyController.text = widget.initialData['body'] ?? '';
    _displayController.text = widget.initialData['display'] ?? '';
    _platformController.text = widget.initialData['platform'] ?? '';
    _memoryController.text = widget.initialData['memory'] ?? '';
    _mainCameraController.text = widget.initialData['main_camera'] ?? '';
    _selfieCameraController.text = widget.initialData['selfie_camera'] ?? '';
    _commsController.text = widget.initialData['comms'] ?? '';
    _featuresController.text = widget.initialData['features'] ?? '';
    _batteryController.text = widget.initialData['battery'] ?? '';
    _priceController.text = widget.initialData['price'] ?? '';
  }

  Future<void> _updatePhone() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ❗ PERBAIKAN DI SINI: Menggunakan ApiService.updatePhone
      // Ini akan menghasilkan URL yang benar (misalnya 10.0.2.2/api_hp/update_phone.php)
      final url = Uri.parse(ApiService.updatePhone);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          // Kirim ID dan Brand sebagai kunci, diikuti 11 data form
          'id': widget.initialData['id']
              .toString(), // ID wajib dikirim untuk UPDATE
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

      if (data['status'] == 'success' || data['status'] == 'info') {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
        // Pop 2 kali: Tutup EditScreen, lalu DetailScreen (sebelumnya harus di-refresh)
        Navigator.pop(context, true);
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengedit data: ${data['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error koneksi: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      appBar: AppBar(
        title: Text('Edit ${widget.initialData['nama_model'] ?? 'Data HP'}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Form Edit Data HP',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // --- FIELD FORM YANG SAMA SEPERTI CREATE SCREEN ---
              TextFormField(
                controller: _namaModelController,
                decoration: const InputDecoration(
                  labelText: 'Nama Model',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Model tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bodyController,
                decoration: const InputDecoration(
                  labelText: 'Body',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _displayController,
                decoration: const InputDecoration(
                  labelText: 'Display',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _platformController,
                decoration: const InputDecoration(
                  labelText: 'Platform',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _memoryController,
                decoration: const InputDecoration(
                  labelText: 'Memory',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _mainCameraController,
                decoration: const InputDecoration(
                  labelText: 'Main Camera',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _selfieCameraController,
                decoration: const InputDecoration(
                  labelText: 'Selfie Camera',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _commsController,
                decoration: const InputDecoration(
                  labelText: 'Comms',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _featuresController,
                decoration: const InputDecoration(
                  labelText: 'Features',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _batteryController,
                decoration: const InputDecoration(
                  labelText: 'Battery',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              // --- AKHIR FIELD FORM ---
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePhone,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
