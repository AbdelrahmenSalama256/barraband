import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:education_app/constants/network/local_network.dart';
import 'package:education_app/screens/Barraband%20modal/modal_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  User? user; // كائن المستخدم لحفظ البيانات

  AuthCubit() : super(AuthInitial());

  // دالة تسجيل الدخول
// دالة تسجيل الدخول
  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoadingState());

    var url = Uri.parse('https://barraband.net/api/login');
    var body = {
      'email': email.trim(),
      'password': password.trim(),
    };

    try {
      final response = await http.post(url, body: body);

      // التأكد من أن الاستجابة 200 ناجحة
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Response body: $data'); // طباعة الاستجابة

        // التأكد من وجود حقل success في الاستجابة
        if (data.containsKey('success')) {
          user = User.fromJson(data['success']);
          String token = data['success']['token'];

          // حفظ التوكن في التخزين المؤقت
          await CacheNetwork.insertToCache(key: "token", value: token);

          emit(AuthSuccessState(user: user!));
        } else {
          emit(AuthFailureState(message: 'Login failed. Invalid credentials.'));
        }
      } else {
        print(
            'Request failed: ${response.statusCode} - ${response.reasonPhrase}');
        print('Response body: ${response.body}');
        emit(AuthFailureState(
            message:
                'Request failed: ${response.statusCode} - ${response.reasonPhrase}'));
      }
    } catch (e) {
      emit(AuthFailureState(message: 'Exception: $e'));
      print('Exception: $e');
    }
  }

  // دالة تسجيل الدخول عبر فيسبوك
  Future<void> signupWithFacebook() async {
    emit(AuthLoadingState());

    // تنفيذ عملية تسجيل الدخول عبر فيسبوك
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      // تم تسجيل الدخول بنجاح
      final AccessToken accessToken = result.accessToken!;

      // أرسل الـ token إلى API الخاص بك
      await sendFacebookTokenToApi(accessToken.tokenString);
    } else {
      // حدث خطأ
      emit(AuthFailureState(
          message: 'Login failed: ${result.status} - ${result.message}'));
    }
  }

  // دالة لإرسال توكن فيسبوك إلى API
  Future<void> sendFacebookTokenToApi(String token) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://barraband.net/api/login-facebook'));
    request.fields.addAll({
      'input_token': token, // استخدم الـ token الذي تم الحصول عليه
      'provider_id': 'facebook' // أو أي معرّف مزود آخر إذا كنت تستخدمه
    });

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);
        print('Response body: $data'); // طباعة الاستجابة

        if (data.containsKey('success')) {
          user = User.fromJson(data['success']); // إنشاء كائن المستخدم وتخزينه
          String token = data['success']['token'];

          // حفظ التوكن في التخزين المؤقت
          await CacheNetwork.insertToCache(key: "token", value: token);

          emit(AuthSuccessState(user: user!));
        } else {
          emit(AuthFailureState(message: 'Login failed. Please try again.'));
        }
      } else {
        print(
            'Request failed: ${response.statusCode} - ${response.reasonPhrase}');
        emit(AuthFailureState(
            message:
                'Request failed: ${response.statusCode} - ${response.reasonPhrase}'));
      }
    } catch (e) {
      emit(AuthFailureState(message: 'Exception: $e'));
      print('Exception: $e');
    }
  }

// دالة إنشاء الحساب الجديد
  void signup({
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String name,
    required String country,
  }) async {
    emit(AuthLoadingState());

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://barraband.net/api/signup'),
    );

    request.fields.addAll({
      'email': email.trim(),
      'password': password.trim(),
      'password_confirmation': passwordConfirmation.trim(),
      'phone': phone.trim(),
      'name': name.trim(),
      'country': country.trim(),
    });

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);
        print('Response body: $data'); // طباعة الاستجابة

        if (data.containsKey('success')) {
          user = User.fromJson(data['success']); // إنشاء كائن المستخدم وتخزينه
          String token = data['success']['token'];

          // حفظ التوكن في التخزين المؤقت
          await CacheNetwork.insertToCache(key: "token", value: token);

          emit(AuthSuccessState(user: user!));
        } else {
          emit(AuthFailureState(message: 'Signup failed. Please try again.'));
        }
      } else {
        _handleHttpErrors(response); // التعامل مع أخطاء HTTP
      }
    } catch (e) {
      emit(AuthFailureState(message: e.toString()));
      print('Exception: $e');
    }
  }

  // دالة استرداد بيانات المستخدم
  void fetchUserDetails({int retryCount = 3}) async {
    emit(AuthLoadingState());
    var userToken = await CacheNetwork.getCacheData(
      key: "token",
    );

    if (userToken == null) {
      emit(AuthFailureState(
          message: 'التوكن غير موجود. من فضلك قم بتسجيل الدخول مرة أخرى.'));
      return;
    }

    var headers = {
      'Authorization': 'Bearer $userToken',
    };

    var request = http.MultipartRequest(
        'GET', Uri.parse('https://barraband.net/api/details'));
    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);
        print('Response: $responseData');

        if (data['success'] == true) {
          user = User.fromJson(data); // تعيين بيانات المستخدم
          emit(AuthSuccessState(user: user!));
        } else {
          emit(AuthFailureState(message: 'فشل في تحميل بيانات المستخدم.'));
        }
      } else if (response.statusCode == 401 && retryCount > 0) {
        print('الرمز المميز غير صالح أو انتهت صلاحيته، إعادة المحاولة...');
        await Future.delayed(
            Duration(seconds: 2)); // Add a slight delay before retrying
        fetchUserDetails(retryCount: retryCount - 1);
      } else {
        emit(AuthFailureState(
            message: 'فشل في تحميل بيانات المستخدم: ${response.reasonPhrase}'));
      }
    } catch (e) {
      if (retryCount > 0) {
        print('حدث خطأ: $e، إعادة المحاولة...');
        await Future.delayed(
            Duration(seconds: 2)); // Add a slight delay before retrying
        fetchUserDetails(retryCount: retryCount - 1);
      } else {
        emit(AuthFailureState(message: 'خطأ: $e'));
      }
    }
  }

  // التعامل مع أخطاء HTTP
  void _handleHttpErrors(http.StreamedResponse response) async {
    var responseData = await response.stream.bytesToString();

    try {
      var data = jsonDecode(responseData);

      if (response.statusCode == 401) {
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          _handleApiErrors(data['error']);
        } else {
          emit(AuthFailureState(
              message: 'Unauthorized: ${response.reasonPhrase}'));
        }
      } else {
        emit(AuthFailureState(
            message: 'Request failed: ${response.reasonPhrase}'));
      }
    } catch (e) {
      emit(AuthFailureState(message: 'Error: $responseData'));
    }
  }

  // التعامل مع أخطاء الـ API
  void _handleApiErrors(Map<String, dynamic> errors) {
    String errorMessage = '';
    errors.forEach((key, value) {
      if (value is List) {
        for (var error in value) {
          errorMessage += '$error\n';
        }
      } else {
        errorMessage += '$value\n';
      }
    });
    emit(AuthFailureState(message: errorMessage.trim()));
  }

// دالة نسيان كلمة المرور
  Future<void> forgotPassword({required String email}) async {
    emit(AuthLoadingState());

    var url = Uri.parse('https://barraband.net/api/forgot');
    var body = {
      'email': email,
    };

    try {
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        print('Response: $data');

        if (data['status'] == 'true') {
          emit(AuthPasswordResetSuccessState(
            message: data['message'] ?? 'تمت العملية بنجاح',
          ));
        } else {
          emit(AuthFailureState(message: 'فشل في إعادة تعيين كلمة المرور'));
        }
      } else {
        emit(AuthFailureState(message: 'خطأ في الاتصال بالسيرفر'));
      }
    } catch (e) {
      emit(AuthFailureState(message: 'حدث خطأ: $e'));
    }
  }

  Future<void> changePassword({required String newPassword}) async {
    emit(AuthLoadingState());

    var request = http.MultipartRequest(
        'POST', Uri.parse('https://barraband.net/api/changepass'));

    request.fields.addAll({
      'password': newPassword,
      'password_confirmation': newPassword, // التأكيد على كلمة المرور
    });

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseBody);
        print('Response: $responseBody');

        if (jsonResponse['status'] == 'true') {
          emit(AuthSuccessState(message: jsonResponse['message']));
        } else {
          emit(AuthFailureState(message: jsonResponse['message'] ?? 'حدث خطأ'));
        }
      } else {
        String errorBody = await response.stream.bytesToString();
        emit(AuthFailureState(
            message: 'Error ${response.statusCode}: $errorBody'));
        print('Error response: $errorBody'); // طباعة تفاصيل الخطأ
      }
    } catch (e) {
      // طباعة تفاصيل الخطأ
      print('Caught exception: $e');
      emit(AuthFailureState(message: 'خطأ في الاتصال بالإنترنت: $e'));
    }
  }
}
