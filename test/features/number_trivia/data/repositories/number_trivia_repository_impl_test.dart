import 'package:clean_architecture_tdd_course/core/errors/exceptions.dart';
import 'package:clean_architecture_tdd_course/core/errors/failures.dart';
import 'package:clean_architecture_tdd_course/core/usecases/network_info.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNumberTriviaRemoteDatasource extends Mock
    implements NumberTriviaRemoteDatasource {}

class MockNumberTriviaLocalDatasource extends Mock
    implements NumberTriviaLocalDatasource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockNumberTriviaRemoteDatasource mockRemoteDatasource;
  late MockNumberTriviaLocalDatasource mockLocalDatasource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDatasource = MockNumberTriviaRemoteDatasource();
    mockLocalDatasource = MockNumberTriviaLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();

    repository = NumberTriviaRepositoryImpl(
      remoteDatasource: mockRemoteDatasource,
      localDatasource: mockLocalDatasource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text: 'teste trivia',
    );
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;
    test(
      'should check if the device is online',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDatasource.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        await repository.getConcreteNumberTrivia(tNumber);
        // assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test('should return remote data when the call to remote datasource is succesfull',
          () async {
        //arrange
        when(() => mockRemoteDatasource.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(() => mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'should cash the data locally when the call to remote datasource is succesfull',
          () async {
        //arrange
        when(() => mockRemoteDatasource.getConcreteNumberTrivia(any()))
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(() => mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel)).called(1);
      });

      test(
          'should return server failure when the call to remote datasource is insuccesfull',
          () async {
        //arrange
        when(() => mockRemoteDatasource.getConcreteNumberTrivia(any()))
            .thenThrow(ServerException());
        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(() => mockRemoteDatasource.getConcreteNumberTrivia(tNumber));
        verifyZeroInteractions(mockLocalDatasource);
        expect(result, equals(Left(ServerFailure([]))));
      });
    });

    runTestsOffline(() {
      test('should return last locally cached data when the cache data is present',
          () async {
        //arrange
        when(() => mockLocalDatasource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verifyZeroInteractions(mockRemoteDatasource);
        verify(() => mockLocalDatasource.getLastNumberTrivia()).called(1);
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return cache failure when the call to cache data is insuccesfull',
          () async {
        //arrange
        when(() => mockLocalDatasource.getLastNumberTrivia()).thenThrow(CacheException());

        //act
        final result = await repository.getConcreteNumberTrivia(tNumber);
        //assert
        verify(() => mockLocalDatasource.getLastNumberTrivia());
        verifyZeroInteractions(mockRemoteDatasource);
        expect(result, equals(Left(CacheFailure([]))));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel = NumberTriviaModel(
      number: 123,
      text: 'teste trivia',
    );
    final NumberTrivia tNumberTrivia = tNumberTriviaModel;

    test(
      'should check if the device is online',
      () async {
        // arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockRemoteDatasource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        // act
        await repository.getRandomNumberTrivia();
        // assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test('should return remote data when the call to remote datasource is succesfull',
          () async {
        //arrange
        when(() => mockRemoteDatasource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verify(() => mockRemoteDatasource.getRandomNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test(
          'should cash the data locally when the call to remote datasource is succesfull',
          () async {
        //arrange
        when(() => mockRemoteDatasource.getRandomNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);
        //act
        await repository.getRandomNumberTrivia();
        //assert
        verify(() => mockLocalDatasource.cacheNumberTrivia(tNumberTriviaModel)).called(1);
      });

      test(
          'should return server failure when the call to remote datasource is insuccesfull',
          () async {
        //arrange
        when(() => mockRemoteDatasource.getRandomNumberTrivia())
            .thenThrow(ServerException());
        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verify(() => mockRemoteDatasource.getRandomNumberTrivia());
        verifyZeroInteractions(mockLocalDatasource);
        expect(result, equals(Left(ServerFailure([]))));
      });
    });

    runTestsOffline(() {
      test('should return last locally cached data when the cache data is present',
          () async {
        //arrange
        when(() => mockLocalDatasource.getLastNumberTrivia())
            .thenAnswer((_) async => tNumberTriviaModel);

        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verifyZeroInteractions(mockRemoteDatasource);
        verify(() => mockLocalDatasource.getLastNumberTrivia()).called(1);
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return cache failure when the call to cache data is insuccesfull',
          () async {
        //arrange
        when(() => mockLocalDatasource.getLastNumberTrivia()).thenThrow(CacheException());

        //act
        final result = await repository.getRandomNumberTrivia();
        //assert
        verify(() => mockLocalDatasource.getLastNumberTrivia());
        verifyZeroInteractions(mockRemoteDatasource);
        expect(result, equals(Left(CacheFailure([]))));
      });
    });
  });
}
