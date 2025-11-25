import 'package:flutter/material.dart';
import 'package:flutter_application_1/service/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; 
import 'package:google_fonts/google_fonts.dart';
import 'register_screen.dart';
import '../home/screen_home.dart';
import '../../utils/session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  // Warna Tema
  final primaryColor = const Color(0xFF553C9A);
  final secondaryColor = const Color(0xFF6C63FF);

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = Uri.parse(ApiService.login);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
        }),
      );

      if (!mounted) return;

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final String userId = data['data']['id'].toString();
        final String userUsername = data['data']['username'];
        final String userNamaLengkap = data['data']['nama_lengkap'];
        final String userRole = data['data']['role'];
        final String? userProfileImage = data['data']['profile_image_url'];

        UserSession.id = userId;
        UserSession.username = userUsername;
        UserSession.namaLengkap = userNamaLengkap;
        UserSession.role = userRole;
        UserSession.profileImageUrl = userProfileImage;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang, $userNamaLengkap!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login Gagal: ${data['message']}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }
    } catch (e) {
      String errorMessage;
      if (e.toString().contains('Failed host lookup') ||
          e.toString().contains('Connection refused')) {
        errorMessage =
            'Gagal terhubung ke server. Cek koneksi internet atau IP Address.';
      } else {
        errorMessage = 'Terjadi kesalahan: $e';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
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
                    const SizedBox(height: 40), // Jarak untuk tombol back
                    // --- KARTU LOGIN GLASSMORPHISM ---
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        40,
                      ), // Sudut sangat bulat
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 15,
                          sigmaY: 15,
                        ), // Efek Blur Kaca
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 40,
                          ),
                          decoration: BoxDecoration(
                            // Warna putih semi-transparan
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
                                // Ikon Gembok Lucu
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
                                  child: Icon(
                                    Icons.lock_person_rounded,
                                    size: 45,
                                    color: secondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Judul SPECTRA
                                Text(
                                  'SPECTRA',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                Text(
                                  'Selamat Datang Kembali!',
                                  style: GoogleFonts.nunito(
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 30),

                                // Field Username
                                _buildTextField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  icon: Icons.person_rounded,
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

                                // Tombol Login
                                SizedBox(
                                  width: double.infinity,
                                  height: 55,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryColor,
                                      foregroundColor: Colors.white,
                                      elevation: 8,
                                      shadowColor: primaryColor.withOpacity(
                                        0.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          30,
                                        ), // Tombol kapsul
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
                                            'MASUK',
                                            style: GoogleFonts.nunito(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Link Daftar
                                Column(
                                  children: [
                                    Text(
                                      "Belum punya akun?",
                                      style: GoogleFonts.nunito(
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "Daftar Sekarang",
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

            // 2. TOMBOL KEMBALI (DI POJOK KIRI ATAS, LUAR CARD)
            Positioned(
              top: 10,
              left: 10,
              child: SafeArea(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2), // Glass effect
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

  // Helper Widget untuk Text Field yang Lucu
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      style: TextStyle(fontWeight: FontWeight.w700, color: primaryColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Masukkan ${label.toLowerCase()}',
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: TextStyle(
          color: primaryColor,
          fontWeight: FontWeight.bold,
        ),
        prefixIcon: Icon(icon, color: secondaryColor),
        filled: true,
        fillColor: Colors.white, // Putih solid agar kontras di atas kaca
        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), // Sangat bulat
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: secondaryColor, width: 2),
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
        return null;
      },
    );
  }
}

// --- ANIMATED BACKGROUND CLASS ---
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