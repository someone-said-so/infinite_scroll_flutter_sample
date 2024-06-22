typedef Trivia = (int, String);

class TriviaModel implements TriviaBisinessLogic {
  @override
  final int minNumber = 0;
  @override
  final int maxNumber = 99;

  @override
  List<Trivia> sort(List<Trivia> unsorted) {
    unsorted.sort((a, b) => a.$1.compareTo(b.$1));
    return unsorted;
  }
}

abstract class TriviaBisinessLogic {
  int get minNumber;
  int get maxNumber;
  List<Trivia> sort(List<Trivia> unsorted);
}
