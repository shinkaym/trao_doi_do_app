import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/data/repositories_impl/appointment_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/category_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/item_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/item_warehouse_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/notification_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/onboarding_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/ranking_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/settings_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/transaction_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/interest_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/post_repository_impl.dart';
import 'package:trao_doi_do_app/data/repositories_impl/message_repository_impl.dart';
import 'package:trao_doi_do_app/domain/repositories/appointment_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/category_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/item_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/item_warehouse_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/notification_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/onboarding_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/interest_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/post_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/message_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/ranking_repository.dart';
import 'package:trao_doi_do_app/domain/repositories/settings_repository.dart';
import 'package:trao_doi_do_app/domain/usecases/create_claim_request_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/create_transaction_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/delete_all_claim_requests_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/delete_claim_request_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/delete_post_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_appointment_detail_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_appointments_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_categories_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_claim_requests_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_interest_detail_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_items_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_my_good_deeds_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_notifications_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_old_stock_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_post_by_id_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_setting_by_key_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_settings_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_transaction_by_interest_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_transactions_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_unread_count_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/get_user_ranks_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/mark_all_messages_read_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/mark_all_notifications_read_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/mark_notification_read_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/onboarding_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_claim_request_usecase.dart';
import 'package:trao_doi_do_app/domain/usecases/update_post_usecase.dart';
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

final itemWarehouseRepositoryProvider =
    Provider.autoDispose<ItemWarehouseRepository>((ref) {
      final remoteDataSource = ref.watch(itemWarehouseRemoteDataSourceProvider);
      return ItemWarehouseRepositoryImpl(remoteDataSource);
    });

final appointmentRepositoryProvider =
    Provider.autoDispose<AppointmentRepository>((ref) {
      final remoteDataSource = ref.watch(appointmentRemoteDataSourceProvider);
      return AppointmentRepositoryImpl(remoteDataSource);
    });

final rankingRepositoryProvider = Provider.autoDispose<RankingRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(rankingRemoteDataSourceProvider);
  return RankingRepositoryImpl(remoteDataSource);
});

final settingsRepositoryProvider = Provider.autoDispose<SettingsRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(settingsRemoteDataSourceProvider);
  return SettingsRepositoryImpl(remoteDataSource);
});

final notificationRepositoryProvider =
    Provider.autoDispose<NotificationRepository>((ref) {
      final remoteDataSource = ref.watch(notificationRemoteDataSourceProvider);
      return NotificationRepositoryImpl(remoteDataSource);
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

final getTransactionByInterestUseCaseProvider =
    Provider.autoDispose<GetTransactionByInterestUseCase>((ref) {
      final repository = ref.watch(transactionRepositoryProvider);
      return GetTransactionByInterestUseCase(repository);
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

final updatePostUseCaseProvider = Provider.autoDispose<UpdatePostUseCase>((
  ref,
) {
  final repository = ref.watch(postRepositoryProvider);
  return UpdatePostUseCase(repository);
});

final deletePostUseCaseProvider = Provider.autoDispose<DeletePostUseCase>((
  ref,
) {
  final repository = ref.watch(postRepositoryProvider);
  return DeletePostUseCase(repository);
});

final getInterestDetailUseCaseProvider =
    Provider.autoDispose<GetInterestDetailUseCase>((ref) {
      final repository = ref.watch(interestRepositoryProvider);
      return GetInterestDetailUseCase(repository);
    });

final getUnreadCountUseCaseProvider =
    Provider.autoDispose<GetUnreadCountUseCase>((ref) {
      final repository = ref.watch(interestRepositoryProvider);
      return GetUnreadCountUseCase(repository);
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

final getPostByIDUseCaseProvider = Provider.autoDispose<GetPostByIDUseCase>((
  ref,
) {
  final repository = ref.watch(postRepositoryProvider);
  return GetPostByIDUseCase(repository);
});

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

final createClaimRequestUseCaseProvider =
    Provider.autoDispose<CreateClaimRequestUseCase>((ref) {
      final repository = ref.watch(itemWarehouseRepositoryProvider);
      return CreateClaimRequestUseCase(repository);
    });

final updateClaimRequestUseCaseProvider =
    Provider.autoDispose<UpdateClaimRequestUseCase>((ref) {
      final repository = ref.watch(itemWarehouseRepositoryProvider);
      return UpdateClaimRequestUseCase(repository);
    });

final getOldStockUseCaseProvider = Provider.autoDispose<GetOldStockUseCase>((
  ref,
) {
  final repository = ref.watch(itemWarehouseRepositoryProvider);
  return GetOldStockUseCase(repository);
});

final getClaimRequestsUseCaseProvider =
    Provider.autoDispose<GetClaimRequestsUseCase>((ref) {
      final repository = ref.watch(itemWarehouseRepositoryProvider);
      return GetClaimRequestsUseCase(repository);
    });

final deleteClaimRequestUseCaseProvider =
    Provider.autoDispose<DeleteClaimRequestUseCase>((ref) {
      final repository = ref.watch(itemWarehouseRepositoryProvider);
      return DeleteClaimRequestUseCase(repository);
    });

final deleteAllClaimRequestsUseCaseProvider =
    Provider.autoDispose<DeleteAllClaimRequestsUseCase>((ref) {
      final repository = ref.watch(itemWarehouseRepositoryProvider);
      return DeleteAllClaimRequestsUseCase(repository);
    });

final getAppointmentsUseCaseProvider =
    Provider.autoDispose<GetAppointmentsUseCase>((ref) {
      final repository = ref.watch(appointmentRepositoryProvider);
      return GetAppointmentsUseCase(repository);
    });

final getAppointmentDetailUseCaseProvider =
    Provider.autoDispose<GetAppointmentDetailUseCase>((ref) {
      final repository = ref.watch(appointmentRepositoryProvider);
      return GetAppointmentDetailUseCase(repository);
    });

final getUserRanksUseCaseProvider = Provider.autoDispose<GetUserRanksUseCase>((
  ref,
) {
  final repository = ref.watch(rankingRepositoryProvider);
  return GetUserRanksUseCase(repository);
});

final getMyGoodDeedsUseCaseProvider =
    Provider.autoDispose<GetMyGoodDeedsUseCase>((ref) {
      final repository = ref.watch(rankingRepositoryProvider);
      return GetMyGoodDeedsUseCase(repository);
    });

final getSettingsUseCaseProvider = Provider.autoDispose<GetSettingsUseCase>((
  ref,
) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettingsUseCase(repository);
});

final getSettingByKeyUseCaseProvider =
    Provider.autoDispose<GetSettingByKeyUseCase>((ref) {
      final repository = ref.watch(settingsRepositoryProvider);
      return GetSettingByKeyUseCase(repository);
    });

final getNotificationsUseCaseProvider =
    Provider.autoDispose<GetNotificationsUseCase>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return GetNotificationsUseCase(repository);
    });

final markNotificationReadUseCaseProvider =
    Provider.autoDispose<MarkNotificationReadUseCase>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return MarkNotificationReadUseCase(repository);
    });

final markAllNotificationsReadUseCaseProvider =
    Provider.autoDispose<MarkAllNotificationsReadUseCase>((ref) {
      final repository = ref.watch(notificationRepositoryProvider);
      return MarkAllNotificationsReadUseCase(repository);
    });
