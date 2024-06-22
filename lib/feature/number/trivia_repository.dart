abstract class TriviaRepository {
  Future<String> fetchTrivia(int number);
  Future<Map<String, String>> fetchTrivias(List<int> numbers);
}
