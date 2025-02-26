// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String uid;
  final String userName;
  final String caption;
  final String imageUrl;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.uid,
    required this.userName,
    required this.caption,
    required this.imageUrl,
    required this.timestamp,
  });

  Post copyWith({String? newimageUrl}) {
    return Post(
      id: id,
      uid: uid,
      userName: userName,
      caption: caption,
      imageUrl: newimageUrl ?? imageUrl,
      timestamp: timestamp,
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
    };
  }

  // convery json -> post

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      uid: json['uid'],
      userName: json['user_name'],
      caption: json['caption'],
      imageUrl: json['image_url'],
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
