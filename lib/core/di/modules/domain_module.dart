import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/data/repositories_impl/category_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/item_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/onboarding_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/transaction_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/interest_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/post_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/message_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/category_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/item_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/onboarding_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/interest_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/message_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/create_transaction_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_categories_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_interest_detail_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_items_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_transactions_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/mark_all_messages_read_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/onboarding_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_transaction_status_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_transaction_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/create_interest_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/cancel_interest_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_interests_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/create_post_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_posts_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_post_detail_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_my_posts_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_messages_usecase.dart';
import '../modules/data_module.dart';

/// Domain Module - Contains repositories and use cases
class DomainModule {
  static void initialize() {
    // Module initialization logic if needed
  }
}

// =============================================================================
// REPOSITORY PROVIDERS
// =============================================================================

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  final dataSource = ref.watch(onboardingLocalDataSourceProvider);
  return OnboardingRepositoryImpl(dataSource);
});

final itemRepositoryProvider = Provider.autoDispose<ItemRepository>((ref) {
  final remoteDataSource = ref.watch(itemRemoteDataSourceProvider);
  return ItemRepositoryImpl(remoteDataSource);
});

final categoryRepositoryProvider = Provider.autoDispose<CategoryRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  final localDataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource, localDataSource);
});

final transactionRepositoryProvider =
    Provider.autoDispose<TransactionRepositoryImpl>((ref) {
      final remoteDataSource = ref.watch(transactionRemoteDataSourceProvider);
      return TransactionRepositoryImpl(remoteDataSource);
    });

final interestRepositoryProvider = Provider.autoDispose<InterestRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(interestRemoteDataSourceProvider);
  return InterestRepositoryImpl(remoteDataSource);
});

final postRepositoryProvider = Provider.autoDispose<PostRepository>((ref) {
  final remoteDataSource = ref.watch(postRemoteDataSourceProvider);
  return PostRepositoryImpl(remoteDataSource);
});

final messageRepositoryProvider = Provider.autoDispose<MessageRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(messageRemoteDataSourceProvider);
  return MessageRepositoryImpl(remoteDataSource);
});

// =============================================================================
// USE CASE PROVIDERS
// =============================================================================

final onboardingUseCaseProvider = Provider<OnboardingUseCase>((ref) {
  final repository = ref.watch(onboardingRepositoryProvider);
  return OnboardingUseCase(repository);
});

final getItemsUseCaseProvider = Provider.autoDispose<GetItemsUseCase>((ref) {
  final repository = ref.watch(itemRepositoryProvider);
  return GetItemsUseCase(repository);
});

final getCategoriesUseCaseProvider = Provider.autoDispose<GetCategoriesUseCase>(
  (ref) {
    final repository = ref.watch(categoryRepositoryProvider);
    return GetCategoriesUseCase(repository);
  },
);

final getTransactionsUseCaseProvider =
    Provider.autoDispose<GetTransactionsUseCase>((ref) {
      final repository = ref.watch(transactionRepositoryProvider);
      return GetTransactionsUseCase(repository);
    });

final createTransactionUseCaseProvider =
    Provider.autoDispose<CreateTransactionUseCase>((ref) {
      final repository = ref.watch(transactionRepositoryProvider);
      return CreateTransactionUseCase(repository);
    });

final updateTransactionUseCaseProvider =
    Provider.autoDispose<UpdateTransactionUseCase>((ref) {
      final repository = ref.watch(transactionRepositoryProvider);
      return UpdateTransactionUseCase(repository);
    });

final updateTransactionStatusUseCaseProvider =
    Provider.autoDispose<UpdateTransactionStatusUseCase>((ref) {
      final repository = ref.watch(transactionRepositoryProvider);
      return UpdateTransactionStatusUseCase(repository);
    });

final createInterestUseCaseProvider =
    Provider.autoDispose<CreateInterestUseCase>((ref) {
      final repository = ref.watch(interestRepositoryProvider);
      return CreateInterestUseCase(repository);
    });

final cancelInterestUseCaseProvider =
    Provider.autoDispose<CancelInterestUseCase>((ref) {
      final repository = ref.watch(interestRepositoryProvider);
      return CancelInterestUseCase(repository);
    });

final getInterestsUseCaseProvider = Provider.autoDispose<GetInterestsUseCase>((
  ref,
) {
  final repository = ref.watch(interestRepositoryProvider);
  return GetInterestsUseCase(repository);
});

final createPostUseCaseProvider = Provider.autoDispose<CreatePostUseCase>((
  ref,
) {
  final repository = ref.watch(postRepositoryProvider);
  return CreatePostUseCase(repository);
});

final getInterestDetailUseCaseProvider =
    Provider.autoDispose<GetInterestDetailUseCase>((ref) {
      final repository = ref.watch(interestRepositoryProvider);
      return GetInterestDetailUseCase(repository);
    });

final getPostsUseCaseProvider = Provider.autoDispose<GetPostsUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return GetPostsUseCase(repository);
});

final getMyPostsUseCaseProvider = Provider.autoDispose<GetMyPostsUseCase>((
  ref,
) {
  final repository = ref.watch(postRepositoryProvider);
  return GetMyPostsUseCase(repository);
});

final getPostDetailUseCaseProvider = Provider.autoDispose<GetPostDetailUseCase>(
  (ref) {
    final repository = ref.watch(postRepositoryProvider);
    return GetPostDetailUseCase(repository);
  },
);

final getMessagesUseCaseProvider = Provider.autoDispose<GetMessagesUseCase>((
  ref,
) {
  final repository = ref.watch(messageRepositoryProvider);
  return GetMessagesUseCase(repository);
});

final markAllMessagesReadUseCaseProvider =
    Provider.autoDispose<MarkAllMessagesReadUseCase>((ref) {
      final repository = ref.watch(messageRepositoryProvider);
      return MarkAllMessagesReadUseCase(repository);
    });
