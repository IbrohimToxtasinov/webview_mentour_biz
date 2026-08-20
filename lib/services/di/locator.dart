import 'package:get_it/get_it.dart';
import 'package:mentour_web_view/data/repositories/attendance_repository.dart';
import 'package:mentour_web_view/data/repositories/auth_repository.dart';
import 'package:mentour_web_view/data/repositories/coin_market_products_repository.dart';
import 'package:mentour_web_view/data/repositories/course_repository.dart';
import 'package:mentour_web_view/data/repositories/file_repository.dart';
import 'package:mentour_web_view/data/repositories/group_repository.dart';
import 'package:mentour_web_view/data/repositories/home_works_repository.dart';
import 'package:mentour_web_view/data/repositories/library_repository.dart';
import 'package:mentour_web_view/data/repositories/profile_repository.dart';
import 'package:mentour_web_view/data/repositories/questions_repository.dart';
import 'package:mentour_web_view/data/repositories/ranking_repository.dart';
import 'package:mentour_web_view/data/repositories/vocabulary_repository.dart';
import 'package:mentour_web_view/services/network/open_api/open_api_services.dart';
import 'package:mentour_web_view/services/network/secure_api/secure_api_services.dart';
import 'package:mentour_web_view/data/repositories/notifications_repository.dart';

final sl = GetIt.instance;

Future<void> slInit() async {
  _apiServiceModule();
  _repositoryModule();
}

void _apiServiceModule() {
  sl.registerLazySingleton(() => OpenApiService());
  sl.registerLazySingleton(() => SecureApiService());
}

void _repositoryModule() {
  sl.registerLazySingleton(() => AuthRepository());
  sl.registerLazySingleton(() => ProfileRepository());
  sl.registerLazySingleton(() => CourseRepository());
  sl.registerLazySingleton(() => HomeworksRepository());
  sl.registerLazySingleton(() => QuestionsRepository());
  sl.registerLazySingleton(() => VocabularyRepository());
  sl.registerLazySingleton(() => RankingRepository());
  sl.registerLazySingleton(() => CoinMarketProductsRepository());
  sl.registerLazySingleton(() => FileRepository());
  sl.registerLazySingleton(() => AttendanceRepository());
  sl.registerLazySingleton(() => LibraryRepository());
  sl.registerLazySingleton(() => NotificationsRepository());
  sl.registerLazySingleton(() => GroupRepository());
}
