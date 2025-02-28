import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_app/features/profile/domain/repo/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Future<ProfileUser?> fetchProfileUser(String uid) async {
    try {
      final userDoc = await firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();

        if (userData != null) {
          return ProfileUser.fromJson(userData);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateProfileUser(ProfileUser updatedProfile) async {
    try {
      await firestore.collection('users').doc(updatedProfile.uid).update({
        'bio': updatedProfile.bio,
        'profile_image_url': updatedProfile.profileImageUrl,
      });
    } catch (e) {
      print('error updating profile: $e');
    }
  }

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      // fetch users docs
      final currUserDoc =
          await firestore.collection('users').doc(currentUid).get();
      final targetUserDoc =
          await firestore.collection('users').doc(targetUid).get();

      if (currUserDoc.exists && targetUserDoc.exists) {
        // get users data
        final currentUserData = currUserDoc.data();
        final targetUserData = targetUserDoc.data();

        if (currentUserData != null && targetUserData != null) {
          // create users objects
          final currUser = ProfileUser.fromJson(
            currentUserData as Map<String, dynamic>,
          );
          final targetUser = ProfileUser.fromJson(
            targetUserData as Map<String, dynamic>,
          );

          // check if the current user is already following the target user
          final currentFollowing = currUser.following;

          if (currentFollowing.contains(targetUser.uid)) {
            // unfollow
            await firestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayRemove([targetUid]),
            });
            await firestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayRemove([currentUid]),
            });
          }
          // follow
          else {
            await firestore.collection('users').doc(currentUid).update({
              'following': FieldValue.arrayUnion([targetUid]),
            });
            await firestore.collection('users').doc(targetUid).update({
              'followers': FieldValue.arrayUnion([currentUid]),
            });
          }
        }
      }
    } catch (e) {}
  }
}
