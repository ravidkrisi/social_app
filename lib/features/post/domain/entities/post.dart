// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/post/domain/entities/comment.dart';

class Post {
  final String id;
  final String uid;
  final String userName;
  final String caption;
  final String imageUrl;
  final DateTime timestamp;
  final List<String> likes;
  final List<Comment> comments;

  Post({
    required this.id,
    required this.uid,
    required this.userName,
    required this.caption,
    required this.imageUrl,
    required this.timestamp,
    required this.likes,
    required this.comments,
  });

  Post copyWith({String? newimageUrl}) {
    return Post(
      id: id,
      uid: uid,
      userName: userName,
      caption: caption,
      imageUrl: newimageUrl ?? imageUrl,
      timestamp: timestamp,
      likes: likes,
      comments: comments,
    );
  }

  // convert post -> json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'user_name': userName,
      'caption': caption,
      'image_url': imageUrl,
      'timestamp': timestamp,
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
    };
  }

  // convery json -> post

  factory Post.fromJson(Map<String, dynamic> json) {
    // prepare comments
    final List<Comment> comments =
        (json['comments'] as List<dynamic>?)
            ?.map((commentJson) => Comment.fromJson(commentJson))
            .toList() ??
        [];
    return Post(
      id: json['id'],
      uid: json['uid'],
      userName: json['user_name'],
      caption: json['caption'],
      imageUrl: json['image_url'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      likes: List<String>.from(json['likes'] ?? []),
      comments: comments,
    );
  }
}
