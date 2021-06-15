import 'dart:convert';
import 'package:clean_architecture_tdd_course/core/errors/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:http/http.dart' as http;
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

class UriFake extends Fake implements Uri {}

void main() {
  late NumberTriviaRemoteDatasourceImpl datasource;
  late MockHttpClient mockHttpClient;

  final tNumberTriviaModel =
      NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

  setUp(() async {
    registerFallbackValue(UriFake());
    mockHttpClient = MockHttpClient();
    datasource = NumberTriviaRemoteDatasourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientError() {
    when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;

    test('''should perform a get request on a URL with number being the endpoint 
      and with application/json header''', () async {
      //arrange
      setUpMockHttpClientSuccess();
      //act
      datasource.getConcreteNumberTrivia(tNumber);
      //assert
      verify(() => mockHttpClient.get(
            Uri.parse('http://numbersapi.com/$tNumber'),
            headers: {'Content-Type': 'application/json'},
          ));
    });

    test('should return NumberTrivia when the response code is 200 (success)', () async {
      //arrange
      setUpMockHttpClientSuccess();
      //act
      final result = await datasource.getConcreteNumberTrivia(tNumber);
      //assert
      expect(result, equals(tNumberTriviaModel));
    });

    test('should throw a ServerException when the response code is different from 200',
        () async {
      //arrange
      setUpMockHttpClientError();
      //act
      final call = datasource.getConcreteNumberTrivia;
      //assert
      expect(() => call(tNumber), throwsA(TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      'should preform a GET request on a URL with *random* endpoint with application/json header',
      () {
        //arrange
        setUpMockHttpClientSuccess();
        // act
        datasource.getRandomNumberTrivia();
        // assert
        verify(() => mockHttpClient.get(
              Uri.parse('http://numbersapi.com/random'),
              headers: {'Content-Type': 'application/json'},
            ));
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockHttpClientSuccess();
        // act
        final result = await datasource.getRandomNumberTrivia();
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientError();
        // act
        final call = datasource.getRandomNumberTrivia;
        // assert
        expect(() => call(), throwsA(TypeMatcher<ServerException>()));
      },
    );
  });
}
