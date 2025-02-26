/*

Profile Repository

*/

import 'package:social_app/features/profile/domain/entities/profile_user.dart';

abstract class ProfileRepo {
  Future<ProfileUser?> fetchProfileUser(String uid);
  Future<void> updateProfileUser(ProfileUser updatedProfile);
}
