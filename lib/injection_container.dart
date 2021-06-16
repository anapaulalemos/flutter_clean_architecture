import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

//service locator
final sl = GetIt.instance;

void init() {
  // External
  sl.registerSingletonAsync<SharedPreferences>(
      () async => SharedPreferences.getInstance());
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => InternetConnectionChecker());

  // Features - Number Trivia

  // Bloc
  // streams and stuff need to ne registered as factories and not singletons
  sl.registerFactory(() => NumberTriviaBloc(
        getConcreteNumberTrivia: sl(), //same as sl.call()
        getRandomNumberTrivia: sl(),
        inputConverter: sl(),
      ));

  // Use cases
  // this usecases do not hold any state or stream
  // so they can be singletons.
  // Singletons are imediatelly registered after the app start,
  // LazySinglaton are registered when they are requested for the first time
  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(sl()));

  // Repository
  sl.registerLazySingleton<NumberTriviaRepository>(() => NumberTriviaRepositoryImpl(
        remoteDatasource: sl(),
        localDatasource: sl(),
        networkInfo: sl(),
      ));

  //Dasource
  sl.registerLazySingleton<NumberTriviaRemoteDatasource>(
      () => NumberTriviaRemoteDatasourceImpl(client: sl()));
  sl.registerSingletonWithDependencies<NumberTriviaLocalDatasource>(
      () => NumberTriviaLocalDatasourceImpl(preferences: sl()),
      dependsOn: [SharedPreferences]);

  // Core
  sl.registerLazySingleton(() => InputConverter());
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}
