import 'package:social_app/features/post/domain/entities/post.dart';

abstract class PostRepo {
  Future<List<Post>> fetchAllPosts();
  Future<void> createPost(Post post);
  Future<void> deletePost(String id);
  Future<List<Post>> fetchPostsByUserId(String uid);
}
