import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import 'core/services/step_counter_service.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/chatbot/data/datasources/chat_remote_datasource.dart';
import 'features/chatbot/data/repositories/chat_repository_impl.dart';
import 'features/chatbot/domain/repositories/chat_repository.dart';
import 'features/chatbot/presentation/bloc/chat_bloc.dart';
import 'features/health_dashboard/data/repositories/health_repository_impl.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // --- BLOCS ---
  sl.registerLazySingleton(() => AuthBloc(authRepository: sl()));
  sl.registerLazySingleton(() => SettingsBloc());
  sl.registerFactory(() => ChatBloc(repository: sl()));

  // --- REPOSITORIES ---
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HealthRepository>(() => HealthRepositoryImpl());
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));

  // --- DATA SOURCES ---
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    ),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImpl(),
  );

  // --- SERVICES ---
  sl.registerLazySingleton<StepCounterService>(() => StepCounterServiceImpl());

  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
}
