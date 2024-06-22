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
    final loading = ref.watch(triviaLoadingProvider);

    final itemScrollController = useMemoized(() => ItemScrollController());
    final itemPositionsListener = useMemoized(() => ItemPositionsListener.create());
    final scrollOffsetController = useMemoized(() => ScrollOffsetController());
    final scrollOffsetListener = useMemoized(() => ScrollOffsetListener.create());

    final initialized = useState(false);
    final topIndex = useState(0);
    final bottomIndex = useState(0);

    useEffect(() {
      listener() {
        final positions = itemPositionsListener.itemPositions.value;
        if (positions.isNotEmpty && trivia.isNotEmpty) {
          topIndex.value = min(positions.first.index, positions.last.index);
          bottomIndex.value = max(positions.first.index, positions.last.index);

          print("topIndex: ${topIndex.value}, bottomIndex: ${bottomIndex.value}");

          // final bottom = positions.last.index > positions.first.index ? positions.last : positions.first;
          // final leading = max(bottom.itemLeadingEdge, 0.0);
          // final trailing = min(bottom.itemTrailingEdge, 1.0);
          // final percent = ((trailing - leading) * 100).toInt();
          // print("bottom itemは画面表示領域の${percent}%を占有しています。");

          final shouldSmallerFetch = (topIndex.value - trivia.first.$1) <= 3 && initialized.value;
          if (shouldSmallerFetch) {
            ref.read(triviaProvider.notifier).fetchSmaller(10);
          }

          final shouldBiggerFetch = (trivia.last.$1 - bottomIndex.value) <= 3 && initialized.value;
          if (shouldBiggerFetch) {
            ref.read(triviaProvider.notifier).fetchBigger(10);
          }
        }
      }

      itemPositionsListener.itemPositions.addListener(listener);
      return () => itemPositionsListener.itemPositions.removeListener(listener);
    }, [trivia, initialized]);

    useEffect(() {
      // 40..59の配列を読み込む
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await provider.fetchTrivias(List.generate(20, (index) => index + 40));
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          // 40から数えて10 + 1番目の要素つまりは#50にスクロール
          // itemScrollController.scrollTo(
          //     index: 10, alignment: 1.0, duration: const Duration(seconds: 1), curve: Curves.easeInOutCubic);
          itemScrollController.jumpTo(index: 50 + 1, alignment: 1.0);
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            initialized.value = true;
          });
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
                Column(
                  children: [
                    if (trivia.isNotEmpty) Text("List: [${trivia.first.$1}..${trivia.last.$1}]"),
                    if (trivia.isNotEmpty) Text("Scroll Top Index: ${topIndex.value}"),
                    if (trivia.isNotEmpty) Text("Scroll Bottom Index: ${bottomIndex.value}"),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ScrollablePositionedList.builder(
              itemCount: trivia.isEmpty ? 0 : 100,
              itemBuilder: (context, index) {
                final (int, String)? foundTrivia = trivia.where((element) => element.$1 == index).firstOrNull;
                return switch (foundTrivia) {
                  null => const SizedBox(height: 0),
                  _ => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
                      child: ListTile(
                        leading: Text("${foundTrivia.$1}", style: const TextStyle(fontSize: 14.0)),
                        title: Text(foundTrivia.$2),
                      ),
                    )
                };
              },
              itemScrollController: itemScrollController,
              itemPositionsListener: itemPositionsListener,
              scrollOffsetController: scrollOffsetController,
              scrollOffsetListener: scrollOffsetListener,
              physics: const RangeMaintainingScrollPhysics(),
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
