import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/error/failure.dart';
import 'package:trao_doi_do_app/data/datasources/local/fcm_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/fcm_remote_datasource.dart';
import 'package:trao_doi_do_app/data/repositories_impl/fcm_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/fcm_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/delete_fcm_token_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_fcm_token_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/save_fcm_token_usecase.dart';
import 'package:trao_doi_do_app/presentation/notifiers/fcm_notifier.dart';

/// FCM Module - Contains FCM-related dependencies
class FcmModule {
  static void initialize() {
    // Module initialization logic if needed
  }
}

// =============================================================================
// FCM DATA LAYER PROVIDERS
// =============================================================================

final fcmLocalDataSourceProvider = Provider<FcmLocalDataSource>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return FcmLocalDataSourceImpl(secureStorage);
});

final fcmRemoteDataSourceProvider = Provider.autoDispose<FcmRemoteDataSource>((
  ref,
) {
  final dioClient = ref.watch(dioClientProvider);
  return FcmRemoteDataSourceImpl(dioClient);
});

// =============================================================================
// FCM DOMAIN LAYER PROVIDERS
// =============================================================================

final fcmRepositoryProvider = Provider<FcmRepository>((ref) {
  final remoteDataSource = ref.watch(fcmRemoteDataSourceProvider);
  final localDataSource = ref.watch(fcmLocalDataSourceProvider);
  return FcmRepositoryImpl(remoteDataSource, localDataSource);
});

// =============================================================================
// FCM USE CASES PROVIDERS
// =============================================================================

final saveFcmTokenUseCaseProvider = Provider<SaveFcmTokenUseCase>((ref) {
  final repository = ref.watch(fcmRepositoryProvider);
  return SaveFcmTokenUseCase(repository);
});

final deleteFcmTokenUseCaseProvider = Provider<DeleteFcmTokenUseCase>((ref) {
  final repository = ref.watch(fcmRepositoryProvider);
  return DeleteFcmTokenUseCase(repository);
});

final getFcmTokenUseCaseProvider = Provider<GetFcmTokenUseCase>((ref) {
  final repository = ref.watch(fcmRepositoryProvider);
  return GetFcmTokenUseCase(repository);
});

// =============================================================================
// FCM PRESENTATION LAYER PROVIDER
// =============================================================================

final fcmProvider = StateNotifierProvider<FcmNotifier, FcmState>((ref) {
  final saveFcmTokenUseCase = ref.watch(saveFcmTokenUseCaseProvider);
  final deleteFcmTokenUseCase = ref.watch(deleteFcmTokenUseCaseProvider);
  final getFcmTokenUseCase = ref.watch(getFcmTokenUseCaseProvider);

  return FcmNotifier(
    saveFcmTokenUseCase,
    deleteFcmTokenUseCase,
    getFcmTokenUseCase,
  );
});

// =============================================================================
// FCM STATUS PROVIDERS
// =============================================================================

final fcmTokenProvider = Provider<String?>((ref) {
  return ref.watch(fcmProvider.select((state) => state.fcmToken));
});

final isFcmTokenRegisteredProvider = Provider<bool>((ref) {
  return ref.watch(fcmProvider.select((state) => state.isTokenRegistered));
});

final fcmLoadingProvider = Provider<bool>((ref) {
  return ref.watch(fcmProvider.select((state) => state.isLoading));
});

final fcmErrorProvider = Provider<Failure?>((ref) {
  return ref.watch(fcmProvider.select((state) => state.failure));
});
