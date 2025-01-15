import '../../add_habit/enum/days_enum.dart';

extension DaysExtension on Days {
  String get capitalized {
    // İlk harfi büyük yapmak için:
    final name = this.name; // Enum adını al
    return name[0].toUpperCase() + name.substring(1); // İlk harfi büyüt ve geri kalanı ekle
  }
}
