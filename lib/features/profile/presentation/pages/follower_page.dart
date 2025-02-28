import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profile/presentation/components/user_tile.dart';
import 'package:social_app/features/profile/presentation/cubits/profile_cubit.dart';

class FollowerPage extends StatelessWidget {
  final List<String> followers;
  final List<String> following;

  const FollowerPage({
    super.key,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    // TAB CONTROLLER
    return DefaultTabController(
      length: 2,

      // SCAFFOLD
      child: Scaffold(
        // APPBAR
        appBar: AppBar(
          bottom: TabBar(
            dividerColor: Colors.transparent,
            labelColor: Theme.of(context).colorScheme.inversePrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.primary,
            tabs: [Tab(text: 'followers'), Tab(text: 'following')],
          ),
        ),

        // Tab bar view
        body: TabBarView(
          children: [
            _buildUserList(followers, 'no followers', context),
            _buildUserList(following, 'no following', context),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(
    List<String> uids,
    String emptyMessage,
    BuildContext context,
  ) {
    return uids.isEmpty
        ? Center(child: Text(emptyMessage))
        : ListView.builder(
          itemCount: uids.length,
          itemBuilder: (context, index) {
            // get individual id
            final uid = uids[index];

            return FutureBuilder(
              future: context.read<ProfileCubit>().getUserProfile(uid),
              builder: (context, snapshot) {
                // user loaded
                if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return UserTile(user: user);
                }
                // user loading
                else if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListTile(title: Text('Loading..'));
                }
                // not found
                else {
                  return ListTile(title: Text('user not found'));
                }
              },
            );
          },
        );
  }
}
