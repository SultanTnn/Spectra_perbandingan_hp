import 'package:flutter/material.dart';

class ProfileAvatarWidget extends StatelessWidget {
  final double radius;
  final Color primaryColor;
  final String? profileUrl;
  final int cacheKey;
  final bool sessionLoaded;

  const ProfileAvatarWidget({
    super.key,
    required this.radius,
    required this.primaryColor,
    required this.profileUrl,
    required this.cacheKey,
    required this.sessionLoaded,
  });

  @override
  Widget build(BuildContext context) {
    final double size = radius * 2;
    // Cek apakah URL ada dan sesi sudah dimuat
    final bool hasValidUrl = profileUrl != null && profileUrl!.isNotEmpty && sessionLoaded;
    // Tambahkan cache buster key untuk memaksa reload gambar
    final String finalUrl = '$profileUrl?cb=$cacheKey';

    return CircleAvatar(
      key: ValueKey(cacheKey),
      radius: radius,
      backgroundColor: Colors.white,
      child: hasValidUrl
          ? ClipOval(
              child: Image.network(
                finalUrl,
                fit: BoxFit.cover,
                width: size,
                height: size,
                errorBuilder: (context, error, stackTrace) {
                  // Tampilkan ikon error jika gambar gagal dimuat (misalnya URL salah)
                  return Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red.shade700,
                    size: radius * 0.8,
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  // Tampilkan indikator loading saat gambar sedang diunduh
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      color: primaryColor,
                    ),
                  );
                },
              ),
            )
          // Fallback utama jika tidak ada URL profil
          : Icon(Icons.person, color: primaryColor, size: radius * 0.8),
    );
  }
}

// Widget khusus untuk Drawer Header
class ProfileDrawerHeader extends StatelessWidget {
  final Color dynamicPrimary;
  final Color dynamicAccent;
  final String? namaLengkap;
  final String? username;
  final String? profileUrl;
  final int cacheKey;
  final bool sessionLoaded;
  final String Function(String) getTranslatedText;

  const ProfileDrawerHeader({
    super.key,
    required this.dynamicPrimary,
    required this.dynamicAccent,
    required this.namaLengkap,
    required this.username,
    required this.profileUrl,
    required this.cacheKey,
    required this.sessionLoaded,
    required this.getTranslatedText,
  });

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 15.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [dynamicPrimary, dynamicAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menggunakan ProfileAvatarWidget
          ProfileAvatarWidget(
            radius: 30,
            primaryColor: dynamicPrimary,
            profileUrl: profileUrl,
            cacheKey: cacheKey,
            sessionLoaded: sessionLoaded,
          ),
          const SizedBox(height: 12),
          Text(
            namaLengkap ??
                (sessionLoaded
                    ? getTranslatedText('selamat_datang')
                    : 'Memuat...'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            username ?? getTranslatedText('user_aktif'),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}