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
}
