import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import '../../service/api_service.dart';

class CreatePhoneScreen extends StatefulWidget {
  final String brand;
  const CreatePhoneScreen({super.key, required this.brand});

  @override
  State<CreatePhoneScreen> createState() => _CreatePhoneScreenState();
}

class _CreatePhoneScreenState extends State<CreatePhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
      final url = Uri.parse(ApiService.createPhone);

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
          'image_url': '',
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error koneksi: $e')));
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
    final primaryColor = const Color(0xFF553C9A);
    final secondaryColor = const Color(0xFF6C63FF);
    final accentColor = const Color(0xFF0175C2);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Tambah HP ${widget.brand.toUpperCase()}',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withOpacity(0.9),
              secondaryColor.withOpacity(0.9),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(
            top: 80,
            left: 16,
            right: 16,
            bottom: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah Data ${widget.brand}',
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tambahkan smartphone baru ke dalam database',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Form Fields Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildModernTextField(
                        controller: _namaModelController,
                        label: 'Nama Model',
                        icon: Icons.phone_iphone_rounded,
                        validator: (value) => value == null || value.isEmpty
                            ? 'Nama Model tidak boleh kosong'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _priceController,
                        label: 'Harga',
                        icon: Icons.attach_money_rounded,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _bodyController,
                        label: 'Body',
                        icon: Icons.shape_line_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _displayController,
                        label: 'Display',
                        icon: Icons.desktop_mac_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _platformController,
                        label: 'Platform',
                        icon: Icons.computer_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _memoryController,
                        label: 'Memory',
                        icon: Icons.memory_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _mainCameraController,
                        label: 'Main Camera',
                        icon: Icons.camera_alt_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _selfieCameraController,
                        label: 'Selfie Camera',
                        icon: Icons.camera_front_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _commsController,
                        label: 'Comms',
                        icon: Icons.wifi_calling_3_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _featuresController,
                        label: 'Features',
                        icon: Icons.featured_play_list_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildModernTextField(
                        controller: _batteryController,
                        label: 'Battery',
                        icon: Icons.battery_full_rounded,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Button
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [secondaryColor, accentColor],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: secondaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _savePhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.white.withOpacity(0.8),
                              ),
                            ),
                          )
                        : Text(
                            'Simpan Data Baru',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final primaryColor = const Color(0xFF553C9A);
    final secondaryColor = const Color(0xFF6C63FF);

    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.nunito(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
        ),
        floatingLabelStyle: GoogleFonts.nunito(
          color: secondaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: secondaryColor, size: 22),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
