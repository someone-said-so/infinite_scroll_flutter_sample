import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia_repository.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia_repository_impl.dart';

class TriviaNotifier extends StateNotifier<List<Trivia>> {
  final Ref ref;
  TriviaNotifier(this.ref) : super([]);

  Future<void> fetchTrivias(List<int> numbers) async {
    final repo = ref.read(triviaRepositoryProvider);
    final trivias = await repo.fetchTrivias(numbers);
    debugPrint(trivias.toString());

    state += trivias.entries.map((element) => (int.parse(element.key), element.value)).toList();
  }
}

final triviaProvider = StateNotifierProvider<TriviaNotifier, List<Trivia>>((ref) {
  return TriviaNotifier(ref);
});

final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  return TriviaRepositoryImpl();
});
