import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_app/features/profile/domain/repo/profile_repo.dart';
import 'package:social_app/features/profile/presentation/cubits/profile_states.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;

  ProfileCubit({required this.profileRepo}) : super(ProfileInitial());

  // fetch user profile using repo
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

  // update bio and or profile picture
  Future<void> updateProfileUser({required String uid, String? bio}) async {
    emit(ProfileLoading());
    try {
      // fetch current user
      final currentUser = await profileRepo.fetchProfileUser(uid);
      if (currentUser == null) {
        emit(ProfileError('user not found for profile update'));
        return;
      }

      // profile picture update

      // update new profile
      final updatedProfile = currentUser.copyWith(
        newBio: bio ?? currentUser.bio,
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
}
