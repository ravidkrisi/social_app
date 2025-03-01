import 'package:social_app/features/profile/domain/entities/profile_user.dart';

abstract class SearchState {}

// initial
class SearchInitial extends SearchState {}

// loading
class SearchLoding extends SearchState {}

// loaded
class SearchLoaded extends SearchState {
  final List<ProfileUser?> users;

  SearchLoaded(this.users);
}

// error
class SearchError extends SearchState {
  String message;

  SearchError(this.message);
}
