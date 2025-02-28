import 'package:flutter/material.dart';

class PorfileStats extends StatelessWidget {
  final int postsCount;
  final int followersCount;
  final int followingCount;
  const PorfileStats({
    super.key,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
  });

  @override
  Widget build(BuildContext context) {
    // text style for digit
    var textStyleDigit = TextStyle(
      fontSize: 20,
      color: Theme.of(context).colorScheme.inversePrimary,
    );
    var textStyleText = TextStyle(color: Theme.of(context).colorScheme.primary);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // posts
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(postsCount.toString(), style: textStyleDigit),
              Text('Posts', style: textStyleText),
            ],
          ),
        ),

        // followers
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(followersCount.toString(), style: textStyleDigit),
              Text('Followers', style: textStyleText),
            ],
          ),
        ),

        // following
        SizedBox(
          width: 100,
          child: Column(
            children: [
              Text(followingCount.toString(), style: textStyleDigit),
              Text('Following', style: textStyleText),
            ],
          ),
        ),
      ],
    );
  }
}
