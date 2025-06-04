part of 'profile_cubit.dart';

@immutable
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

// حالات الحزم (Packages)
class PackagesLoadingState extends ProfileState {}

class PackagesSuccessState extends ProfileState {
  final List<dynamic> packages;
  PackagesSuccessState({required this.packages});
}

class PackagesFailureState extends ProfileState {
  final String message;
  PackagesFailureState({required this.message});
}

// حالات الرتب (Ranks)
class RanksLoadingState extends ProfileState {}

class RanksSuccessState extends ProfileState {
  final List<Rank> ranks;
  RanksSuccessState({required this.ranks});
}

class RanksFailureState extends ProfileState {
  final String message;
  RanksFailureState({required this.message});
}

class UserSubscriptionsLoadingState extends ProfileState {}

class UserSubscriptionsSuccessState extends ProfileState {
  final List<dynamic> subscriptions;
  UserSubscriptionsSuccessState(this.subscriptions);
}

class UserSubscriptionsEmptyState extends ProfileState {
  UserSubscriptionsEmptyState();
}

class UserSubscriptionsFailureState extends ProfileState {
  final String message;
  UserSubscriptionsFailureState({required this.message});
}
