/*

Auth Cubit: State Management

*/

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/domain/entities/app_user.dart';
import 'package:social_app/features/auth/domain/repos/auth_repo.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;

  AppUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  // check if user is already authenticated
  void checkAuth() async {
    final AppUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(AuthAuthenticated(user: user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // get current user
  AppUser? get currentUser => _currentUser;

  // login with email + pw
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());

      final user = await authRepo.loginWithEmailPassword(email, password);

      if (user != null) {
        _currentUser = user;
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // register with email + pw
  Future<void> register(String name, String email, String pwd) async {
    try {
      AppUser? user = await authRepo.registerWithEmailPassword(
        name,
        email,
        pwd,
      );

      if (user != null) {
        _currentUser = user;
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // logout
  Future<void> logout() async {
    authRepo.logout();
    emit(AuthUnauthenticated());
  }
}
