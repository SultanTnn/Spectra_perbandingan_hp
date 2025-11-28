import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/session.dart';
import '../service/api_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import '../screens/home/profile_avatar_widget.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _namaLengkapController = TextEditingController();
  final _usernameController = TextEditingController();

  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  
  // Kunci unik untuk memaksa rebuild avatar di layar ini
  int _localAvatarKey = 0; 

  @override
  void initState() {
    super.initState();
    _namaLengkapController.text = UserSession.namaLengkap ?? '';
    _usernameController.text = UserSession.username ?? '';
    // Inisialisasi kunci lokal agar sesuai dengan kunci sesi
    _localAvatarKey = UserSession.cacheKey; 
  }

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  // ... (Fungsi _pickImage tetap sama, tidak perlu diubah) ...
  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Pilih dari Galeri'),
            onTap: () async {
              final XFile? image = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 80,
              );
              if (image != null) {
                setState(() {
                  _pickedImage = image;
                  _localAvatarKey = DateTime.now().millisecondsSinceEpoch; // Update local key
                });
              }
              Navigator.of(ctx).pop();
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Ambil Foto'),
            onTap: () async {
              final XFile? image = await _picker.pickImage(
                source: ImageSource.camera,
                imageQuality: 80,
              );
              if (image != null) {
                setState(() {
                  _pickedImage = image;
                  _localAvatarKey = DateTime.now().millisecondsSinceEpoch; // Update local key
                });
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // --- FUNGSI UPDATE YANG SUDAH DIPERBAIKI (Penanganan Error JSON) ---
  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      var uri = Uri.parse('${ApiService.baseUrl}update_profile.php');
      var request = http.MultipartRequest('POST', uri);

      request.fields['id'] = UserSession.id!;
      request.fields['nama_lengkap'] = _namaLengkapController.text;
      request.fields['username'] = _usernameController.text;

      if (_pickedImage != null) {
        if (kIsWeb) {
          var bytes = await _pickedImage!.readAsBytes();
          var multipartFile = http.MultipartFile.fromBytes(
            'profile_image',
            bytes,
            filename: _pickedImage!.name,
          );
          request.files.add(multipartFile);
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_image',
              _pickedImage!.path,
            ),
          );
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      // Cek jika balasan BUKAN 200 (OK)
      if (response.statusCode != 200) {
        throw Exception('Server mengembalikan error HTTP: ${response.statusCode}');
      }
      
      // --- PENANGANAN JSON YANG LEBIH BAIK ---
      String responseBody = response.body.trim();
      
      // Deteksi jika server mengembalikan HTML/Warning (seperti "<br />...")
      if (responseBody.startsWith('<') || responseBody.startsWith('<b>') || responseBody.isEmpty) {
        throw Exception('Respons server tidak valid. Mungkin ada PHP Warning/Error. Respons: $responseBody');
      }

      final data = json.decode(responseBody);

      if (data['status'] == 'success') {
        UserSession.namaLengkap = _namaLengkapController.text;
        UserSession.username = _usernameController.text;
        
        String? returnedImageUrl;
        
        if (data['data'] != null && data['data']['profile_image_url'] != null) {
          returnedImageUrl = data['data']['profile_image_url'] as String;
          // Asumsi ApiService.normalizeImageUrl sudah benar
          UserSession.profileImageUrl = returnedImageUrl;
        }

        // *** TAMBAHAN PENTING: UPDATE CACHE KEY ***
        // Paksa semua widget avatar lainnya untuk reload
        UserSession.cacheKey = UserSession.cacheKey + 1; 

        // Simpan semua perubahan sesi (termasuk cacheKey)
        await UserSession.saveData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        // Kirim hasil (URL baru atau true) kembali ke Home Screen
        Navigator.pop(context, true); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: ${data['message']}')),
        );
      }
    } catch (e) {
      // Menangkap semua error: HTTP, JSON Decode, atau Exception buatan sendiri
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      print('Update Profile Error: $e'); // Log error untuk debugging
    } finally {
      setState(() {
        _isLoading = false;
        // Reset _pickedImage setelah proses selesai
        _pickedImage = null; 
      });
    }
  }

  // Helper untuk mendapatkan ImageProvider dari URL sesi (Gambar lama/yang sudah diupload)
  ImageProvider? _getSessionImageProvider() {
    // Tambahkan cacheKey ke URL sesi agar gambar lama yang baru di-update tetap ter-refresh di layar ini
    if (UserSession.profileImageUrl != null &&
        UserSession.profileImageUrl!.isNotEmpty) {
      // Menggunakan logika separator yang sama seperti di ProfileAvatarWidget
      final String separator = UserSession.profileImageUrl!.contains('?') ? '&' : '?';
      final String finalUrl = '${UserSession.profileImageUrl}$separator${UserSession.cacheKey}';
      return NetworkImage(finalUrl);
    }
    return null;
  }

  // --- FUNGSI _buildAvatar() YANG DIPERBAIKI ---
  Widget _buildAvatar() {
    ImageProvider? finalProvider;
    Widget? childWidget;

    if (_pickedImage != null) {
      if (kIsWeb) {
        // KASUS WEB: Langsung pakai NetworkImage (blob URL dari XFile)
        finalProvider = NetworkImage(_pickedImage!.path, headers: const {'Cache-Control': 'no-cache'});
      } else {
        // KASUS MOBILE: Membaca bytes secara sinkron (lebih cepat di mobile)
        finalProvider = MemoryImage(File(_pickedImage!.path).readAsBytesSync());
      }
    } else {
      // KASUS LAINNYA: Ambil dari sesi (URL lama/terbaru)
      finalProvider = _getSessionImageProvider();
    }
    
    // Fallback jika tidak ada gambar
    if (finalProvider == null) {
        childWidget = Icon(Icons.person, size: 60, color: Colors.grey.shade400);
    }

    // Menggunakan _localAvatarKey untuk merebuild avatar di layar ini saat ganti gambar
    return CircleAvatar(
      key: ValueKey('local-avatar-$_localAvatarKey'), 
      radius: 60,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: finalProvider,
      child: childWidget,
    );
  }
  // ----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    _buildAvatar(),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: Colors.blue.shade600,
                        clipBehavior: Clip.hardEdge,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: _pickImage,
                          child: const Padding(
                            padding: EdgeInsets.all(6.0),
                            child: Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // ... (TextFormField Nama Lengkap)
              TextFormField(
                controller: _namaLengkapController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama Lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // ... (TextFormField Username)
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_circle),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // ... (ElevatedButton Simpan Perubahan)
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
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