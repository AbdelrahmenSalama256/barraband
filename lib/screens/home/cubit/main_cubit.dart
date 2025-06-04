import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:education_app/constants/network/local_network.dart';
import 'package:education_app/screens/Barraband%20modal/categoryModal.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'main_state.dart';

class MainCubit extends Cubit<MainState> {
  MainCubit() : super(MainInitial());

  // مصفوفات لتخزين الفئات والأقسام الفرعية والدروس
  List<Category> categoriesList = [];
  List<SubCategory> subCategoriesList = [];
  List<Lesson> lessonsList = [];

  // Fetch Categories
  void fetchCategories() async {
    emit(CategoriesLoadingState());
    var userToken = await CacheNetwork.getCacheData(key: "token");

    if (userToken == null) {
      emit(CategoriesFailureState(
          message: 'التوكن غير موجود. من فضلك قم بتسجيل الدخول مرة أخرى.'));
      return;
    }

    var headers = {
      'Authorization': 'Bearer $userToken',
    };

    var request = http.MultipartRequest(
        'GET', Uri.parse('https://barraband.net/api/categories'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);
        print(data); // <-- Add this to see if categories data is returned.

        if (data['status'] == 'Ok' && data.containsKey('data')) {
          categoriesList = (data['data'] as List)
              .map((categoryJson) => Category.fromJson(categoryJson))
              .toList();

          emit(CategoriesLoadedState(categories: categoriesList));
        } else {
          emit(CategoriesFailureState(message: 'فشل في تحميل الفئات.'));
        }
      } else {
        emit(CategoriesFailureState(
            message: 'فشل في تحميل الفئات: ${response.reasonPhrase}'));
      }
    } catch (e) {
      emit(CategoriesFailureState(message: 'خطأ: $e'));
    }
  }

  // Fetch Subcategories by categoryId
  void fetchSubCategories(int categoryId) async {
    emit(SubCategoriesLoadingState());
    var userToken = await CacheNetwork.getCacheData(key: "token");

    try {
      var response = await http.get(
        Uri.parse('https://barraband.net/api/subcategories/$categoryId'),
        headers: {'Authorization': 'Bearer $userToken'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        subCategoriesList = (data['data'] as List)
            .map((subCategoryJson) => SubCategory.fromJson(subCategoryJson))
            .toList();

        emit(SubCategoriesLoadedState(
            categoryId: categoryId, subCategories: subCategoriesList));
      } else {
        emit(
            SubCategoriesFailureState(message: 'Failed to load subcategories'));
      }
    } catch (e) {
      emit(SubCategoriesFailureState(message: 'Error: $e'));
    }
  }

// Fetch Lessons
  void fetchLessons(int categoryId) async {
    emit(LessonsLoadingState());
    var userToken = await CacheNetwork.getCacheData(key: "token");

    if (userToken == null) {
      emit(LessonsFailureState(
          message: 'التوكن غير موجود. من فضلك قم بتسجيل الدخول مرة أخرى.'));
      return;
    }

    var headers = {
      'Authorization': 'Bearer $userToken',
    };

    try {
      var response = await http.get(
        Uri.parse('https://barraband.net/api/main-lessons/$categoryId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Received data: $data'); // طباعة البيانات لفحصها

        // تحقق من وجود 'data' قبل محاولة الوصول إليها
        if (data['data'] != null && data['data'] is List) {
          List<Lesson> lessons = (data['data'] as List)
              .map((lessonJson) => Lesson.fromJson(lessonJson))
              .toList();

          print('Parsed lessons: $lessons'); // طباعة البيانات بعد التحليل

          // جلب الفيديوهات لكل درس
          for (var lesson in lessons) {
            var lessonVideos = await fetchLessonVideos(lesson.id);
            lesson.lessonVideos = lessonVideos;
            print(
                'Lesson ID: ${lesson.id}, Videos: $lessonVideos'); // طباعة الفيديوهات لكل درس
          }

          emit(LessonsLoadedState(lessons: lessons));
        } else {
          emit(LessonsFailureState(message: 'لا توجد دروس متاحة.'));
          print('No lessons available.'); // طباعة رسالة عندما لا تكون هناك دروس
        }
      } else {
        emit(LessonsFailureState(
            message: 'فشل في تحميل الدروس: ${response.reasonPhrase}'));
        print("message: 'فشل في تحميل الدروس: ${response.reasonPhrase}");
      }
    } catch (e) {
      emit(LessonsFailureState(message: 'خطأ: $e'));
      print("message: خطأ: $e");
    }
  }

  // Fetch Lesson Videos
  Future<List<LessonVideo>> fetchLessonVideos(int lessonId) async {
    var userToken = await CacheNetwork.getCacheData(key: "token");
    var headers = {
      'Authorization': 'Bearer $userToken',
    };

    var response = await http.get(
      Uri.parse('https://barraband.net/api/lesson-videos/$lessonId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<LessonVideo> lessonVideos = (data['data'] as List)
          .map((lessonVideoJson) => LessonVideo.fromJson(lessonVideoJson))
          .toList();

      return lessonVideos;
    } else {
      return [];
    }
  }
}
