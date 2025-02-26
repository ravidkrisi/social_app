import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
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
  // mobile image pick
  PlatformFile? imageSelectedFile;

  // web image pick
  Uint8List? webImage;

  // controllers
  final bioTextController = TextEditingController();

  // pick image
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imageSelectedFile = result.files.first;

        if (kIsWeb) {
          webImage = imageSelectedFile?.bytes;
        }
      });
    }
  }

  // update profile button pressed
  void updateProfile() async {
    // profile cubit
    final profileCubit = context.read<ProfileCubit>();

    // prepare images
    final String uid = widget.user.uid;
    final imageMobilePath = kIsWeb ? null : imageSelectedFile?.path;
    final imageWebBytes = kIsWeb ? imageSelectedFile?.bytes : null;
    //prepare bio
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;

    // only update the profile if there is something to update
    if (imageWebBytes != null || imageMobilePath != null || newBio != null) {
      profileCubit.updateProfileUser(
        uid: uid,
        bio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    }
    // nothing to update -> go to previos page
    else {
      Navigator.pop(context);
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

  Widget buildEditPage() {
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
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            clipBehavior: Clip.hardEdge,
            child:
                // display selected image for mobile
                (!kIsWeb && imageSelectedFile != null)
                    ? Image.file(
                      File(imageSelectedFile!.path!),
                      fit: BoxFit.cover,
                    )
                    :
                    // display selected image for web
                    (kIsWeb && webImage != null)
                    ? Image.memory(webImage!, fit: BoxFit.cover)
                    :
                    // no image selected -> display existing profile pic
                    CachedNetworkImage(
                      imageUrl: widget.user.profileImageUrl,
                      imageBuilder:
                          (context, imageProvider) =>
                              Image(image: imageProvider, fit: BoxFit.cover),
                      placeholder:
                          (context, url) => CircularProgressIndicator(),
                      errorWidget:
                          (context, url, error) => Icon(
                            Icons.person,
                            size: 72,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
          ),

          SizedBox(height: 25),

          // pick image button
          MaterialButton(
            onPressed: pickImage,
            color: Colors.blue.shade300,
            child: Text('Pick Image'),
          ),

          SizedBox(height: 10),

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
