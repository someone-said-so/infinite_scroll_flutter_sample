import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// ScrollablePositionedListのラッパークラス
class ScrollableList extends StatefulWidget {
  /// Number of items the [itemBuilder] can produce.
  final int itemCount;

  /// Called to build children for the list with
  /// 0 <= index < itemCount.
  final IndexedWidgetBuilder itemBuilder;

  /// Controller for jumping or scrolling to an item.
  final ItemScrollController? itemScrollController;

  /// Controller for animate to an offset.
  final ScrollOffsetController? scrollOffsetController;

  /// ScrollableListEventを受け取れリスナー
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
    this.scrollOffsetController,
    ScrollableListEventListener? listener,
    this.initialScrollIndex = 0,
    this.initialAlignment = 0,
    this.physics,
  }) : notifier = listener as ScrollableListEventNotifier?;

  @override
  ScrollableListState createState() => ScrollableListState();
}

class ScrollableListState extends State<ScrollableList> {
  late ItemScrollController? _itemScrollController;
  late ScrollOffsetController? _scrollOffsetController;
  final _itemPositionsListener = ItemPositionsListener.create();
  final _scrollOffsetListener = ScrollOffsetListener.create();
  late StreamSubscription<double>? _subscription;
  var scrollHistory = (<(double, DateTime)>[]);

  @override
  void initState() {
    super.initState();
    // ScrollableListで指定されたControllerがない場合は自身でControllerを生成する
    _itemScrollController = widget.itemScrollController ?? ItemScrollController();
    _scrollOffsetController = widget.scrollOffsetController ?? ScrollOffsetController();
    // 内部のリスナーを登録する
    widget.notifier?.event.addListener(_update);
    _itemPositionsListener.itemPositions.addListener(_listenItemPositions);
    // スクロールの変化を日時とのセットの最新10件を保持する
    _subscription = _scrollOffsetListener.changes.listen((offset) {
      scrollHistory = [(offset, DateTime.now()), ...scrollHistory].take(10).toList();
      // ScrollableListのリスナーにイベントを発行する
      widget.notifier?.event.value = ScrollableListEventScrollOffset(offset);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant ScrollableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _itemScrollController = widget.itemScrollController ?? ItemScrollController();
    _scrollOffsetController = widget.scrollOffsetController ?? ScrollOffsetController();

    // アイテムが増えた時の処理
    final addedCount = widget.itemCount - oldWidget.itemCount;
    if (addedCount > 0) {
      // 直近1秒間のスクロール量を積分する
      // NOTE: 負数は上方向にスクロールしたことを示す
      final scrollOffsetInSecond = scrollHistory
          .where((record) => DateTime.now().difference(record.$2).inSeconds <= 1)
          .fold(0.0, (acc, current) => acc + current.$1);

      // 現在のアイテムの位置を取得する
      final positions = _itemPositionsListener.itemPositions.value;
      final top = positions.first.index <= positions.last.index ? positions.first : positions.last;
      final scrollIndex = top.index;
      final leadingEdge = top.itemLeadingEdge;

      /*
       * （上["10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20"]下）という配列があり、画面上表示されているアイテムが["12", "13", "14"]だとする。
       * 残りの表示が3つ以下に10個追加ロードする場合、index = 2("12")の時に前方から0..9が足されると["2", "3", "4"]になりいきなりスクロール位置が瞬間的に変わったように見えてしまう。
       * なお下方向のスクロールで配列が後方から追加される場合は問題がない。
       */
      if (addedCount > 0 && scrollOffsetInSecond < 0.0) {
        /*
         * そこで、スクロール位置が見た目の上で急に変わらないように増えた分だけスクロール位置を移動してユーザーが元々みていたアイテムが画面上に表示されるようにする。
         */
        _itemScrollController?.jumpTo(index: scrollIndex + addedCount, alignment: leadingEdge);
        // jumpToをすると惰性スクロールが止まってしまうため、指で操作して違和感がないようにする
        _scrollOffsetController?.animateScroll(
          // NOTE: この値は適当な値であり、scrollOffsetInSecondに相関性のある畳み込み処理で調整するとより自然な惰性スクロールができる
          offset: -500.0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  void dispose() {
    widget.notifier?.event.removeListener(_update);
    _itemPositionsListener.itemPositions.removeListener(_listenItemPositions);
    _subscription?.cancel();
    super.dispose();
  }

  void _update() {}

  void _listenItemPositions() {
    // 内部のインデックスが変化した時の処理
    final positions = _itemPositionsListener.itemPositions.value;
    final top = positions.first.index <= positions.last.index ? positions.first : positions.last;
    print("scrollIndex: ${top.index}, leadingEdge: ${top.itemLeadingEdge}");
    // ScrollableListのリスナーにイベントを発行する
    widget.notifier?.event.value = ScrollableListEventItemPositions(positions);
  }

  @override
  Widget build(BuildContext context) {
    return ScrollablePositionedList.builder(
      itemCount: widget.itemCount,
      itemBuilder: widget.itemBuilder,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
      scrollOffsetController: _scrollOffsetController,
      scrollOffsetListener: _scrollOffsetListener,
      initialScrollIndex: widget.initialScrollIndex,
      initialAlignment: widget.initialAlignment,
      physics: widget.physics,
    );
  }
}

/// ScrollableListEventListenerが受け取れるイベントの宣言
sealed class ScrollableListEvent {
  const ScrollableListEvent();
}

class ScrollableListEventNothing extends ScrollableListEvent {
  const ScrollableListEventNothing();
}

/// 内部のアイテムの位置が変化した時に[positions]でその配置をイベントとして発行する
class ScrollableListEventItemPositions extends ScrollableListEvent {
  final Iterable<ItemPosition> positions;
  const ScrollableListEventItemPositions(this.positions);
}

/// スクロールした時の変化量を[offset]として発行する
class ScrollableListEventScrollOffset extends ScrollableListEvent {
  final double offset;
  const ScrollableListEventScrollOffset(this.offset);
}

/// ScrollableListで発行されるEventのListenerインターフェース
abstract class ScrollableListEventListener {
  factory ScrollableListEventListener.create() => ScrollableListEventNotifier();
  ValueListenable<ScrollableListEvent> get event;
}

/// Internal implementation of [ItemPositionsListener].
class ScrollableListEventNotifier implements ScrollableListEventListener {
  @override
  final ValueNotifier<ScrollableListEvent> event = ValueNotifier(const ScrollableListEventNothing());
}
