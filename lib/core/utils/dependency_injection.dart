import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/datasources/api_datasource.dart';
import '../database/app_database.dart';

final GetIt getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // External dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => Connectivity());
  getIt.registerLazySingleton(() => AppDatabase());
  
  // Data sources
  getIt.registerLazySingleton<ApiDataSource>(
    () => ApiDataSourceImpl(
      baseUrl: 'http://10.0.2.2:3000/api/v1', // Android emulator
      // baseUrl: 'http://localhost:3000/api/v1', // iOS simulator
    ),
  );
  
  // Repositories will be registered here
  
  // Use cases will be registered here
  
  // BLoCs will be registered here
}