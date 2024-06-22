import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:infinite_scroll_flutter_sample/feature/number/trivia_repository.dart';

class TriviaRepositoryImpl extends TriviaRepository {
  @override
  Future<String> fetchTrivia(int number) async {
    try {
      Dio dio = Dio();

      Response response = await dio.get('http://numbersapi.com/$number');

      if (response.statusCode == 200) {
        return response.data.toString();
      } else {
        throw Exception('Failed to fetch trivia');
      }
    } catch (e) {
      throw Exception('Failed to fetch trivia: $e');
    }
  }

  @override
  Future<Map<String, String>> fetchTrivias(List<int> numbers) async {
    try {
      Dio dio = Dio();
      final numbersString = numbers.join(',');
      Response response = await dio.get<String>(
        'http://numbersapi.com/$numbersString',
        options: Options(responseType: ResponseType.plain),
      );

      /*
       * 以下のようなレスポンスが返ってくる
{
 "1": "1 is the number of dimensions of a line.",
 "2": "2 is the price in cents per acre the USA bought Alaska from Russia.",
 "3": "3 is the number of witches in William Shakespeare's Macbeth.",
}
       */

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.data) as Map<String, dynamic>;
        final converted = decoded.map((key, value) => MapEntry(key, value.toString()));
        return Map<String, String>.from(converted);
      } else {
        throw Exception('Failed to fetch trivia');
      }
    } catch (e) {
      throw Exception('Failed to fetch trivia: $e');
    }
  }
}
