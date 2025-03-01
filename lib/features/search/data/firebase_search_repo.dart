import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_app/features/search/domain/search_repo.dart';

class FirebaseSearchRepo implements SearchRepo {
  final usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  Future<List<ProfileUser?>> searchUser(String query) async {
    try {
      final result =
          await usersCollection
              .where('name', isGreaterThanOrEqualTo: query)
              .where('name', isLessThanOrEqualTo: '$query\uf8ff')
              .get();

      final users =
          result.docs.map((doc) => ProfileUser.fromJson(doc.data())).toList();
      return users;
    } catch (e) {
      throw Exception('error search users: $e');
    }
  }
}
