import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:social_app/features/post/domain/entities/comment.dart';
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

  @override
  Future<void> toggleLikePost(String postId, String userId) async {
    try {
      // get post doc from firestore
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        // doc -> post object
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // check if user had already like the post
        final hasLiked = post.likes.contains(userId);

        // update the likes list
        if (hasLiked) {
          // unlike
          post.likes.remove(userId);
        } else {
          // like
          post.likes.add(userId);
        }

        // update post doc with the new likes list
        await postsCollection.doc(postId).update({'likes': post.likes});
      } else {
        throw Exception('post not found');
      }
    } catch (e) {
      throw Exception('Error toggling like: $e');
    }
  }

  @override
  Future<void> addComment(String postId, Comment comment) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        // convert post json -> post object
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // add the new comment
        post.comments.add(comment);

        // update the post doc in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception('post not found: $postId');
      }
    } catch (e) {
      throw Exception('error adding comment: $e');
    }
  }

  @override
  Future<void> deleteComment(String postId, String commentId) async {
    try {
      final postDoc = await postsCollection.doc(postId).get();

      if (postDoc.exists) {
        // convert post json -> post object
        final post = Post.fromJson(postDoc.data() as Map<String, dynamic>);

        // remove the comment
        post.comments.removeWhere((comment) => comment.id == commentId);

        // update the post doc in firestore
        await postsCollection.doc(postId).update({
          'comments': post.comments.map((comment) => comment.toJson()).toList(),
        });
      } else {
        throw Exception('post not found: $postId');
      }
    } catch (e) {
      throw Exception('error removing comment: $e');
    }
  }
}
