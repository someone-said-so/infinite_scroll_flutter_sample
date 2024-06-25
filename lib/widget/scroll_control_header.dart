import 'package:flutter/material.dart';

class ScrollControlHeader extends StatelessWidget {
  final int firstIndex;
  final int lastIndex;
  final ({int topIndex, int bottomIndex}) scrollIndex;
  const ScrollControlHeader({super.key, required this.firstIndex, required this.lastIndex, required this.scrollIndex});

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text("List: [$firstIndex..$lastIndex]"),
          Text("Scroll Top Index: ${scrollIndex.topIndex}}"),
          Text("Scroll Bottom Index: ${scrollIndex.bottomIndex}"),
        ],
      );
}
