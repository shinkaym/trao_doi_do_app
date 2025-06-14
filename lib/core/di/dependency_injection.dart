import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trao_doi_do_app/core/constants/api_constants.dart';
import 'package:trao_doi_do_app/core/constants/storage_keys.dart';
import 'package:trao_doi_do_app/core/network/api_interceptor.dart';
import 'package:trao_doi_do_app/core/network/dio_client.dart';
import 'package:trao_doi_do_app/core/services/token_refresh_service.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

// ========== AUTH IMPORTS ==========
import 'package:trao_doi_do_app/data/datasources/local/auth_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/auth_remote_datasource.dart';
import 'package:trao_doi_do_app/data/repositories_impl/auth_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/auth_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/get_current_user_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_me_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/is_logged_in_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/login_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/logout_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/refresh_token_usecase.dart';
import 'package:trao_doi_do_app/presentation/providers/auth_provider.dart';

// ========== OTHER IMPORTS ==========
import 'package:trao_doi_do_app/data/datasources/local/category_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/local/onboarding_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/category_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/item_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/interest_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/post_remote_datasource.dart';
import 'package:trao_doi_do_app/data/repositories_impl/category_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/item_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/onboarding_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/transaction_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/interest_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/post_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/category_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/item_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/onboarding_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/interest_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/create_transaction_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_categories_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_items_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_transactions_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/onboarding_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_transaction_status_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_transaction_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/create_interest_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/cancel_interest_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_interests_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/create_post_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_posts_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_post_detail_usecase.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/transaction_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/transactions_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/interests_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/post_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/posts_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/post_detail_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/category_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/item_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/interest_provider.dart';

// =============================================================================
// CORE DEPENDENCIES - Singleton pattern
// =============================================================================

/// Logger provider - Single source of truth
final loggerProvider = Provider<ILogger>((ref) => LoggerUtils());

/// Hive provider
final hiveProvider = Provider<HiveInterface>((ref) => Hive);

/// Settings box provider with caching
final settingsBoxProvider = Provider<Box>((ref) {
  final hive = ref.watch(hiveProvider);
  return hive.box(StorageKeys.settings);
});

/// Secure storage provider for sensitive data (tokens, credentials)
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(),
  );
});

// =============================================================================
// NETWORK PROVIDERS
// =============================================================================

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio();
  dio.options.baseUrl = ApiConstants.baseUrl;
  dio.options.connectTimeout = Duration(
    milliseconds: ApiConstants.connectTimeout,
  );
  dio.options.receiveTimeout = Duration(
    milliseconds: ApiConstants.receiveTimeout,
  );
  dio.options.headers = {
    ApiConstants.contentType: ApiConstants.applicationJson,
  };
  dio.interceptors.add(ApiInterceptor(ref));
  return dio;
});

final dioClientProvider = Provider<DioClient>((ref) {
  final dio = ref.watch(dioProvider);
  return DioClient(dio);
});

// =============================================================================
// AUTH DATA LAYER PROVIDERS
// =============================================================================

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthLocalDataSourceImpl(secureStorage);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient);
});

// =============================================================================
// AUTH DOMAIN LAYER PROVIDERS
// =============================================================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource, localDataSource);
});

// =============================================================================
// AUTH USE CASES PROVIDERS
// =============================================================================

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LoginUseCase(repository);
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUserUseCase(repository);
});

final isLoggedInUseCaseProvider = Provider<IsLoggedInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return IsLoggedInUseCase(repository);
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RefreshTokenUseCase(repository);
});

final getMeUseCaseProvider = Provider<GetMeUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetMeUseCase(repository);
});

// =============================================================================
// AUTH PRESENTATION LAYER PROVIDER
// =============================================================================

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  final isLoggedInUseCase = ref.watch(isLoggedInUseCaseProvider);
  final refreshTokenUseCase = ref.watch(refreshTokenUseCaseProvider);
  final getMeUseCase = ref.watch(getMeUseCaseProvider);

  return AuthNotifier(
    loginUseCase,
    logoutUseCase,
    getCurrentUserUseCase,
    isLoggedInUseCase,
    refreshTokenUseCase,
    getMeUseCase,
  );
});

// =============================================================================
// OTHER DATA LAYER PROVIDERS
// =============================================================================

// Onboarding Data Sources
final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>((
  ref,
) {
  final box = ref.watch(settingsBoxProvider);
  return OnboardingLocalDataSourceImpl(box);
});

// Item Data Sources
final itemRemoteDataSourceProvider = Provider<ItemRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ItemRemoteDataSourceImpl(dioClient);
});

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((
  ref,
) {
  return CategoryLocalDataSourceImpl();
});

final categoryRemoteDataSourceProvider = Provider<CategoryRemoteDataSource>((
  ref,
) {
  final dioClient = ref.watch(dioClientProvider);
  return CategoryRemoteDataSourceImpl(dioClient);
});

final transactionRemoteDataSourceProvider =
    Provider<TransactionRemoteDataSource>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return TransactionRemoteDataSourceImpl(dioClient);
    });

// Interest Data Sources
final interestRemoteDataSourceProvider = Provider<InterestRemoteDataSource>((
  ref,
) {
  final dioClient = ref.watch(dioClientProvider);
  return InterestRemoteDataSourceImpl(dioClient);
});

// Post Data Sources
final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return PostRemoteDataSourceImpl(dioClient);
});

// =============================================================================
// OTHER DOMAIN LAYER PROVIDERS
// =============================================================================

// Repository Providers
final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final dataSource = ref.watch(onboardingLocalDataSourceProvider);
  return OnboardingRepositoryImpl(dataSource);
});

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final remoteDataSource = ref.watch(itemRemoteDataSourceProvider);
  return ItemRepositoryImpl(remoteDataSource);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  final localDataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource, localDataSource);
});

final transactionRepositoryProvider = Provider<TransactionRepositoryImpl>((
  ref,
) {
  final remoteDataSource = ref.watch(transactionRemoteDataSourceProvider);
  return TransactionRepositoryImpl(remoteDataSource);
});

final interestRepositoryProvider = Provider<InterestRepository>((ref) {
  final remoteDataSource = ref.watch(interestRemoteDataSourceProvider);
  return InterestRepositoryImpl(remoteDataSource);
});

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final remoteDataSource = ref.watch(postRemoteDataSourceProvider);
  return PostRepositoryImpl(remoteDataSource);
});

// UseCase Providers
final onboardingUseCaseProvider = Provider<OnboardingUseCase>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return OnboardingUseCase(repository);
});

final getItemsUseCaseProvider = Provider<GetItemsUseCase>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return GetItemsUseCase(repository);
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return GetTransactionsUseCase(repository);
});

final createTransactionUseCaseProvider = Provider<CreateTransactionUseCase>((
  ref,
) {
  final repository = ref.watch(transactionRepositoryProvider);
  return CreateTransactionUseCase(repository);
});

final updateTransactionUseCaseProvider = Provider<UpdateTransactionUseCase>((
  ref,
) {
  final repository = ref.watch(transactionRepositoryProvider);
  return UpdateTransactionUseCase(repository);
});

final updateTransactionStatusUseCaseProvider =
    Provider<UpdateTransactionStatusUseCase>((ref) {
      final repository = ref.watch(transactionRepositoryProvider);
      return UpdateTransactionStatusUseCase(repository);
    });

// Interest UseCase Providers
final createInterestUseCaseProvider = Provider<CreateInterestUseCase>((ref) {
  final repository = ref.watch(interestRepositoryProvider);
  return CreateInterestUseCase(repository);
});

final cancelInterestUseCaseProvider = Provider<CancelInterestUseCase>((ref) {
  final repository = ref.watch(interestRepositoryProvider);
  return CancelInterestUseCase(repository);
});

final getInterestsUseCaseProvider = Provider<GetInterestsUseCase>((ref) {
  final repository = ref.watch(interestRepositoryProvider);
  return GetInterestsUseCase(repository);
});

// Post UseCase Providers
final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return CreatePostUseCase(repository);
});

final getPostsUseCaseProvider = Provider<GetPostsUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return GetPostsUseCase(repository);
});

final getPostDetailUseCaseProvider = Provider<GetPostDetailUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return GetPostDetailUseCase(repository);
});

// =============================================================================
// OTHER PRESENTATION LAYER PROVIDERS
// =============================================================================

final itemsListProvider =
    StateNotifierProvider<ItemsListNotifier, ItemsListState>((ref) {
      final getItemsUseCase = ref.watch(getItemsUseCaseProvider);
      return ItemsListNotifier(getItemsUseCase);
    });

final categoryProvider = StateNotifierProvider<CategoryNotifier, CategoryState>(
  (ref) {
    final getCategoriesUseCase = ref.watch(getCategoriesUseCaseProvider);
    return CategoryNotifier(getCategoriesUseCase);
  },
);

final transactionProvider = StateNotifierProvider<
  TransactionNotifier,
  TransactionState
>((ref) {
  final createTransactionUseCase = ref.watch(createTransactionUseCaseProvider);
  final updateTransactionUseCase = ref.watch(updateTransactionUseCaseProvider);
  return TransactionNotifier(
    createTransactionUseCase,
    updateTransactionUseCase,
  );
});

final transactionsListProvider =
    StateNotifierProvider<TransactionsListNotifier, TransactionsListState>((
      ref,
    ) {
      final getTransactionsUseCase = ref.watch(getTransactionsUseCaseProvider);
      return TransactionsListNotifier(getTransactionsUseCase);
    });

// Interest Presentation Providers
final interestProvider = StateNotifierProvider<InterestNotifier, InterestState>(
  (ref) {
    final createInterestUseCase = ref.watch(createInterestUseCaseProvider);
    final cancelInterestUseCase = ref.watch(cancelInterestUseCaseProvider);
    return InterestNotifier(createInterestUseCase, cancelInterestUseCase);
  },
);

// Tạo hai provider riêng biệt cho hai tab
final interestedPostsProvider =
    StateNotifierProvider<InterestsListNotifier, InterestsListState>((ref) {
      final getInterestsUseCase = ref.watch(getInterestsUseCaseProvider);
      return InterestsListNotifier(getInterestsUseCase);
    });

final postsWithInterestsProvider =
    StateNotifierProvider<InterestsListNotifier, InterestsListState>((ref) {
      final getInterestsUseCase = ref.watch(getInterestsUseCaseProvider);
      return InterestsListNotifier(getInterestsUseCase);
    });

// Post Presentation Providers
final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  final createPostUseCase = ref.watch(createPostUseCaseProvider);
  return PostNotifier(createPostUseCase, ref);
});

final postsListProvider =
    StateNotifierProvider<PostsListNotifier, PostsListState>((ref) {
      final getPostsUseCase = ref.watch(getPostsUseCaseProvider);
      return PostsListNotifier(getPostsUseCase);
    });

final postDetailProvider =
    StateNotifierProvider<PostDetailNotifier, PostDetailState>((ref) {
      final getPostDetailUseCase = ref.watch(getPostDetailUseCaseProvider);
      return PostDetailNotifier(getPostDetailUseCase);
    });

// =============================================================================
// TOKEN REFRESH SERVICE
// =============================================================================

final tokenRefreshServiceProvider = Provider<TokenRefreshService>((ref) {
  return TokenRefreshService();
});

// =============================================================================
// CLEANUP
// =============================================================================

/// Dispose function
void disposeDependencies(ProviderContainer container) {
  container.dispose();
}
