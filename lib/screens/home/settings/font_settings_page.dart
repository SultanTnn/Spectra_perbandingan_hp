import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_language.dart';
import 'app_font.dart'; 

class FontSettingsPage extends StatelessWidget {
  const FontSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Skema Warna Dinamis
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF0F2F5);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final primaryColor = isDark ? const Color(0xFF9370DB) : const Color(0xFF6C5CE7);
    final secondaryText = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          AppLanguage.get('pengaturan_tampilan') != 'pengaturan_tampilan'
              ? AppLanguage.get('pengaturan_tampilan')
              : 'Tampilan',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: primaryColor),
            tooltip: AppLanguage.get('reset'),
            onPressed: () => AppFont.resetSettings(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: AppFont.fontNotifier,
        builder: (context, currentFont, _) {
          return ValueListenableBuilder<double>(
            valueListenable: AppFont.fontSizeNotifier,
            builder: (context, currentSize, _) {
              return Column(
                children: [
                  // --- BAGIAN 1: AREA PREVIEW INTERAKTIF ---
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            Text(
                              AppLanguage.get('pratinjau').toUpperCase(),
                              style: TextStyle(
                                color: secondaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 15),

                            // Kartu Simulasi Artikel
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header Kartu (Mockup User/Category)
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: primaryColor.withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          "NEWS",
                                          style: GoogleFonts.getFont(
                                            currentFont,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: primaryColor,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(Icons.bookmark_border_rounded,
                                          color: secondaryText, size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Judul (Title) dengan Animasi
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutExpo,
                                    style: GoogleFonts.getFont(
                                      currentFont,
                                      fontSize: currentSize + 6, // Judul lebih besar
                                      fontWeight: FontWeight.w800,
                                      color: textColor,
                                      height: 1.2,
                                    ),
                                    child: Text(AppLanguage.get('contoh_judul')),
                                  ),
                                  const SizedBox(height: 16),

                                  // Isi (Body) dengan Animasi
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOutExpo,
                                    style: GoogleFonts.getFont(
                                      currentFont,
                                      fontSize: currentSize,
                                      color: textColor.withOpacity(0.8),
                                      height: 1.6,
                                    ),
                                    child: Text(AppLanguage.get('contoh_teks')),
                                  ),
                                  
                                  const SizedBox(height: 20),
                                  Divider(color: secondaryText!.withOpacity(0.2)),
                                  const SizedBox(height: 10),
                                  
                                  // Footer Kartu
                                  Row(
                                    children: [
                                      Text(
                                        "5 min read",
                                        style: TextStyle(color: secondaryText, fontSize: 12),
                                      ),
                                      const Spacer(),
                                      Text(
                                        "$currentFont • ${currentSize.toInt()}px",
                                        style: TextStyle(
                                          color: primaryColor, 
                                          fontSize: 12, 
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // --- BAGIAN 2: CONTROL DECK (PANEL KONTROL) ---
                  Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- SLIDER SIZE ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLanguage.get('ukuran_font'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: bgColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${currentSize.toInt()}",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildIconBtn(Icons.text_fields, 18, secondaryText,
                                () => AppFont.changeFontSize((currentSize - 2).clamp(12, 30))),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: primaryColor,
                                  inactiveTrackColor: primaryColor.withOpacity(0.15),
                                  thumbColor: Colors.white,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 12, elevation: 4),
                                  overlayColor: primaryColor.withOpacity(0.1),
                                  trackHeight: 6,
                                ),
                                child: Slider(
                                  value: currentSize,
                                  min: 12,
                                  max: 30,
                                  divisions: 18,
                                  onChanged: (val) => AppFont.changeFontSize(val),
                                ),
                              ),
                            ),
                            _buildIconBtn(Icons.text_fields, 26, textColor,
                                () => AppFont.changeFontSize((currentSize + 2).clamp(12, 30))),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // --- FONT SELECTOR ---
                        Text(
                          AppLanguage.get('jenis_font'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 50,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: AppFont.availableFonts.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final fontName = AppFont.availableFonts[index];
                              final isSelected = fontName == currentFont;

                              return GestureDetector(
                                onTap: () => AppFont.changeFontFamily(fontName),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: isSelected ? primaryColor : Colors.transparent,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryColor
                                          : secondaryText!.withOpacity(0.3),
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    fontName,
                                    style: GoogleFonts.getFont(
                                      fontName,
                                      textStyle: TextStyle(
                                        color: isSelected ? Colors.white : textColor,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Helper Widget untuk tombol kecil di samping slider
  Widget _buildIconBtn(IconData icon, double size, Color? color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: Colors.transparent,
        child: Icon(icon, size: size, color: color),
      ),
    );
  }
}