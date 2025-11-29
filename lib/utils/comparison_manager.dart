// comparison_manager.dart

class ComparisonManager {
  // Daftar HP yang dipilih untuk perbandingan, bisa dari brand manapun.
  static List<Map<String, String>> selectedPhones = [];

  static bool isSelected(String id) {
    return selectedPhones.any((p) => p['id'] == id);
  }

  static void toggleSelection(String brand, String id) {
    final phoneKey = {'brand': brand, 'id': id};
    final isAlreadySelected = isSelected(id);

    if (isAlreadySelected) {
      // Hapus berdasarkan ID
      selectedPhones.removeWhere((p) => p['id'] == id);
    } else if (selectedPhones.length < 4) {
      // Tambahkan jika belum mencapai batas 3
      selectedPhones.add(phoneKey);
    }
    // Jika sudah 3 dan bukan yang terpilih, tidak dilakukan apa-apa.
  }

  static void clearSelection() {
    selectedPhones.clear();
  }
}
