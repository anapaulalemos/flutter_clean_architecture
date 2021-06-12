import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List<Object> properties;

  Failure(this.properties);

  @override
  List<Object> get props => properties;
}
