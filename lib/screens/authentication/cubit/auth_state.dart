part of 'auth_cubit.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthSuccessState extends AuthState {
  final User? user;
  final String? message;

  AuthSuccessState({this.user, this.message});
}

class AuthFailureState extends AuthState {
  final String message;

  AuthFailureState({required this.message});
}

// حالة جديدة لنجاح إعادة تعيين كلمة المرور
class AuthPasswordResetSuccessState extends AuthState {
  final String message;

  AuthPasswordResetSuccessState({required this.message});
}

class AuthLoggedOutState extends AuthState {}
