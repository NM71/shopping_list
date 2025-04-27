import 'dart:ui';

enum Categories {
  dairy,
  fruit,
  meat,
  vegetables,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other,
}

class Category {
  final String title;
  final Color color;

  const Category(this.title, this.color);
}
