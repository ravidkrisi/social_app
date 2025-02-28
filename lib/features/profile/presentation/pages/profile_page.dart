import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/domain/entities/app_user.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/presentation/components/post_tile.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_app/features/profile/presentation/components/bio_box.dart';
import 'package:social_app/features/profile/presentation/components/follow_button.dart';
import 'package:social_app/features/profile/presentation/components/profile_stats.dart';
import 'package:social_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:social_app/features/profile/presentation/pages/follower_page.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  // current user
  late AppUser? currentUser = authCubit.currentUser;

  // posts
  int postsCount = 0;

  bool isFollowing = false;

  // on startup
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    profileCubit.fetchProfileUser(widget.uid);
  }

  /*

  FOLLOW / UNFOLLOW

  */

  void followBtnPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return;
    }
    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // optimistcally update UI
    setState(() {
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      } else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      if (isFollowing) {
        profileUser.followers.add(currentUser!.uid);
      } else {
        profileUser.followers.remove(currentUser!.uid);
      }
    });
  }

  // build UI
  @override
  Widget build(BuildContext context) {
    bool isOwnProfile = widget.uid == currentUser!.uid;

    // SCAFFOLD
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // loaded
        if (state is ProfileLoaded) {
          // get laoded user
          final user = state.profileUser;

          return Scaffold(
            // APPBAR
            appBar: profileAppBar(user, context, isOwnProfile),

            // Body
            body: ListView(
              children: [
                // email
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                SizedBox(height: 25),

                // profile pic
                profilePic(context, user),

                SizedBox(height: 25),

                // profile stats
                PorfileStats(
                  postsCount: postsCount,
                  followersCount: user.followers.length,
                  followingCount: user.following.length,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => FollowerPage(
                              followers: user.followers,
                              following: user.following,
                            ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 25),

                // follow btn
                if (!isOwnProfile)
                  FollowButton(
                    isFollowing: user.followers.contains(currentUser!.uid),
                    onPressed: followBtnPressed,
                  ),

                SizedBox(height: 25),

                // bio
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        'Bio',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                BioBox(text: user.bio),

                SizedBox(height: 25),

                // posts
                Padding(
                  padding: const EdgeInsets.only(left: 25.0),
                  child: Row(
                    children: [
                      Text(
                        'Posts',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10),

                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    // posts loaded
                    if (state is PostLoaded) {
                      // filter posts by user id
                      final userPosts =
                          state.posts
                              .where((post) => post.uid == widget.uid)
                              .toList();

                      postsCount = userPosts.length;

                      return ListView.builder(
                        itemCount: postsCount,
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          // get individual post
                          final post = userPosts[index];

                          // return as post tile UI
                          return PostTile(
                            post: post,
                            onDeletePressed:
                                () => context.read<PostCubit>().deletePost(
                                  post.id,
                                ),
                          );
                        },
                      );
                    }

                    // posts loading
                    if (state is PostLoading) {
                      return Center(child: CircularProgressIndicator());
                    }

                    return Center(child: Text('something went wrong'));
                  },
                ),
              ],
            ),
          );
        } else if (state is ProfileLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          return Scaffold(body: Center(child: Text('No Pofile Found')));
        }

        // loading
      },
    );
  }

  Container profilePic(BuildContext context, ProfileUser user) {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.secondary,
      ),
      clipBehavior: Clip.hardEdge,
      child: CachedNetworkImage(
        imageUrl: user.profileImageUrl,
        imageBuilder:
            (context, imageProvider) =>
                Image(image: imageProvider, fit: BoxFit.cover),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget:
            (context, url, error) => Icon(
              Icons.person,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  AppBar profileAppBar(
    ProfileUser user,
    BuildContext context,
    bool isOwnProfile,
  ) {
    return AppBar(
      title: Text(user.name),
      foregroundColor: Theme.of(context).colorScheme.primary,
      actions: [
        // edit profile
        if (isOwnProfile)
          IconButton(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfilePage(user: user),
                  ),
                ),
            icon: Icon(Icons.edit),
          ),
      ],
    );
  }
}
