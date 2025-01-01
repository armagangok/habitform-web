extension EasyNulCheckString on String? {
  bool get isNull => this == null;

  bool get isNotNull => this != null;
  
  bool get isNotNullAndNotEmpty {
    if (this == null) return false;
    if (this!.isEmpty) return false;
    return true;
  }
}

extension EasyNullCheckList on List? {
  bool get isNull => this == null;
  bool get isNotNull => this != null;
  bool get isNotNullAndNotEmpty => this != null && this!.isNotEmpty ? true : false;
}

extension EasyList on List {
  bool isLast(int index) => length - 1 == index;
}
