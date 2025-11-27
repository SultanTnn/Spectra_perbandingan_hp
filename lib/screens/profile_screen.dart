// profile_screen.dart (Versi BARU - Mendukung Web & Mobile)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/session.dart';
import '../service/api_service.dart';

// Import untuk deteksi platform (Web atau Mobile)
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

// Import package untuk file
// import 'dart:io'; // Tidak dipakai di versi Web-safe ini
import 'package:image_picker/image_picker.dart';

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

  @override
  void initState() {
    super.initState();
    _namaLengkapController.text = UserSession.namaLengkap ?? '';
    _usernameController.text = UserSession.username ?? '';
  }

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

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
                });
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  // --- FUNGSI UPDATE YANG SUDAH DIPERBAIKI (Web + Mobile) ---
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
          // LOGIKA UNTUK WEB (Browser)
          var bytes = await _pickedImage!.readAsBytes();
          var multipartFile = http.MultipartFile.fromBytes(
            'profile_image', 
            bytes,
            filename: _pickedImage!.name,
          );
          request.files.add(multipartFile);
          
        } else {
          // LOGIKA UNTUK MOBILE (Android/iOS)
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
         setState(() { _isLoading = false; });
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text('Error dari server: ${response.statusCode}')),
         );
         return;
      }

      final data = json.decode(response.body);

      if (data['status'] == 'success') {
        UserSession.namaLengkap = _namaLengkapController.text;
        UserSession.username = _usernameController.text;
        String? returned;
        if (data['data'] != null && data['data']['profile_image_url'] != null) {
          returned = data['data']['profile_image_url'] as String;
          // Normalize: if returned is a relative path, fix leading slash and prefix
          returned = ApiService.normalizeImageUrl(returned);
          UserSession.profileImageUrl = returned;
        }
        // Always save updates to session (even if image wasn't returned)
        await UserSession.saveData();
        // Debug log
        print('[ProfileScreen] Updated UserSession.profileImageUrl=${UserSession.profileImageUrl}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
        // Return returned image url (if any) so caller can update UI immediately
        Navigator.pop(context, returned ?? true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: ${data['message']}')),
        );
      }
    } catch (e) {
      // Ini akan menangkap error JSON <br>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Returns ImageProvider or null — null indicates no image to set
  ImageProvider? _getImageProvider() {
    if (_pickedImage != null) {
      // 'path' dari XFile di web adalah 'blob:...' URL
      if (kIsWeb) {
        return NetworkImage(_pickedImage!.path);
      }
      // For non-web, we'll read as bytes in a FutureBuilder — avoid using dart:io import
      return null;
    }
    if (UserSession.profileImageUrl != null && UserSession.profileImageUrl!.isNotEmpty) {
      return NetworkImage(UserSession.profileImageUrl!);
    }
    return null; // No image available
  }

  Widget _buildAvatar() {
    // If picked image is available and we're on the web, just use network image
    if (_pickedImage != null && kIsWeb) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(_pickedImage!.path),
      );
    }

    // If picked image on mobile (not web) we need to load bytes asynchronously
    if (_pickedImage != null && !kIsWeb) {
      return FutureBuilder<Uint8List?>(
        future: _pickedImage!.readAsBytes(),
        builder: (context, snapshot) {
          final ImageProvider? provider = (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null)
              ? MemoryImage(snapshot.data!)
              : (_getImageProvider());

          return CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: provider,
            child: (provider == null)
                ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                : null,
          );
        },
      );
    }

    // No picked image or mobile with no picked image — use session URL if exists
    final provider = _getImageProvider();
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: provider,
      child: (provider == null) ? Icon(Icons.person, size: 60, color: Colors.grey.shade400) : null,
    );
  }

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
                    // Use helper to build the avatar safely for web & mobile
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
                            child: Icon(Icons.edit,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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