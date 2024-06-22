import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia_interactor.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia_repository.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia_repository_impl.dart';

class TriviaNotifier extends StateNotifier<List<Trivia>> {
  final Ref ref;
  TriviaNotifier(this.ref) : super([]);

  Future<void> fetchTrivias(List<int> numbers) async {
    if (ref.read(triviaLoadingProvider.notifier).state == true) return;

    final useCase = ref.read(triviaUseCaseProvider);
    try {
      ref.read(triviaLoadingProvider.notifier).state = true;
      final trivias = await useCase.fetchTrivias(numbers);
      debugPrint(trivias.toString());
      state += trivias;
    } finally {
      ref.read(triviaLoadingProvider.notifier).state = false;
    }
  }

  Future<void> fetchSmaller(int number) async {
    if (ref.read(triviaLoadingProvider.notifier).state == true) return;

    final useCase = ref.read(triviaUseCaseProvider);
    final model = ref.read(triviaModelProvider);

    final Trivia? minNumberOfTrivia = state.isEmpty ? null : state.reduce((a, b) => a.$1.compareTo(b.$1) < 0 ? a : b);
    final range =
        List.generate(number, (index) => minNumberOfTrivia!.$1 - index - 1).where((v) => v >= model.minNumber).toList();

    if (range.isEmpty) return;
    try {
      ref.read(triviaLoadingProvider.notifier).state = true;
      final trivias = await useCase.fetchTrivias(range);
      final fold = [...state, ...trivias];
      model.sort(fold);
      state = fold;
    } finally {
      ref.read(triviaLoadingProvider.notifier).state = false;
    }
  }

  Future<void> fetchBigger(int number) async {
    if (ref.read(triviaLoadingProvider.notifier).state == true) return;

    final useCase = ref.read(triviaUseCaseProvider);
    final model = ref.read(triviaModelProvider);

    final Trivia? maxNumberOfTrivia = state.isEmpty ? null : state.reduce((a, b) => a.$1.compareTo(b.$1) > 0 ? a : b);
    final range =
        List.generate(number, (index) => maxNumberOfTrivia!.$1 + index + 1).where((v) => v <= model.maxNumber).toList();

    if (range.isEmpty) return;
    try {
      ref.read(triviaLoadingProvider.notifier).state = true;
      final trivias = await useCase.fetchTrivias(range);
      final fold = [...state, ...trivias];
      model.sort(fold);
      state = fold;
    } finally {
      ref.read(triviaLoadingProvider.notifier).state = false;
    }
  }
}

final triviaProvider = StateNotifierProvider<TriviaNotifier, List<Trivia>>((ref) {
  return TriviaNotifier(ref);
});

final triviaLoadingProvider = StateProvider<bool>(
  (ref) => false,
);

final triviaRepositoryProvider = Provider<TriviaRepository>((ref) {
  return TriviaRepositoryImpl(dio: Dio());
});

final triviaUseCaseProvider = Provider<TriviaUseCase>((ref) {
  final repo = ref.read(triviaRepositoryProvider);
  return TriviaInteractor(repo: repo);
});

final triviaModelProvider = Provider<TriviaBisinessLogic>((ref) {
  return TriviaModel();
});
