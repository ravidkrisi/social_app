import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/repos/post_repo.dart';
import 'package:social_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_app/features/storage/domain/storage_repo.dart';

class PostCubit extends Cubit<PostState> {
  final PostRepo postRepo;
  final StorageRepo storageRepo;

  PostCubit({required this.postRepo, required this.storageRepo})
    : super(PostInitial());

  // create a new post
  Future<void> createPost(
    Post post, {
    String? imagePath,
    Uint8List? imageBytes,
  }) async {
    String? imageUrl;

    try {
      // handle image upload for mobile platforms (using file path)
      if (imagePath != null) {
        emit(PostLoading());
        imageUrl = await storageRepo.uploadPostImageMobile(imagePath, post.id);
      }
      // handle image upload for web platforms (using file bytes)
      else if (imageBytes != null) {
        emit(PostLoading());
        imageUrl = await storageRepo.uploadPostImageWeb(imageBytes, post.id);
      }

      // add image url to the post
      final newPost = post.copyWith(newimageUrl: imageUrl);

      // add post in backend
      await postRepo.createPost(newPost);

      // re-fetch all posts
      fetchAllPosts();
    } catch (e) {
      emit(PostError('error creating post: $e'));
    }
  }

  // fetch all posts
  Future<void> fetchAllPosts() async {
    try {
      emit(PostLoading());
      final posts = await postRepo.fetchAllPosts();
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError('error fetching all posts: $e'));
    }
  }

  // delete post
  Future<void> deletePost(String id) async {
    try {
      await postRepo.deletePost(id);
    } catch (e) {
      emit(PostError('error deleting post: $e'));
    }
  }

  // toggle like on post
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      await postRepo.toggleLikePost(postId, userId);
    } catch (e) {
      emit(PostError('failed to toggle like: $e'));
    }
  }
}
