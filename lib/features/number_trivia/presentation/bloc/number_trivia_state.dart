part of 'number_trivia_bloc.dart';

abstract class NumberTriviaState extends Equatable {
  final List<Object> properties;
  const NumberTriviaState(this.properties);

  @override
  List<Object> get props => properties;
}

class Empty extends NumberTriviaState {
  Empty() : super([]);
}

class Loading extends NumberTriviaState {
  Loading() : super([]);
}

class Loaded extends NumberTriviaState {
  final NumberTrivia trivia;

  Loaded({required this.trivia}) : super([trivia]);
}

class Error extends NumberTriviaState {
  final String message;

  Error({required this.message}) : super([message]);
}
