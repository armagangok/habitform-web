import 'package:intl/intl.dart';

extension DateTimeFormat on DateTime {
  String toHHMM() {
    return DateFormat('HH:mm').format(this);
  }
}
