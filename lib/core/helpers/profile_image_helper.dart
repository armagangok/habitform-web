// import 'dart:io';

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import '../core.dart';

// class ProfileImageHelper {
//   static final ProfileImageHelper shared = ProfileImageHelper._();

//   ProfileImageHelper._();

//   // Profil resmi cache anahtarı
//   static const String _profileImageCacheKey = 'cached_profile_image_path';

//   // Profil resminin cache'lenmiş yolunu almak için
//   Future<String?> getCachedProfileImagePath() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_profileImageCacheKey);
//   }

//   // Profil resmini cache'lemek için
//   Future<String?> cacheProfileImage(String imageUrl, {String? userId}) async {
//     try {
//       // Resmi indir
//       final response = await http.get(Uri.parse(imageUrl));
//       if (response.statusCode != 200) {
//         LogHelper.shared.errorPrint('Profil resmi indirilemedi: ${response.statusCode}');
//         return null;
//       }

//       // Resmi yerel dosya sistemine kaydet
//       final directory = await getApplicationDocumentsDirectory();
//       final userIdToUse = userId ?? FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
//       final imagePath = '${directory.path}/profile_image_$userIdToUse.jpg';

//       final file = File(imagePath);
//       await file.writeAsBytes(response.bodyBytes);

//       // Cache yolunu kaydet
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(_profileImageCacheKey, imagePath);

//       LogHelper.shared.debugPrint('Profil resmi cache\'lendi: $imagePath');
//       return imagePath;
//     } catch (e) {
//       LogHelper.shared.errorPrint('Profil resmi cache\'lenirken hata oluştu: $e');
//       return null;
//     }
//   }

//   // Profil resmi cache'ini temizlemek için
//   Future<void> clearCachedProfileImage() async {
//     try {
//       // Cache yolunu al
//       final cachedPath = await getCachedProfileImagePath();
//       if (cachedPath != null) {
//         // Dosyayı sil
//         final file = File(cachedPath);
//         if (await file.exists()) {
//           await file.delete();
//           LogHelper.shared.debugPrint('Profil resmi dosyası silindi: $cachedPath');
//         }
//       }

//       // SharedPreferences'dan cache anahtarını sil
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove(_profileImageCacheKey);
//       LogHelper.shared.debugPrint('Profil resmi cache referansı silindi');
//     } catch (e) {
//       LogHelper.shared.errorPrint('Profil resmi cache\'i temizlenirken hata oluştu: $e');
//     }
//   }

//   // Profil resmini görüntülemek için widget
//   Widget getProfileImage({
//     required String? photoURL,
//     required double size,
//     required Color backgroundColor,
//     required Widget placeholder,
//     String? userId,
//   }) {
//     return FutureBuilder<String?>(
//       future: getCachedProfileImagePath(),
//       builder: (context, snapshot) {
//         // Eğer cache'lenmiş resim varsa ve photoURL de varsa
//         if (snapshot.hasData && snapshot.data != null && photoURL != null) {
//           final cachedImagePath = snapshot.data!;

//           return Container(
//             width: size,
//             height: size,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: backgroundColor,
//               image: DecorationImage(
//                 image: _getImageProvider(cachedImagePath, photoURL),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           );
//         }

//         // Eğer photoURL varsa ama cache yoksa, resmi cache'le ve göster
//         if (photoURL != null) {
//           // Resmi cache'leme işlemini başlat
//           cacheProfileImage(photoURL, userId: userId);

//           return Container(
//             width: size,
//             height: size,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: backgroundColor,
//               image: DecorationImage(
//                 image: NetworkImage(photoURL),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           );
//         }

//         // Eğer resim yoksa placeholder göster
//         return Container(
//           width: size,
//           height: size,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: backgroundColor,
//           ),
//           child: placeholder,
//         );
//       },
//     );
//   }

//   // Resim provider'ını seçmek için yardımcı metod
//   ImageProvider _getImageProvider(String cachedPath, String photoURL) {
//     final file = File(cachedPath);

//     // Önce cache'lenmiş dosyayı kontrol et
//     if (file.existsSync()) {
//       return FileImage(file);
//     }

//     // Cache yoksa veya geçersizse, ağdan yükle
//     return NetworkImage(photoURL);
//   }
// }
