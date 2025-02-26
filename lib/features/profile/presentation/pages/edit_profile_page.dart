import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_app/features/profile/presentation/cubits/profile_states.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;
  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final bioTextController = TextEditingController();

  // update profile button pressed
  void updateProfile() async {
    if (bioTextController.text.isNotEmpty) {
      context.read<ProfileCubit>().updateProfileUser(
        uid: widget.user.uid,
        bio: bioTextController.text,
      );
    }
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        print(state);
        // profile loading..
        if (state is ProfileLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [CircularProgressIndicator(), Text('Uploading...')],
              ),
            ),
          );
        } else {
          return buildEditPage();
        }
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildEditPage({double uploadProgress = 0.0}) {
    // SCAFFOLD
    return Scaffold(
      // APPBAR
      appBar: AppBar(
        title: Text('Edit Profile'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: updateProfile,
            icon: Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: Colors.green,
            ),
          ),
        ],
      ),

      // BODY
      body: Column(
        children: [
          // profile picture

          // bio
          Text('Bio'),

          SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: MyTextField(
              controller: bioTextController,
              hintText: 'Write about yourself..',
              obscureText: false,
            ),
          ),
        ],
      ),
    );
  }
}
