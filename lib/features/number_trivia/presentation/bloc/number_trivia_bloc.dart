import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clean_architecture_tdd_course/core/errors/failures.dart';
import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:equatable/equatable.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MSG = 'Server failure';
const String CACHE_FAILURE_MSG = 'Cache failure';
const String INVALID_INPUT_FAILURE_MSG =
    'Invalid input - the number must be a positive number or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia concrete;
  final GetRandomNumberTrivia random;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.concrete,
    required this.random,
    required this.inputConverter,
  }) : super(Empty());

  @override
  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    if (event is GetTriviaForConcreteNumber) {
      final inputEither = inputConverter.stringToUnsignedInteger(event.numberString);

      yield* inputEither.fold((failure) async* {
        yield Error(message: INVALID_INPUT_FAILURE_MSG);
      }, (integer) async* {
        yield Loading();

        final concreteEither = await concrete(Params(number: integer));

        yield concreteEither.fold(
          (failure) => Error(
            message: _mapErrorMessage(failure),
          ),
          (trivia) => Loaded(trivia: trivia),
        );
      });
    }
  }

  String _mapErrorMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MSG;
      case CacheFailure:
        return CACHE_FAILURE_MSG;
      default:
        return 'Unexpected error';
    }
  }
}
