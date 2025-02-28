import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/auth/domain/entities/app_user.dart';
import 'package:social_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_app/features/post/presentation/cubits/post_states.dart';
import 'package:uuid/uuid.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  // mobile image pick
  PlatformFile? selectedImage;

  // web image pick
  Uint8List? webImage;

  // text controller -> caption
  final captionController = TextEditingController();

  // current user
  AppUser? currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  // get current user
  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  // select image
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        selectedImage = result.files.first;

        if (kIsWeb) {
          webImage = selectedImage?.bytes;
        }
      });
    }
  }

  // create & upload post
  void uploadPost() {
    // check if both image and caption are provided
    if (selectedImage == null || captionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('fill all fields')));
      return;
    }

    // create post object
    final post = Post(
      id: Uuid().v4(),
      uid: currentUser!.uid,
      userName: currentUser!.name,
      caption: captionController.text,
      imageUrl: '',
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );

    // post cubit
    final postCubit = context.read<PostCubit>();

    // web upload
    if (kIsWeb) {
      postCubit.createPost(post, imageBytes: webImage);
    }
    // mobile upload
    else {
      postCubit.createPost(post, imagePath: selectedImage?.path);
    }
  }

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        // lodaing ..
        if (state is PostLoading || state is PostUploading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // build upload page
        return buildUploadPage();
      },
      listener: (context, state) {
        // go to previous page when upload is done & posts are loaded
        if (state is PostLoaded) {
          Navigator.pop(context);
        }
      },
    );
  }

  Widget buildUploadPage() {
    // SCAFFOLD
    return Scaffold(
      // APP BAR
      appBar: AppBar(
        title: Text('Create Post'),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            onPressed: uploadPost,
            icon: Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: Colors.green,
            ),
          ),
        ],
      ),

      // BODY
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // image preview for web
                if (kIsWeb && webImage != null) Image.memory(webImage!),

                // image preview for mobile
                if (!kIsWeb && selectedImage != null)
                  Image.file(File(selectedImage!.path!)),

                SizedBox(height: 10),

                // pick image button
                MaterialButton(
                  onPressed: pickImage,
                  color: Colors.blue.shade300,
                  child: Text('Pick Image'),
                ),

                SizedBox(height: 25),

                // caption text box
                MyTextField(
                  controller: captionController,
                  hintText: 'caption',
                  obscureText: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
