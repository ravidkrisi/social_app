import 'package:flutter/material.dart';

class BioBox extends StatelessWidget {
  final String text;
  const BioBox({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding inside
      padding: EdgeInsets.all(25),

      width: double.infinity,

      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
      child: Text(
        text.isNotEmpty ? text : 'Add bio',
        style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
      ),
    );
  }
}
