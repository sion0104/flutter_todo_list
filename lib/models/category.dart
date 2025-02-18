enum Category {
  none,
  work,
  personal,
  study,
}

extension CategoryExtension on Category {
  String get name => toString().split('.').last;

  static Category fromString(String category) {
    return Category.values.firstWhere(
      (e) => e.toString().split('.').last == category,
      orElse: () => Category.none,
    );
  }
}
