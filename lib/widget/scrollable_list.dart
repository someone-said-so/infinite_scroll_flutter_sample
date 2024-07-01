// ignore_for_file: library_private_types_in_public_api

import 'dart:async';

import 'package:flutter/foundation.dart';
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

  final ScrollableListEventNotifier? notifier;

  /// Index of an item to initially align within the viewport.
  final int initialScrollIndex;

  /// Determines where the leading edge of the item at [initialScrollIndex]
  /// should be placed.
  ///
  /// See [ItemScrollController.jumpTo] for an explanation of alignment.
  final double initialAlignment;

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
    ScrollableListEventListener? listener,
    this.initialScrollIndex = 0,
    this.initialAlignment = 0,
    this.physics,
  }) : notifier = listener as ScrollableListEventNotifier?;

  static StreamController<int> eventStreamController() => StreamController<int>();

  @override
  _ScrollableListState createState() => _ScrollableListState();
}

class _ScrollableListState extends State<ScrollableList> {
  late ItemScrollController? _itemScrollController;
  late ScrollOffsetController? _scrollOffsetController;
  final controller = StreamController();

  @override
  void initState() {
    super.initState();
    _itemScrollController = widget.itemScrollController ?? ItemScrollController();
    _scrollOffsetController = widget.scrollOffsetController ?? ScrollOffsetController();
    widget.notifier?.event.addListener(_update);
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
    print("ScrollableList is updated. $oldWidget -> $widget");
    _itemScrollController = widget.itemScrollController ?? ItemScrollController();
    _scrollOffsetController = widget.scrollOffsetController ?? ScrollOffsetController();

    widget.notifier?.event.value = ScrollableListEventNothing();
  }

  @override
  void dispose() {
    print("ScrollableList is unmounted.");
    widget.notifier?.event.removeListener(_update);
    super.dispose();
  }

  void _update() {}

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
      itemScrollController: _itemScrollController,
      itemPositionsListener: widget.itemPositionsListener,
      scrollOffsetController: _scrollOffsetController,
      scrollOffsetListener: widget.scrollOffsetListener,
      initialScrollIndex: widget.initialScrollIndex,
      physics: widget.physics,
    );
  }
}

sealed class ScrollableListEvent {
  const ScrollableListEvent();
}

class ScrollableListEventNothing extends ScrollableListEvent {
  const ScrollableListEventNothing();
}

abstract class ScrollableListEventListener {
  factory ScrollableListEventListener.create() => ScrollableListEventNotifier();
  ValueListenable<ScrollableListEvent> get event;
}

/// Internal implementation of [ItemPositionsListener].
class ScrollableListEventNotifier implements ScrollableListEventListener {
  @override
  final ValueNotifier<ScrollableListEvent> event = ValueNotifier(const ScrollableListEventNothing());
}
