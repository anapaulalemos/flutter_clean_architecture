import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/errors/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDatasourceImpl datasource;
  late MockSharedPreferences mockSharedPreferences;

  final json = fixture('trivia_cached.json');
  final tNumberTriviaModel = NumberTriviaModel.fromJson(jsonDecode(json));

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    datasource = NumberTriviaLocalDatasourceImpl(preferences: mockSharedPreferences);
  });

  group('getLastNumberTrivia', () {
    test(
        'should return NumberTrivia from sharedPreferences when there is one in the cache',
        () async {
      //arrange
      when(() => mockSharedPreferences.getString(any())).thenReturn(json);
      //act
      final result = await datasource.getLastNumberTrivia();
      //assert
      verify(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA));
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a CacheException when there is not a cached value', () async {
      //arrange
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);
      //act
      final call = datasource.getLastNumberTrivia;
      //assert
      expect(() => call(), throwsA(TypeMatcher<CacheException>()));
    });
  });

  //TODO: FIX THIS FUKING TEST
  group('cacheNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'test trivia');

    test('should call SharedPreferences to cache the data', () async {
      // act
      datasource.cacheNumberTrivia(tNumberTriviaModel);
      await untilCalled(() => mockSharedPreferences.setString(any(), any()));
      // assert
      verify(
        () => mockSharedPreferences.setString(
          CACHED_NUMBER_TRIVIA,
          jsonEncode(tNumberTriviaModel.toJson()),
        ),
      ).called(1);
    });
  });
}
