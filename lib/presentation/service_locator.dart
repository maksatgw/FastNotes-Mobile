import 'package:fastnotes_flutter/data/repositories/auth_repository_impl.dart';
import 'package:fastnotes_flutter/data/services/auth_service.dart';
import 'package:fastnotes_flutter/domain/repositories/auth_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:fastnotes_flutter/data/services/note_service.dart';
import 'package:fastnotes_flutter/data/repositories/note_repository_impl.dart';
import 'package:fastnotes_flutter/domain/repositories/note_repository.dart';

// GetIt örneğimizi oluşturuyoruz
final serviceLocator = GetIt.instance;

// Tüm bağımlılıkları kaydettiğimiz fonksiyon
void setupServiceLocator() {
  // Services
  serviceLocator.registerLazySingleton<NoteService>(() => NoteServiceImpl());
  serviceLocator.registerLazySingleton<AuthService>(() => AuthServiceImpl());

  // Repositories
  serviceLocator.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(
      noteService: serviceLocator<NoteService>(),
    ),
  );
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(authService: serviceLocator<AuthService>()),
  );
}
