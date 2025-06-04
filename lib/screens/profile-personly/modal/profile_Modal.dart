class Package {
  final String title;
  final String titleAr;
  final String currency;
  final double price;
  final int days;
  final int allowedLessons;

  Package({
    required this.title,
    required this.titleAr,
    required this.currency,
    required this.price,
    required this.days,
    required this.allowedLessons,
  });

  // دالة لتحويل JSON إلى كائن Package
  factory Package.fromJson(Map<String, dynamic> json) {
    return Package(
      title: json['title'],
      titleAr: json['title_ar'],
      currency: json['currency'],
      price: json['price'].toDouble(),
      days: json['days'],
      allowedLessons: json['allowed_lessons'],
    );
  }

  // دالة لتحويل كائن Package إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'title_ar': titleAr,
      'currency': currency,
      'price': price,
      'days': days,
      'allowed_lessons': allowedLessons,
    };
  }
}

class Rank {
  final String name;
  final String nameAr;
  final int percent;
  final int videosCount;
  final double min;

  Rank({
    required this.name,
    required this.nameAr,
    required this.percent,
    required this.videosCount,
    required this.min,
  });

  factory Rank.fromJson(Map<String, dynamic> json) {
    return Rank(
      name: json['name'],
      nameAr: json['name_ar'],
      percent: json['percent'],
      videosCount: json['videos_count'],
      min: json['min'].toDouble(),
    );
  }
}
