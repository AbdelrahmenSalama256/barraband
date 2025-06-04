import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:education_app/constants/network/local_network.dart';
import 'package:education_app/screens/profile-personly/modal/profile_Modal.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<void> fetchPackages() async {
    var userToken = await CacheNetwork.getCacheData(
      key: "token",
    );
    emit(PackagesLoadingState());

    var headers = {
      'Authorization': 'Bearer $userToken',
    };
    var request = http.MultipartRequest(
        'GET', Uri.parse('https://barraband.net/api/packages'));

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);

        if (data['status'] == "Ok") {
          List<Package> packages = (data['data'] as List)
              .map((packageJson) => Package.fromJson(packageJson))
              .toList(); // تحويل البيانات إلى كائنات Package

          emit(PackagesSuccessState(packages: packages)); // نجاح
        } else {
          emit(PackagesFailureState(message: 'Failed to fetch packages.'));
        }
      } else {
        emit(PackagesFailureState(
            message:
                'Request failed: ${response.statusCode} - ${response.reasonPhrase}'));
      }
    } catch (e) {
      emit(PackagesFailureState(message: 'Exception: $e'));
      print('Exception: $e');
    }
  }

  Future<void> fetchRanks() async {
    var userToken = await CacheNetwork.getCacheData(key: "token");
    emit(RanksLoadingState()); // حالة تحميل الرتب

    var headers = {
      'Authorization': 'Bearer $userToken',
    };

    var request = http.MultipartRequest(
        'GET', Uri.parse('https://barraband.net/api/user-progress'));

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();
        var data = jsonDecode(responseBody);

        List<Rank> ranks = (data['data'] as List)
            .map((rankJson) => Rank.fromJson(rankJson))
            .toList();

        emit(RanksSuccessState(ranks: ranks)); // نجاح
      } else {
        emit(RanksFailureState(
            message: 'Failed to load ranks: ${response.statusCode}'));
      }
    } catch (e) {
      emit(RanksFailureState(message: 'Exception: $e'));
    }
  }

  Future<void> fetchUserSubscriptions() async {
    var userToken = await CacheNetwork.getCacheData(
      key: "token",
    );
    emit(UserSubscriptionsLoadingState());

    var headers = {
      'Authorization': 'Bearer $userToken',
    };
    var request = http.MultipartRequest(
        'GET', Uri.parse('https://barraband.net/api/user-subscriptions'));

    request.headers.addAll(headers);

    try {
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var data = jsonDecode(responseData);

        if (data['status'] == "Ok" && data['data'].isNotEmpty) {
          List<dynamic> subscriptions = data['data'];
          emit(UserSubscriptionsSuccessState(
              subscriptions)); // حالة النجاح        } else {
          emit(UserSubscriptionsEmptyState()); // لا يوجد اشتراك
        }
      } else {
        emit(UserSubscriptionsFailureState(
            message:
                'Request failed: ${response.statusCode} - ${response.reasonPhrase}'));
      }
    } catch (e) {
      emit(UserSubscriptionsFailureState(message: 'Exception: $e'));
      print('Exception: $e');
    }
  }
}
