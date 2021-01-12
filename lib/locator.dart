import 'package:canli_sohbet_app/repository/user_repository.dart';
import 'package:canli_sohbet_app/services/fake_auth_service.dart';
import 'package:canli_sohbet_app/services/firebase_auth_service.dart';
import 'package:canli_sohbet_app/services/firebase_storage_service.dart';
import 'package:canli_sohbet_app/services/firestore_db_service.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => FirebaseAuthService());
  locator.registerLazySingleton(() => FakeAuthServices());
  locator.registerLazySingleton(() => UserRepository());
  locator.registerLazySingleton(() => FirestoreDbService());
  locator.registerLazySingleton(() => FirebaseStorageService());

}