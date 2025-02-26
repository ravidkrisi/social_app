import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_app/features/post/domain/entities/post.dart';
import 'package:social_app/features/post/domain/repos/post_repo.dart';

class FirebasePostRepo implements PostRepo {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  final postsCollection = FirebaseFirestore.instance.collection('posts');

  @override
  Future<void> createPost(Post post) async {
    try {
      await postsCollection.doc(post.id).set(post.toJson());
    } catch (e) {
      throw Exception("error creating post: $e");
    }
  }

  @override
  Future<void> deletePost(String id) async {
    try {
      await postsCollection.doc(id).delete();
    } catch (e) {
      throw Exception("error deleting post: $e");
    }
  }

  @override
  Future<List<Post>> fetchAllPosts() async {
    try {
      // get all posts with most recent posts at the top
      final postsSnapshot =
          await postsCollection.orderBy('timestamp', descending: true).get();

      // convert each doc json -> list of posts
      final List<Post> allPosts =
          postsSnapshot.docs.map((doc) => Post.fromJson(doc.data())).toList();

      return allPosts;
    } catch (e) {
      throw Exception("failed fetching posts: $e");
    }
  }

  @override
  Future<List<Post>> fetchPostsByUserId(String uid) async {
    try {
      // get all posts with most recent posts at the top
      final postsSnapshot =
          await postsCollection
              .where('uid', isEqualTo: uid)
              .orderBy('timestamp', descending: true)
              .get();

      // convert each doc json -> list of posts
      final List<Post> allPosts =
          postsSnapshot.docs.map((doc) => Post.fromJson(doc.data())).toList();

      return allPosts;
    } catch (e) {
      throw Exception("failed fetching posts: $e");
    }
  }
}
