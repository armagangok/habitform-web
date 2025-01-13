import '../core.dart';

class CustomDecoration {
  const CustomDecoration._();

  static BoxDecoration get backgroundGradiend => const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xff181A20),
            Color(0xff181A20),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      );
}
