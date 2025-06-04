part of 'main_cubit.dart';

@immutable
abstract class MainState {}

class MainInitial extends MainState {}

class CategoriesLoadingState extends MainState {}

class CategoriesLoadedState extends MainState {
  final List categories;

  CategoriesLoadedState({required this.categories});
}

class CategoriesFailureState extends MainState {
  final String message;

  CategoriesFailureState({required this.message});
}

// حالات الفئات الفرعية
class SubCategoriesLoadingState extends MainState {}

class SubCategoriesLoadedState extends MainState {
  final int categoryId;
  final List<SubCategory> subCategories;

  SubCategoriesLoadedState(
      {required this.categoryId, required this.subCategories});
}

class SubCategoriesFailureState extends MainState {
  final String message;
  SubCategoriesFailureState({required this.message});
}

// State when lessons are being loaded
class LessonsLoadingState extends MainState {}

// State when lessons are successfully loaded
class LessonsLoadedState extends MainState {
  final List<Lesson> lessons;

  LessonsLoadedState({required this.lessons});
}

// State when there is a failure loading lessons
class LessonsFailureState extends MainState {
  final String message;

  LessonsFailureState({required this.message});
}

class LessonVideosLoadedState extends MainState {
  final List<LessonVideo> videos;

  LessonVideosLoadedState({required this.videos});
}
