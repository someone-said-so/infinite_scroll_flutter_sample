import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia_notifier.dart';
import 'package:infinite_scroll_flutter_sample/widget/scroll_control_header.dart';
import 'package:infinite_scroll_flutter_sample/widget/scrollable_list.dart';
import 'package:infinite_scroll_flutter_sample/widget/trivia_list_item.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MyHomePage extends HookConsumerWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // スクロールインデックスの初期位置
    const initialScrollIndex = 10;
    const initialLeadingEdge = 0.0;

    final trivia = ref.watch(triviaProvider);
    final triviaNotifier = ref.read(triviaProvider.notifier);
    final loading = ref.watch(triviaLoadingProvider);

    final itemScrollController = useMemoized(() => ItemScrollController());
    final scrollOffsetController = useMemoized(() => ScrollOffsetController());
    final scrollableListener = useMemoized(() => ScrollableListEventListener.create());

    final initialized = useState(false);
    final topIndex = useState(0);
    final bottomIndex = useState(0);

    useEffect(() {
      onScrollOffsetEvent() {
        (switch (scrollableListener.event.value) {
          ScrollableListEventScrollOffset(:final offset) => () {
              print("offset: $offset");
            },
          _ => () {},
        })();
      }

      scrollableListener.event.addListener(onScrollOffsetEvent);
      return () => scrollableListener.event.removeListener(onScrollOffsetEvent);
    }, []);

    useEffect(() {
      onItemPositionEvent() {
        (switch (scrollableListener.event.value) {
          ScrollableListEventItemPositions(:final positions) => () {
              if (positions.isNotEmpty && trivia.isNotEmpty) {
                topIndex.value = min(positions.first.index, positions.last.index);
                bottomIndex.value = max(positions.first.index, positions.last.index);

                // final bottom = positions.last.index > positions.first.index ? positions.last : positions.first;
                // final leading = max(bottom.itemLeadingEdge, 0.0);
                // final trailing = min(bottom.itemTrailingEdge, 1.0);
                // final percent = ((trailing - leading) * 100).toInt();
                // print("bottom itemは画面表示領域の$percent%を占有しています。");

                final shouldSmallerFetch = topIndex.value <= 3 && initialized.value;
                if (shouldSmallerFetch) triviaNotifier.fetchSmaller(10);

                final shouldBiggerFetch = (trivia.length - bottomIndex.value) <= 3 && initialized.value;
                if (shouldBiggerFetch) triviaNotifier.fetchBigger(10);
              }
            },
          _ => () {},
        })();
      }

      scrollableListener.event.addListener(onItemPositionEvent);
      return () => scrollableListener.event.removeListener(onItemPositionEvent);
    }, [trivia, initialized]);

    useEffect(() {
      const startingNumber = 40;
      // 40..59の配列を読み込む
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await triviaNotifier.fetchTrivias(List.generate(20, (index) => index + startingNumber));
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          initialized.value = true;
        });
      });
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (loading) const CircularProgressIndicator(),
                if (trivia.isNotEmpty)
                  ScrollControlHeader(
                    firstIndex: trivia.first.$1,
                    lastIndex: trivia.last.$1,
                    scrollIndex: (topIndex: topIndex.value, bottomIndex: bottomIndex.value),
                  ),
              ],
            ),
          ),
          if (trivia.isNotEmpty)
            Expanded(
              child: ScrollableList(
                itemCount: trivia.length,
                itemBuilder: (context, index) {
                  final Trivia foundTrivia = trivia[index];
                  return switch (foundTrivia) {
                    null => const SizedBox(height: 0),
                    _ => TriviaListItem(trivia: foundTrivia),
                  };
                },
                itemScrollController: itemScrollController,
                scrollOffsetController: scrollOffsetController,
                listener: scrollableListener,
                initialScrollIndex: initialScrollIndex,
                initialAlignment: initialLeadingEdge,
                physics: const RangeMaintainingScrollPhysics(), // NeverScrollableScrollPhysicsにするとユーザーのスクロールを無効にできる
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scrollOffsetController.animateScroll(
            offset: -200.0,
            duration: const Duration(seconds: 2),
            curve: Curves.easeOut,
          );
          // 10 + 1番目の要素つまりは#50にスクロール
          // itemScrollController.scrollTo(
          // itemScrollController.jumpTo(index: 10 + 1, alignment: 1.0);
        },
        tooltip: 'Test',
        child: const Icon(Icons.add),
      ),
    );
  }
}
