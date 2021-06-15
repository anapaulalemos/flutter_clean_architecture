part of 'number_trivia_bloc.dart';

abstract class NumberTriviaEvent extends Equatable {
  final List<Object> properties;
  const NumberTriviaEvent(this.properties);

  @override
  List<Object> get props => properties;
}

class GetTriviaForConcreteNumber extends NumberTriviaEvent {
  final String numberString;

  GetTriviaForConcreteNumber(this.numberString) : super([numberString]);
}

class GetTriviaForRandomNumber extends NumberTriviaEvent {
  GetTriviaForRandomNumber() : super([]);
}
