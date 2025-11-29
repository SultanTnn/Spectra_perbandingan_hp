import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_language.dart';
import 'font_settings_page.dart';
import 'storage_settings_page.dart';
import 'about_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemeStatus();
  }

  // Memuat status Dark Mode dari SharedPreferences
  Future<void> _loadThemeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool(AppLanguage.keyDarkMode) ?? false;
    });
  }

  // Menyimpan status Dark Mode dan memberikan nilai balik (pop) agar HomeScreen tahu ada perubahan
  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppLanguage.keyDarkMode, value);
    setState(() {
      _isDarkMode = value;
    });
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(AppLanguage.get('pilih_bahasa')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(context, 'Indonesia', 'id', '🇮🇩'),
              _buildLanguageOption(context, 'English', 'en', '🇺🇸'),
              _buildLanguageOption(context, 'Melayu', 'ms', '🇲🇾'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String name, String code, String flag) {
    final isSelected = AppLanguage.languageNotifier.value == code;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Theme.of(context).primaryColor : null,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : null,
      onTap: () {
        AppLanguage.changeLanguage(code);
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Warna background disesuaikan dengan tema
    final bgColor = _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final cardColor = _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = _isDarkMode ? Colors.white : const Color(0xFF333333);

    return WillPopScope(
      // Saat tombol back ditekan, kirim sinyal 'true' jika ada perubahan yang perlu direload di home
      onWillPop: () async {
        Navigator.pop(context, true); 
        return false;
      },
      child: ValueListenableBuilder<String>(
        valueListenable: AppLanguage.languageNotifier,
        builder: (context, languageCode, child) {
          return Scaffold(
            backgroundColor: bgColor,
            appBar: AppBar(
              title: Text(
                AppLanguage.get('pengaturan'),
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: textColor),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: UMUM ---
                  _buildSectionHeader(AppLanguage.get('umum'), textColor),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          context,
                          icon: Icons.language,
                          iconColor: Colors.blueAccent,
                          title: AppLanguage.get('bahasa_aplikasi'),
                          subtitle: languageCode == 'id'
                              ? 'Bahasa Indonesia'
                              : (languageCode == 'ms' ? 'Bahasa Melayu' : 'English'),
                          onTap: () => _showLanguageDialog(context),
                        ),
                        _buildDivider(cardColor),
                        _buildSettingsTile(
                          context,
                          icon: _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          iconColor: Colors.orangeAccent,
                          title: AppLanguage.get('mode_tampilan'),
                          trailing: Switch.adaptive(
                            value: _isDarkMode,
                            activeColor: Colors.blueAccent,
                            onChanged: (val) => _toggleDarkMode(val),
                          ),
                        ),
                        _buildDivider(cardColor),
                        _buildSettingsTile(
                          context,
                          icon: Icons.text_fields,
                          iconColor: Colors.purpleAccent,
                          title: AppLanguage.get('font_size'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const FontSettingsPage()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SECTION 2: DATA & INFO ---
                  _buildSectionHeader(AppLanguage.get('data_sinkronisasi'), textColor),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          context,
                          icon: Icons.storage_rounded,
                          iconColor: Colors.green,
                          title: AppLanguage.get('storage_cache'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StorageSettingsPage()),
                          ),
                        ),
                        _buildDivider(cardColor),
                        _buildSettingsTile(
                          context,
                          icon: Icons.info_outline_rounded,
                          iconColor: Colors.grey,
                          title: AppLanguage.get('tentang_aplikasi'),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AboutPage()),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      "Version 1.0.0 (Build 102)",
                      style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: textColor.withOpacity(0.6),
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Divider(height: 1, thickness: 0.5, indent: 60, color: Colors.grey.withOpacity(0.3));
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    // Deteksi tema untuk warna text tile
    final isDark = Theme.of(context).brightness == Brightness.dark || _isDarkMode;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: textColor.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Trailing Widget (Arrow or Switch)
              if (trailing != null)
                trailing
              else
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }
}