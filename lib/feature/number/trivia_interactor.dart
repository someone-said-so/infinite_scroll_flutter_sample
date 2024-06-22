import 'package:flutter/material.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia_repository.dart';

class TriviaInteractor implements TriviaUseCase {
  final TriviaRepository repo;

  TriviaInteractor({required this.repo});

  @override
  Future<List<Trivia>> fetchTrivias(List<int> numbers) async {
    final trivias = await repo.fetchTrivias(numbers);
    debugPrint(trivias.toString());

    return trivias.entries.map((element) => (int.parse(element.key), element.value)).toList();
  }
}

abstract class TriviaUseCase {
  Future<List<Trivia>> fetchTrivias(List<int> numbers);
}
