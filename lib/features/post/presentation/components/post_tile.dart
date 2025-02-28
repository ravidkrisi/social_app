import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:social_app/features/auth/domain/entities/app_user.dart';
import 'package:social_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/domain/entities/comment.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/presentation/components/comment_tile.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:uuid/uuid.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnPost = false;
  // current user
  AppUser? currentUser;

  // post user
  ProfileUser? postUser;

  // on startup
  @override
  void initState() {
    super.initState();

    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = (widget.post.uid == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.uid);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  /*

  LIKES

  */
  // user tapped like btn
  void toggleLikePost() {
    // current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    // optimistically like & update the UI
    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid);
      } else {
        widget.post.likes.add(currentUser!.uid);
      }
    });

    // update like
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((
      error,
    ) {
      // if there is an error - revert to original values
      if (isLiked) {
        widget.post.likes.add(currentUser!.uid);
      } else {
        widget.post.likes.remove(currentUser!.uid);
      }
    });
  }

  /*

  COMMENTS

  */

  // comment text controller
  final commentTextController = TextEditingController();

  /// open comment box -> user wants to type new comment
  void openNewCommentBox() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add a new comment'),
            content: MyTextField(
              controller: commentTextController,
              hintText: 'write something',
              obscureText: false,
            ),
            actions: [
              // cancel button
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),

              // save button
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  addComment();
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void addComment() {
    // validate comment is not empty
    if (commentTextController.text.isNotEmpty) {
      // create a new comment
      final newComment = Comment(
        id: Uuid().v4(),
        postId: widget.post.id,
        userId: currentUser!.uid,
        userName: currentUser!.name,
        text: commentTextController.text,
        timestamp: DateTime.now(),
      );

      // add comment using cubit
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  /// show options for deletion
  void showOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Post?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  widget.onDeletePressed!();
                  Navigator.pop(context);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.secondary,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child:
            // top section: profile pic / name / delete btn
            topSection(context),
          ),
          // image
          imageSection(),
          // bottom section: like / comment / timestamp
          bottomSection(),
          // caption section
          captionSection(),
          // comment section
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              // LOADED
              if (state is PostLoaded) {
                // final individual post
                final post = state.posts.firstWhere(
                  (post) => post.id == widget.post.id,
                );

                if (post.comments.isNotEmpty) {
                  // numbers of comments to show
                  int showCommentsCount = post.comments.length;

                  // comment section
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: showCommentsCount,
                    itemBuilder: (context, index) {
                      // get individual comment
                      final comment = post.comments[index];

                      // comment tile UI
                      return Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: CommentTile(comment: comment),
                      );
                    },
                  );
                }
              }
              // LOADING
              else if (state is PostLoading) {
                return Center(child: CircularProgressIndicator());
              }
              // ERROR
              else if (state is PostError) {
                return Center(child: Text(state.message));
              }
              return Center(child: Text('something went wrong..'));
            },
          ),
        ],
      ),
    );
  }

  Padding captionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
      child: Row(
        children: [
          // user name
          Text(
            widget.post.userName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          SizedBox(width: 10),
          // post's caption
          Text(widget.post.caption),
        ],
      ),
    );
  }

  Padding bottomSection() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          // like btn
          SizedBox(
            width: 50,
            child: Row(
              children: [
                GestureDetector(
                  onTap: toggleLikePost,
                  child: Icon(
                    widget.post.likes.contains(currentUser!.uid)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        widget.post.likes.contains(currentUser!.uid)
                            ? Colors.red
                            : Colors.black,
                  ),
                ),
                Text(widget.post.likes.length.toString()),
              ],
            ),
          ),

          SizedBox(width: 20),

          // comment btn
          GestureDetector(onTap: openNewCommentBox, child: Icon(Icons.comment)),
          Text(widget.post.comments.length.toString()),

          Spacer(),

          // timestamp
          Text(
            DateFormat('dd/MM/yyyy').format(widget.post.timestamp).toString(),
          ),
        ],
      ),
    );
  }

  CachedNetworkImage imageSection() {
    return CachedNetworkImage(
      imageUrl: widget.post.imageUrl,
      height: 430,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Text('error loading photo: $error'),
    );
  }

  Row topSection(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // post's user profile pic
        postUser?.profileImageUrl != null
            ? CachedNetworkImage(
              imageUrl: postUser!.profileImageUrl,
              errorWidget: (context, url, error) => Icon(Icons.person),
              imageBuilder:
                  (context, imageProvider) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: imageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
            )
            : Icon(Icons.person, color: Colors.blue),

        SizedBox(width: 10),
        // post's user name
        Text(
          widget.post.userName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        // delete button
        if (isOwnPost)
          GestureDetector(
            onTap: showOptions,
            child: Icon(
              Icons.delete,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }
}
