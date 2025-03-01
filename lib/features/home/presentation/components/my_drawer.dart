import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/home/presentation/components/my_drawer_tile.dart';
import 'package:social_app/features/profile/presentation/pages/profile_page.dart';
import 'package:social_app/features/search/presentation/pages/search_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              // logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Icon(
                  Icons.person,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              // divider line
              Divider(color: Theme.of(context).colorScheme.secondary),

              // home tile
              MyDrawerTile(
                title: 'HOME',
                icon: Icons.home,
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),

              // profile tile
              MyDrawerTile(
                title: 'PROFILE',
                icon: Icons.person,
                onTap: () {
                  // pop menu drawer
                  Navigator.of(context).pop();

                  // get current user
                  final currentUser = context.read<AuthCubit>().currentUser;
                  String? uid = currentUser?.uid;

                  // navigate to profile page
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProfilePage(uid: uid ?? ''),
                    ),
                  );
                },
              ),

              // search tile
              MyDrawerTile(
                title: 'SEARCH',
                icon: Icons.search,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SearchPage()),
                  );
                },
              ),

              // settings tile
              MyDrawerTile(
                title: 'SETTINGS',
                icon: Icons.settings,
                onTap: () {},
              ),

              // logout tile
              MyDrawerTile(
                title: 'LOGOUT',
                icon: Icons.logout,
                onTap: () {
                  context.read<AuthCubit>().logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
