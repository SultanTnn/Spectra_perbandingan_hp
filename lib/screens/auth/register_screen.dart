import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Untuk efek Glassmorphism
import 'package:google_fonts/google_fonts.dart';
import '../../service/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // --- DEFINISI WARNA (Dibuat Static agar tidak Null) ---
  static const Color primaryColor = Color(0xFF553C9A);
  static const Color secondaryColor = Color(0xFF6C63FF);
  // ignore: unused_field
  static const Color blueColor = Color(0xFF0175C2);
  // ----------------------------------------------------

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(ApiService.register);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nama_lengkap': _namaController.text,
          'username': _usernameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
        Navigator.pop(context); // Kembali ke Login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrasi Gagal: ${data['message']}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Animasi
      body: AnimatedGradientBackground(
        child: Stack(
          children: [
            // 1. KONTEN UTAMA (CENTERED)
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 60,
                    ), // Jarak atas agar tidak ketabrak tombol back
                    // --- KARTU REGISTER GLASSMORPHISM ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 40,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(40),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.6),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 25,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                // Ikon Daftar Lucu
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: secondaryColor.withOpacity(0.3),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.person_add_rounded,
                                    size: 45,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Judul
                                Text(
                                  'Buat Akun',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'Gabung bersama SPECTRA!',
                                  style: GoogleFonts.nunito(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Field Nama Lengkap
                                _buildTextField(
                                  controller: _namaController,
                                  label: 'Nama Lengkap',
                                  icon: Icons.badge_rounded,
                                ),
                                const SizedBox(height: 16),

                                // Field Username
                                _buildTextField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  icon: Icons.person_rounded,
                                ),
                                const SizedBox(height: 16),

                                // Field Email
                                _buildTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email_rounded,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 16),

                                // Field Password
                                _buildTextField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.key_rounded,
                                  isPassword: true,
                                ),

                                const SizedBox(height: 30),

                                // Tombol Daftar
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _register,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: primaryColor.withOpacity(
                                        0.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 3,
                                            ),
                                          )
                                        : Text(
                                            'DAFTAR',
                                            style: GoogleFonts.nunito(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // Link Login
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Sudah punya akun? ",
                                      style: GoogleFonts.nunito(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Text(
                                        "Masuk Saja",
                                        style: GoogleFonts.nunito(
                                          color: secondaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          decoration: TextDecoration.underline,
                                          decorationColor: secondaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      '© 2025 Kelompok 3',
                      style: GoogleFonts.nunito(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. TOMBOL KEMBALI (POJOK KIRI ATAS)
            Positioned(
              top: 10,
              left: 10,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                    ),
                    tooltip: "Kembali",
                    splashRadius: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget untuk Text Field yang Seragam
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w700, color: primaryColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Masukkan ${label.toLowerCase()}',
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: secondaryColor),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: secondaryColor, width: 2),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                  color: Colors.grey[400],
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        if (label == 'Password' && value.length < 6) {
          return 'Password minimal 6 karakter';
        }
        if (label == 'Email' &&
            (!value.contains('@') || !value.contains('.'))) {
          return 'Format email tidak valid';
        }
        return null;
      },
    );
  }
}

// --- ANIMATED BACKGROUND CLASS (Sama seperti Welcome/Login) ---
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
  late Animation<Alignment> _topAlignmentAnimation;
  late Animation<Alignment> _bottomAlignmentAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );
    _topAlignmentAnimation = TweenSequence<Alignment>([
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

    _bottomAlignmentAnimation = TweenSequence<Alignment>([
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

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const color1 = Color(0xFF553C9A);
    const color2 = Color(0xFF6C63FF);
    const color3 = Color(0xFF0175C2);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _topAlignmentAnimation.value,
              end: _bottomAlignmentAnimation.value,
              colors: const [color1, color2, color3],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}
