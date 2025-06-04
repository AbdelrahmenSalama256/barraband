class Category {
  final int id;
  final String name;
  final String nameAr;
  final String slug;
  final String slugAr;
  final String? photo; // Make this nullable to avoid null safety errors
  final String? title; // Make this nullable
  final String? titleAr; // Make this nullable
  final String? details; // Make this nullable
  final String? detailsAr; // Make this nullable
  final List<SubCategory> subCategories; // Subcategories list

  Category({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    required this.slugAr,
    this.photo, // Make it optional
    this.title, // Make it optional
    this.titleAr, // Make it optional
    this.details, // Make it optional
    this.detailsAr, // Make it optional
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var subCategoriesJson = json['subcategories'] as List? ?? [];
    List<SubCategory> subCategoriesList =
        subCategoriesJson.map((subCategoryJson) {
      return SubCategory.fromJson(subCategoryJson);
    }).toList();

    return Category(
      id: json['id'],
      name: json['name'],
      nameAr: json['name_ar'],
      slug: json['slug'],
      slugAr: json['slug_ar'],
      photo: json['photo'], // Handle nullable value
      title: json['title'], // Handle nullable value
      titleAr: json['title_ar'], // Handle nullable value
      details: json['details'], // Handle nullable value
      detailsAr: json['details_ar'], // Handle nullable value
      subCategories: subCategoriesList,
    );
  }
}

class SubCategory {
  final int id;
  final int categoryId;
  final String name;
  final String nameAr;
  final String slug;
  final String slugAr;
  final int status;
  final String? photo; // Make this nullable
  final String? details;
  final String? detailsAr;

  SubCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.nameAr,
    required this.slug,
    required this.slugAr,
    required this.status,
    this.photo, // Make it optional
    this.details,
    this.detailsAr,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      categoryId: json['category_id'],
      name: json['name'],
      nameAr: json['name_ar'],
      slug: json['slug'],
      slugAr: json['slug_ar'],
      status: json['status'],
      photo: json['photo'], // Handle nullable value
      details: json['details'],
      detailsAr: json['details_ar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'name': name,
      'name_ar': nameAr,
      'slug': slug,
      'slug_ar': slugAr,
      'status': status,
      'photo': photo,
      'details': details,
      'details_ar': detailsAr,
    };
  }
}

class Lesson {
  final int id;
  final int subcategoryId;
  final int categoryId;
  final String name;
  final String nameAr;
  final String details;
  final String detailsAr;
  final String photo;
  List<LessonVideo> lessonVideos; // قائمة الفيديوهات

  // إضافة الخصائص المفقودة
  final bool isPlaying;
  final String duration;
  final bool isCompleted;

  Lesson({
    required this.id,
    required this.subcategoryId,
    required this.categoryId,
    required this.name,
    required this.nameAr,
    required this.details,
    required this.detailsAr,
    required this.photo,
    this.isPlaying = false, // القيمة الافتراضية
    this.duration = "Unknown", // القيمة الافتراضية
    this.isCompleted = false, // القيمة الافتراضية
    List<LessonVideo>? lessonVideos, // استلام الفيديوهات كقائمة اختيارية
  }) : lessonVideos = lessonVideos ?? []; // تأكد من تعيين الفيديوهات هنا

  factory Lesson.fromJson(Map<String, dynamic> json) {
    print('Parsing Lesson from JSON: $json'); // طباعة البيانات
    var lesson = Lesson(
      id: json['id'] ?? 0,
      subcategoryId: json['subcategory_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      name: json['name']?.toString() ?? 'Unnamed Lesson',
      nameAr: json['name_ar']?.toString() ?? 'Unnamed Lesson (AR)',
      details: json['details']?.toString() ?? 'No details available',
      detailsAr: json['details_ar']?.toString() ?? 'لا توجد تفاصيل متاحة',
      photo: json['photo']?.toString() ?? 'https://example.com/default.png',
      isPlaying: json['is_playing'] ?? false,
      duration: json['duration']?.toString() ?? "Unknown",
      isCompleted: json['is_completed'] ?? false,
      lessonVideos: [], // تعيين قائمة فارغة كقيمة افتراضية
    );
    print(
        'Parsed Lesson: ${lesson.name}, Video URL: ${lesson.photo}'); // طباعة خصائص الدرس
    return lesson;
  }
}

class LessonVideo {
  final int id;
  final String name;
  final String nameAr;
  final String movieName;
  final String title;
  final String titleAr;
  final String ext;
  final String duration;
  final String videoUrl;
  final String details;
  final String detailsAr;

  LessonVideo({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.movieName,
    required this.title,
    required this.titleAr,
    required this.ext,
    required this.duration,
    required this.videoUrl,
    required this.details,
    required this.detailsAr,
  });

  factory LessonVideo.fromJson(Map<String, dynamic> json) {
    var lessonVideo = LessonVideo(
      id: json['id'] ?? 0, // التأكد من وجود قيمة افتراضية
      name: json['name'] ?? '', // التأكد من وجود قيمة افتراضية
      nameAr: json['name_ar'] ?? '', // التأكد من وجود قيمة افتراضية
      movieName: json['movie_name'] ?? '',
      title: json['title'] ?? '',
      titleAr: json['title_ar'] ?? '',
      ext: json['ext'] ?? '',
      duration: json['duration'] ?? '',
      videoUrl: json['video'] ?? '', // التأكد من وجود قيمة افتراضية
      details: json['details'] ?? 'No details available',
      detailsAr: json['details_ar'] ?? 'لا توجد تفاصيل متاحة',
    );
    print(
        'Parsed LessonVideo: ${lessonVideo.name}, Video URL: ${lessonVideo.videoUrl}'); // طباعة خصائص الفيديو
    return lessonVideo;
  }
}
