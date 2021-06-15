import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/errors/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NumberTriviaLocalDatasource {
  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present.
  Future<NumberTriviaModel> getLastNumberTrivia();

  void cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

const CACHED_NUMBER_TRIVIA = 'CACHED_NUMBER_TRIVIA';

class NumberTriviaLocalDatasourceImpl implements NumberTriviaLocalDatasource {
  final SharedPreferences preferences;

  NumberTriviaLocalDatasourceImpl({required this.preferences});

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) {
    final value = jsonEncode(triviaToCache.toJson());
    return preferences.setString(
      CACHED_NUMBER_TRIVIA,
      value,
    );
  }

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = preferences.getString(CACHED_NUMBER_TRIVIA);
    if (jsonString != null) {
      return Future.value(NumberTriviaModel.fromJson(jsonDecode(jsonString)));
    } else {
      throw CacheException();
    }
  }
}
