import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/home/presentation/components/my_drawer.dart';
import 'package:social_app/features/post/presentation/components/post_tile.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_app/features/post/presentation/pages/upload_post_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // post cubit
  late final postCubit = context.read<PostCubit>();

  // on strat up
  @override
  void initState() {
    super.initState();

    // fetch all posts
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String id) {
    postCubit.deletePost(id);
    fetchAllPosts();
  }

  // build UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return Scaffold(
      // APPBAR
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UploadPostPage()),
              );
            },
            icon: Icon(CupertinoIcons.plus),
          ),
        ],
      ),

      // DRAWER
      drawer: MyDrawer(),

      // BODY
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          // loading..
          if (state is PostLoading || state is PostUploading) {
            return CircularProgressIndicator();
          }
          // loaded
          else if (state is PostLoaded) {
            final allPosts = state.posts;

            // no posts
            if (allPosts.isEmpty) {
              return Center(child: Text('No Posts Available'));
            }

            // list view of posts
            return ListView.builder(
              itemBuilder: (context, index) {
                // get individual post
                final post = allPosts[index];

                // image
                return PostTile(
                  post: post,
                  onDeletePressed: () => deletePost(post.id),
                );
              },
              itemCount: allPosts.length,
            );
          }
          // error
          else if (state is PostError) {
            return Center(child: Text(state.message));
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}
