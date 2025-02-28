import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_app/features/profile/domain/repo/profile_repo.dart';
import 'package:social_app/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_app/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.profileRepo, required this.storageRepo})
    : super(ProfileInitial());

  // fetch user profile using repo -> useful for loading profile pages
  Future<void> fetchProfileUser(String uid) async {
    try {
      emit(ProfileLoading());
      final user = await profileRepo.fetchProfileUser(uid);

      if (user != null) {
        emit(ProfileLoaded(user));
      } else {
        emit(ProfileError('user not found'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // return user profile given uid -> useful for loading many profiles for posts
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchProfileUser(uid);
    return user;
  }

  // update bio and or profile picture
  Future<void> updateProfileUser({
    required String uid,
    String? bio,
    Uint8List? imageWebBytes,
    String? imageMobilePath,
  }) async {
    emit(ProfileLoading());
    try {
      // fetch current user
      final currentUser = await profileRepo.fetchProfileUser(uid);
      if (currentUser == null) {
        emit(ProfileError('user not found for profile update'));
        return;
      }

      // profile picture update
      String? imageDownloadUrl;

      // ensure there is an image
      if (imageWebBytes != null || imageMobilePath != null) {
        // for mobile
        if (imageMobilePath != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(
            imageMobilePath,
            uid,
          );
        }
        // for web
        else if (imageWebBytes != null) {
          imageDownloadUrl = await storageRepo.uploadProfileImageWeb(
            imageWebBytes,
            uid,
          );
        }
      }

      // update new profile
      final updatedProfile = currentUser.copyWith(
        newBio: bio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      // update in repo
      await profileRepo.updateProfileUser(updatedProfile);

      // re-fetch updated profile
      final updatedUser = await profileRepo.fetchProfileUser(uid);
      emit(ProfileLoaded(updatedUser!));
    } catch (e) {
      emit(ProfileError('error updating profile: $e'));
    }
  }

  // toggle follow/unfollow
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      await profileRepo.toggleFollow(currentUid, targetUid);
    } catch (e) {
      emit(ProfileError('error toggle follow: $e'));
    }
  }
}
