import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ScrollableList extends StatefulWidget {
  /// Number of items the [itemBuilder] can produce.
  final int itemCount;

  /// Called to build children for the list with
  /// 0 <= index < itemCount.
  final IndexedWidgetBuilder itemBuilder;

  /// Controller for jumping or scrolling to an item.
  final ItemScrollController? itemScrollController;

  /// Notifier that reports the items laid out in the list after each frame.
  final ItemPositionsListener? itemPositionsListener;

  final ScrollOffsetController? scrollOffsetController;

  /// Notifier that reports the changes to the scroll offset.
  final ScrollOffsetListener? scrollOffsetListener;

  /// Index of an item to initially align within the viewport.
  final int initialScrollIndex;

  /// How the scroll view should respond to user input.
  ///
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// See [ScrollView.physics].
  final ScrollPhysics? physics;

  const ScrollableList({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.itemScrollController,
    this.itemPositionsListener,
    this.scrollOffsetController,
    this.scrollOffsetListener,
    this.initialScrollIndex = 0,
    this.physics,
  });

  @override
  _ScrollableListState createState() => _ScrollableListState();
}

class _ScrollableListState extends State<ScrollableList> {
  @override
  void initState() {
    super.initState();
    print("ScrollableList is mounted.");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("ScrollableList get ready.");
  }

  @override
  void didUpdateWidget(covariant ScrollableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    print("ScrollableList is updated.");
  }

  @override
  void dispose() {
    print("ScrollableList is unmounted.");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
      itemScrollController: widget.itemScrollController,
      itemPositionsListener: widget.itemPositionsListener,
      scrollOffsetController: widget.scrollOffsetController,
      scrollOffsetListener: widget.scrollOffsetListener,
      initialScrollIndex: widget.initialScrollIndex,
      physics: widget.physics,
    );
  }
}
