// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:social_app/features/auth/data/firebase_auth_repo.dart';
// import 'package:social_app/features/auth/domain/repos/auth_repo.dart';
// import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
// import 'package:social_app/features/auth/presentation/cubits/auth_states.dart';
// import 'package:social_app/features/auth/presentation/pages/auth_page.dart';
// import 'package:social_app/themes/light_mode.dart';

// /*

// APP - root level

// Repositories: for the database
//   - firebase

// bloc Providers: for state mgmt
//   - auth
//   - profile
//   - post
//   - search
//   - theme

// check Auth State
//   - unauthenticated -> auth page (login/register)
//   - authenticated -> home page
// */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/data/firebase_auth_repo.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_app/features/auth/presentation/pages/auth_page.dart';
import 'package:social_app/features/home/presentation/pages/home.dart';
import 'package:social_app/features/post/data/firebase_post_repo.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_app/features/profile/data/firebase_profile_repo.dart';
import 'package:social_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_app/features/search/data/firebase_search_repo.dart';
import 'package:social_app/features/search/presentation/cubits/search_cubit.dart';
import 'package:social_app/features/storage/data/firebase_storage_repo.dart';
import 'package:social_app/themes/theme_cubit.dart';

class MyApp extends StatelessWidget {
  // auth repo
  final firebaseAuthRepo = FirebaseAuthRepo();
  // profile repo
  final firebaseProfileRepo = FirebaseProfileRepo();
  // storage repo
  final firebaseStorageRepo = FirebaseStorageRepo();
  // post repo
  final firebasePostRepo = FirebasePostRepo();
  // search repo
  final firebaseSearchRepo = FirebaseSearchRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // provide cubits to app
      providers: [
        // auth cubit
        BlocProvider<AuthCubit>(
          create:
              (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),
        // profile cubit
        BlocProvider<ProfileCubit>(
          create:
              (context) => ProfileCubit(
                profileRepo: firebaseProfileRepo,
                storageRepo: firebaseStorageRepo,
              ),
        ),
        // post cubit
        BlocProvider<PostCubit>(
          create:
              (context) => PostCubit(
                postRepo: firebasePostRepo,
                storageRepo: firebaseStorageRepo,
              ),
        ),
        // search cubit
        BlocProvider<SearchCubit>(
          create: (context) => SearchCubit(searchRepo: FirebaseSearchRepo()),
        ),
        // theme cubit
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, currentTheme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: currentTheme,
            home: BlocConsumer<AuthCubit, AuthState>(
              // listen for errors..
              listener: (context, state) {
                if (state is AuthError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, authState) {
                print(authState);

                // unauthenticated -> auth page (login/register)
                if (authState is AuthUnauthenticated) {
                  return AuthPage();
                }

                //  - authenticated -> home page
                if (authState is AuthAuthenticated) {
                  return HomePage();
                }
                // loading..
                else {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
