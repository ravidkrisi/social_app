import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/domain/entities/app_user.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/domain/entities/comment.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';

class CommentTile extends StatefulWidget {
  final Comment comment;
  const CommentTile({super.key, required this.comment});

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  // current user
  AppUser? currentUser;
  bool isOwnPost = false;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = widget.comment.userId == currentUser!.uid;
  }

  void showOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Comment?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  context.read<PostCubit>().deleteComment(
                    widget.comment.postId,
                    widget.comment.id,
                  );
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
    return Row(
      children: [
        // comment's user name
        Text(
          widget.comment.userName,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        SizedBox(width: 10),
        // comment's text
        Text(widget.comment.text),

        Spacer(),

        // delete btn
        if (isOwnPost)
          GestureDetector(
            onTap: showOptions,
            child: Icon(
              Icons.more_horiz,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }
}
