import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia_notifier.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MyHomePage extends HookConsumerWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trivia = ref.watch(triviaProvider);
    final provider = ref.read(triviaProvider.notifier);

    final itemScrollController = useMemoized(() => ItemScrollController());
    final itemPositionsListener = useMemoized(() => ItemPositionsListener.create());
    // final scrollOffsetController = useMemoized(() => ScrollOffsetController());
    // final scrollOffsetListener = useMemoized(() => ScrollOffsetListener.create());

    final topIndex = useState(0);
    final bottomIndex = useState(0);

    final listener = useCallback(() {
      final positions = itemPositionsListener.itemPositions.value;
      if (positions.isNotEmpty) {
        topIndex.value = min(positions.first.index, positions.last.index);
        bottomIndex.value = max(positions.first.index, positions.last.index);

        // final bottom = positions.last.index > positions.first.index ? positions.last : positions.first;
        // final leading = max(bottom.itemLeadingEdge, 0.0);
        // final trailing = min(bottom.itemTrailingEdge, 1.0);
        // final percent = ((trailing - leading) * 100).toInt();
        // print("bottom itemは画面表示領域の${percent}%を占有しています。");
      }
    });

    useEffect(() {
      // 40..59の配列を読み込む
      provider.fetchTrivias(List.generate(20, (index) => index + 40)).then<void>((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // 40から数えて10番目の要素つまりは#49にスクロール
          // itemScrollController.scrollTo(
          //     index: 10, alignment: 1.0, duration: const Duration(seconds: 1), curve: Curves.easeInOutCubic);
          itemScrollController.jumpTo(index: 10);
        });
      });
      itemPositionsListener.itemPositions.addListener(listener);

      return () => itemPositionsListener.itemPositions.removeListener(listener);
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
            child: Column(
              children: [
                if (trivia.isNotEmpty) Text("List: [${trivia.first.$1}..${trivia.last.$1}]"),
                if (trivia.isNotEmpty) Text("Scroll Top Index: ${topIndex.value} = ${trivia[topIndex.value].$1}"),
                if (trivia.isNotEmpty)
                  Text("Scroll Bottom Index: ${bottomIndex.value} = ${trivia[bottomIndex.value].$1}"),
              ],
            ),
          ),
          Expanded(
            child: ScrollablePositionedList.separated(
              itemCount: trivia.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
                  child: ListTile(
                    leading: Text("${trivia[index].$1}", style: const TextStyle(fontSize: 14.0)),
                    title: Text(trivia[index].$2),
                  ),
                );
              },
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              // scrollOffsetController: scrollOffsetController,
              // scrollOffsetListener: scrollOffsetListener,
              separatorBuilder: (BuildContext context, int index) => const Divider(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {},
        tooltip: 'Action',
        child: const Icon(Icons.adjust),
      ),
    );
  }
}
