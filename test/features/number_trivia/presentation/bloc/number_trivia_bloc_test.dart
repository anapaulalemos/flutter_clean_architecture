import 'package:clean_architecture_tdd_course/core/errors/failures.dart';
import 'package:clean_architecture_tdd_course/core/usecases/usecase.dart';
import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';

class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

class ParamsFake extends Fake implements Params {}

class NoParamsFake extends Fake implements NoParams {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    registerFallbackValue(ParamsFake());
    registerFallbackValue(NoParamsFake());

    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  group('GetConcreteNumberTrivia', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(text: 'test', number: 1);

    void setUpMockInputConverterSuccess() {
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Right(tNumberParsed));
    }

    test('should emit [Error] when the input is invalid', () async {
      //arrange
      when(() => mockInputConverter.stringToUnsignedInteger(any()))
          .thenReturn(Left(InvalidInputFailure()));

      //assert later
      expectLater(
        bloc.stream,
        emitsInOrder([
          Error(message: INVALID_INPUT_FAILURE_MSG),
        ]),
      );

      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));

      //assert - bloc.state is the initial state
      expect(bloc.state, equals(Empty()));
    });

    test('should getData from the concrete use case', () async {
      //arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(() => mockGetConcreteNumberTrivia(any()));
      //assert
      verify(() => mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // assert later
      final expected = [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Left(ServerFailure()));
      // assert later
      final expected = [
        Loading(),
        Error(message: SERVER_FAILURE_MSG),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async {
      // arrange
      setUpMockInputConverterSuccess();
      when(() => mockGetConcreteNumberTrivia(any()))
          .thenAnswer((_) async => Left(CacheFailure()));
      // assert later
      final expected = [
        Loading(),
        Error(message: CACHE_FAILURE_MSG),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });
  });

  group('GetRandomNumberTrivia', () {
    final tNumberTrivia = NumberTrivia(text: 'test', number: 1);

    test('should getData from the random use case', () async {
      //arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(() => mockGetRandomNumberTrivia(any()));
      //assert
      verify(() => mockGetRandomNumberTrivia(NoParams()));
    });

    test('should emit [Loading, Loaded] when data is gotten successfully', () async {
      // arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // assert later
      final expected = [
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForRandomNumber());
    });

    test('should emit [Loading, Error] when getting data fails', () async {
      // arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Left(ServerFailure()));
      // assert later
      final expected = [
        Loading(),
        Error(message: SERVER_FAILURE_MSG),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForRandomNumber());
    });

    test(
        'should emit [Loading, Error] with a proper message for the error when getting data fails',
        () async {
      // arrange
      when(() => mockGetRandomNumberTrivia(any()))
          .thenAnswer((_) async => Left(CacheFailure()));
      // assert later
      final expected = [
        Loading(),
        Error(message: CACHE_FAILURE_MSG),
      ];
      expectLater(bloc.stream, emitsInOrder(expected));
      // act
      bloc.add(GetTriviaForRandomNumber());
    });
  });
}
