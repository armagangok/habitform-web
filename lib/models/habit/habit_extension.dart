import '../completion_entry/completion_entry.dart';
import 'habit_model.dart';
import 'habit_status.dart';

extension EasyHabitStatus on Habit {
  bool get isActive => status == HabitStatus.active;
  bool get isArchived => status == HabitStatus.archived;
}

extension MigrationHelper on Habit {
  /// Bu metot, eski formatdaki tamamlanma tarihlerini (completionDates)
  /// yeni formattaki CompletionEntry yapısına dönüştürür.
  ///
  /// Adım 1: Her bir tarihi döngü ile işle
  /// Adım 2: Her tarih için normalize edilmiş bir tarih ID'si oluştur (YYYY-MM-DD formatında)
  /// Adım 3: Bu ID'yi hem Map anahtarı, hem de CompletionEntry içindeki ID olarak kullan
  /// Adım 4: Tüm dönüştürmeleri bir Map olarak döndür
  Map<String, CompletionEntry> toCompletionEntry(List<DateTime> completionDates) {
    // Sonuç olarak döndürülecek Map<String, CompletionEntry>
    return Map.fromEntries(
      // Adım 1: Eski completionDates listesindeki her tarihi dönüştür
      completionDates.map(
        (date) {
          // Adım 2: Tarih tabanlı benzersiz bir ID oluştur (yyyy-MM-dd formatında)
          // Saat, dakika, saniye bilgilerini kaldırarak sadece gün bazında normalize et
          final normalizedDate = DateTime(date.year, date.month, date.day);
          // "2023-06-15T00:00:00.000" -> "2023-06-15" formatına dönüştür
          final dateKey = normalizedDate.toIso8601String().split('T')[0];

          // Adım 3: Her tarih için bir Map.Entry oluştur
          return MapEntry(
            dateKey, // Map'in anahtarı olarak tarih ID'sini kullan
            // Adım 4: Yeni CompletionEntry nesnesi oluştur
            CompletionEntry(
              id: dateKey, // CompletionEntry ID'si olarak da aynı tarih ID'sini kullan
              date: date, // Orijinal tarihi sakla
              isCompleted: true, // Migrasyon sırasında tüm tarihler tamamlanmış olarak işaretlenir
            ),
          );
        },
      ),
    );
  }

  /// Eski model alışkanlık nesnesini, yeni modele dönüştürür.
  ///
  /// Bu metot, önceden dönüştürülmüş completions Map'ini kullanarak
  /// alışkanlığın yeni bir kopyasını oluşturur ve eski completionDates'i null yapar.
  Habit toNewHabitModel(Map<String, CompletionEntry> completions) {
    return copyWith(
      completions: completions, // Yeni tamamlanma kayıtlarını ekle
      completionDates: null, // Eski tamamlanma tarihlerini temizle
    );
  }
}
