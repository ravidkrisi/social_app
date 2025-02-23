// ignore_for_file: public_member_api_docs, sort_constructors_first
/*

Auth States

*/

import 'package:social_app/features/auth/domain/entities/app_user.dart';

abstract class AuthState {}

// initial
class AuthInitial extends AuthState {}

// loading..
class AuthLoading extends AuthState {}

// authenticated
class AuthAuthenticated extends AuthState {
  final AppUser user;
  AuthAuthenticated({required this.user});
}

// unauthenticated
class AuthUnauthenticated extends AuthState {}

// errors
class AuthError extends AuthState {
  final String message;
  AuthError({required this.message});
}
