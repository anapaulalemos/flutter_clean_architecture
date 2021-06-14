import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List<Object> properties;

  Failure(this.properties);

  @override
  List<Object> get props => properties;
}

//General failures
class ServerFailure extends Failure {
  ServerFailure(List<Object> properties) : super(properties);
}

class CacheFailure extends Failure {
  CacheFailure(List<Object> properties) : super(properties);
}
