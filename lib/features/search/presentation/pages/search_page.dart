import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profile/presentation/components/user_tile.dart';
import 'package:social_app/features/search/presentation/cubits/search_cubit.dart';
import 'package:social_app/features/search/presentation/cubits/search_states.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final searchController = TextEditingController();
  late final searchCubit = context.read<SearchCubit>();

  void onSearchChanged() {
    final query = searchController.text;
    searchCubit.searchUser(query);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(onSearchChanged);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return Scaffold(
      // APPBAR
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Search Users..',
            hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      ),

      // BODY
      body: BlocBuilder<SearchCubit, SearchState>(
        builder: (context, state) {
          // loaded
          if (state is SearchLoaded) {
            // no users
            if (state.users.isEmpty) {
              return Center(child: Text('No users found'));
            }
            // found users
            else {
              print("im here");
              return ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, index) {
                  // get individual user
                  final user = state.users[index];
                  return UserTile(user: user!);
                },
              );
            }
          }

          // loading
          if (state is SearchLoding) {
            return Center(child: CircularProgressIndicator());
          }

          // error
          if (state is SearchError) {
            return Center(child: Text(state.message));
          }
          // default
          return Center(child: Text('start searching for users..'));
        },
      ),
    );
  }
}
