import 'package:flutter/material.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia.dart';

class TriviaListItem extends StatelessWidget {
  final Trivia trivia;
  const TriviaListItem({super.key, required this.trivia});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
        child: ListTile(
          leading: Text("${trivia.$1}", style: const TextStyle(fontSize: 14.0)),
          title: Text(trivia.$2),
        ),
      );
}
