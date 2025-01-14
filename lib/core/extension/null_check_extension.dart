extension EasyList on List {
  bool isLast(int index) => length - 1 == index;
}

extension EasyNullCheck on dynamic {
  bool get isNull => this == null;
  bool get isNotNull => this != null;
  bool get isNotNullAndNotEmpty => this?.isNotEmpty ?? false;
  bool get isNotNullAndEmpty => this?.isEmpty ?? false;
  bool get isNullOrEmpty => this == null || this.isEmpty;
}
