import 'package:equatable/equatable.dart';

//equatable compares the properties of class
class NumberTrivia extends Equatable {
  final String text;
  final int number;

  NumberTrivia({
    required this.text,
    required this.number,
  });

  @override
  List<Object?> get props => [text, number];
}
