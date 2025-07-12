import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/config/theme_mode_notifier.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/notifiers/appointment_detail_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/notifiers/appointment_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/notifiers/appointments_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/interests/notifiers/interest_detail_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/interests/notifiers/transaction_by_interest_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/interests/notifiers/transaction_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/interests/notifiers/transactions_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/interests/notifiers/interests_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/post/notifiers/post_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/post/notifiers/posts_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/post/notifiers/post_detail_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/profile/notifiers/my_posts_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/notifiers/my_good_deeds_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/ranking/notifiers/ranking_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/splash/notifiers/splash_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/onboarding/notifiers/onboarding_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/notifiers/claim_request_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/notifiers/claim_requests_list_notifier.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/notifiers/old_stock_notifier.dart';
import 'package:trao_doi_do_app/presentation/notifiers/category_notifier.dart';
import 'package:trao_doi_do_app/presentation/notifiers/item_notifier.dart';
import 'package:trao_doi_do_app/presentation/notifiers/interest_notifier.dart';
import 'package:trao_doi_do_app/presentation/notifiers/messages_notifier.dart';
import 'package:trao_doi_do_app/presentation/notifiers/notification_notifier.dart';
import 'package:trao_doi_do_app/presentation/notifiers/search_suggestion_notifier.dart';
import 'package:trao_doi_do_app/presentation/notifiers/settings_notifier.dart';
import 'package:trao_doi_do_app/presentation/notifiers/unread_count_notifier.dart';

/// Presentation Module - Contains UI state providers
class PresentationModule {
  static void initialize() {
    // Module initialization logic if needed
  }
}

// =============================================================================
// SPLASH & ONBOARDING PROVIDERS
// =============================================================================

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

final splashProvider = StateNotifierProvider<SplashNotifier, SplashState>((
  ref,
) {
  final logger = ref.watch(loggerProvider);
  return SplashNotifier(logger);
});

final isSplashCompletedProvider = Provider<bool>((ref) {
  return ref.watch(splashProvider.select((state) => state.isCompleted));
});

final isSplashLoadingProvider = Provider<bool>((ref) {
  return ref.watch(splashProvider.select((state) => state.isLoading));
});

final splashErrorProvider = Provider<String?>((ref) {
  return ref.watch(splashProvider.select((state) => state.error));
});

final splashProgressProvider = Provider<double>((ref) {
  return ref.watch(splashProvider.select((state) => state.progress));
});

final isSplashReadyProvider = Provider<bool>((ref) {
  final state = ref.watch(splashProvider);
  return state.progress >= 1.0 && state.isCompleted;
});

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      final useCase = ref.watch(onboardingUseCaseProvider);
      final logger = ref.watch(loggerProvider);
      return OnboardingNotifier(useCase, logger);
    });

final isOnboardingCompletedProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider.select((state) => state.isCompleted));
});

final isOnboardingLoadingProvider = Provider<bool>((ref) {
  return ref.watch(onboardingProvider.select((state) => state.isLoading));
});

final onboardingErrorProvider = Provider<String?>((ref) {
  return ref.watch(onboardingProvider.select((state) => state.error));
});

final completeOnboardingProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await ref.read(onboardingProvider.notifier).completeOnboarding();
  };
});

// =============================================================================
// OTHER PRESENTATION PROVIDERS
// =============================================================================

final itemsListProvider =
    StateNotifierProvider.autoDispose<ItemsListNotifier, ItemsListState>((ref) {
      final getItemsUseCase = ref.watch(getItemsUseCaseProvider);
      return ItemsListNotifier(getItemsUseCase);
    });

final categoryProvider =
    StateNotifierProvider.autoDispose<CategoryNotifier, CategoryState>((ref) {
      final getCategoriesUseCase = ref.watch(getCategoriesUseCaseProvider);
      return CategoryNotifier(getCategoriesUseCase);
    });

final transactionProvider = StateNotifierProvider.autoDispose<
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

final transactionsListProvider = StateNotifierProvider.autoDispose<
  TransactionsListNotifier,
  TransactionsListState
>((ref) {
  final getTransactionsUseCase = ref.watch(getTransactionsUseCaseProvider);
  return TransactionsListNotifier(getTransactionsUseCase);
});

final interestProvider =
    StateNotifierProvider.autoDispose<InterestNotifier, InterestState>((ref) {
      final createInterestUseCase = ref.watch(createInterestUseCaseProvider);
      final cancelInterestUseCase = ref.watch(cancelInterestUseCaseProvider);
      return InterestNotifier(createInterestUseCase, cancelInterestUseCase);
    });

final interestedPostsProvider =
    StateNotifierProvider<InterestsListNotifier, InterestsListState>((ref) {
      final getInterestsUseCase = ref.watch(getInterestsUseCaseProvider);
      return InterestsListNotifier(getInterestsUseCase);
    });

final transactionByInterestProvider = StateNotifierProvider.family<
  TransactionByInterestNotifier,
  TransactionByInterestState,
  int
>((ref, interestId) {
  final getTransactionByInterestUseCase = ref.watch(
    getTransactionByInterestUseCaseProvider,
  );
  return TransactionByInterestNotifier(
    getTransactionByInterestUseCase,
    interestId,
  );
});

final postsWithInterestsProvider =
    StateNotifierProvider<InterestsListNotifier, InterestsListState>((ref) {
      final getInterestsUseCase = ref.watch(getInterestsUseCaseProvider);
      return InterestsListNotifier(getInterestsUseCase);
    });

final interestDetailProvider = StateNotifierProvider.autoDispose.family<
  InterestDetailNotifier,
  InterestDetailState,
  int
>((ref, interestID) {
  final getInterestDetailUseCase = ref.watch(getInterestDetailUseCaseProvider);
  final notifier = InterestDetailNotifier(getInterestDetailUseCase);

  // Auto load khi provider được tạo
  Future.microtask(() => notifier.loadInterestDetail(interestID));

  return notifier;
});

final unreadCountProvider =
    StateNotifierProvider<UnreadCountNotifier, UnreadCountState>((ref) {
      final getUnreadCountUseCase = ref.watch(getUnreadCountUseCaseProvider);
      return UnreadCountNotifier(getUnreadCountUseCase);
    });

final postProvider = StateNotifierProvider<PostNotifier, PostState>((ref) {
  final createPostUseCase = ref.watch(createPostUseCaseProvider);
  final updatePostUseCase = ref.watch(updatePostUseCaseProvider);
  final deletePostUseCase = ref.watch(deletePostUseCaseProvider);
  return PostNotifier(createPostUseCase, updatePostUseCase, deletePostUseCase);
});

final postsListProvider =
    StateNotifierProvider<PostsListNotifier, PostsListState>((ref) {
      final getPostsUseCase = ref.watch(getPostsUseCaseProvider);
      return PostsListNotifier(getPostsUseCase);
    });

final postsProviderFamily =
    StateNotifierProvider.family<PostsListNotifier, PostsListState, PostType>((
      ref,
      postType,
    ) {
      // Inject GetPostsUseCase dependency here
      final getPostsUseCase = ref.watch(getPostsUseCaseProvider);
      return PostsListNotifier(getPostsUseCase);

      // Temporary mock implementation
    });

final myPostsListProvider =
    StateNotifierProvider<MyPostsListNotifier, MyPostsListState>((ref) {
      final getMyPostsUseCase = ref.watch(getMyPostsUseCaseProvider);
      return MyPostsListNotifier(getMyPostsUseCase);
    });

final postDetailProvider =
    StateNotifierProvider.autoDispose<PostDetailNotifier, PostDetailState>((
      ref,
    ) {
      final getPostDetailUseCase = ref.watch(getPostDetailUseCaseProvider);
      final getPostByIDUseCase = ref.watch(getPostByIDUseCaseProvider);
      return PostDetailNotifier(getPostDetailUseCase, getPostByIDUseCase);
    });

final messagesListProvider = StateNotifierProvider.autoDispose
    .family<MessagesListNotifier, MessagesListState, int>((ref, interestID) {
      final getMessagesUseCase = ref.watch(getMessagesUseCaseProvider);
      final markAllMessagesReadUseCase = ref.watch(
        markAllMessagesReadUseCaseProvider,
      );
      return MessagesListNotifier(
        getMessagesUseCase,
        markAllMessagesReadUseCase,
        interestID,
      );
    });

final claimRequestProvider =
    StateNotifierProvider<ClaimRequestNotifier, ClaimRequestState>((ref) {
      final createClaimRequestUseCase = ref.watch(
        createClaimRequestUseCaseProvider,
      );
      final updateClaimRequestUseCase = ref.watch(
        updateClaimRequestUseCaseProvider,
      );
      final deleteClaimRequestUseCase = ref.watch(
        deleteClaimRequestUseCaseProvider,
      );
      final deleteAllClaimRequestsUseCase = ref.watch(
        deleteAllClaimRequestsUseCaseProvider,
      );

      return ClaimRequestNotifier(
        createClaimRequestUseCase,
        updateClaimRequestUseCase,
        deleteClaimRequestUseCase,
        deleteAllClaimRequestsUseCase,
      );
    });

final oldStockProvider = StateNotifierProvider<OldStockNotifier, OldStockState>(
  (ref) {
    final getOldStockUseCase = ref.watch(getOldStockUseCaseProvider);
    return OldStockNotifier(getOldStockUseCase);
  },
);

final claimRequestsListProvider = StateNotifierProvider<
  ClaimRequestsListNotifier,
  ClaimRequestsListState
>((ref) {
  final getClaimRequestsUseCase = ref.watch(getClaimRequestsUseCaseProvider);
  return ClaimRequestsListNotifier(getClaimRequestsUseCase);
});

final searchSuggestionsProvider =
    StateNotifierProvider<SearchSuggestionsNotifier, SearchSuggestionsState>(
      (ref) => SearchSuggestionsNotifier(ref.read(getPostsUseCaseProvider)),
    );

final appointmentsListProvider =
    StateNotifierProvider<AppointmentsListNotifier, AppointmentsListState>((
      ref,
    ) {
      final getAppointmentsUseCase = ref.watch(getAppointmentsUseCaseProvider);
      return AppointmentsListNotifier(getAppointmentsUseCase);
    });

final appointmentDetailProvider = StateNotifierProvider.autoDispose
    .family<AppointmentDetailNotifier, AppointmentDetailState, int>((
      ref,
      appointmentID,
    ) {
      final getAppointmentDetailUseCase = ref.watch(
        getAppointmentDetailUseCaseProvider,
      );
      final notifier = AppointmentDetailNotifier(getAppointmentDetailUseCase);

      // Auto load khi provider được tạo
      Future.microtask(() => notifier.loadAppointmentDetail(appointmentID));

      return notifier;
    });

final appointmentUpdatingProvider = Provider.family<bool, int>((
  ref,
  appointmentID,
) {
  return ref.watch(appointmentProvider).isAppointmentUpdating(appointmentID);
});

final rankingProvider = StateNotifierProvider<RankingNotifier, RankingState>((
  ref,
) {
  final getUserRanksUseCase = ref.watch(getUserRanksUseCaseProvider);
  return RankingNotifier(getUserRanksUseCase);
});

final myGoodDeedsProvider =
    StateNotifierProvider<MyGoodDeedsNotifier, MyGoodDeedsState>((ref) {
      final getMyGoodDeedsUseCase = ref.watch(getMyGoodDeedsUseCaseProvider);
      return MyGoodDeedsNotifier(getMyGoodDeedsUseCase);
    });

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    final getSettingsUseCase = ref.watch(getSettingsUseCaseProvider);
    final getSettingByKeyUseCase = ref.watch(getSettingByKeyUseCaseProvider);
    return SettingsNotifier(getSettingsUseCase, getSettingByKeyUseCase);
  },
);

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      return NotificationNotifier(
        ref.read(getNotificationsUseCaseProvider),
        ref.read(markNotificationReadUseCaseProvider),
        ref.read(markAllNotificationsReadUseCaseProvider),
        ref,
      );
    });

final unreadNotificationCountProvider = Provider<int>((ref) {
  final notificationState = ref.watch(notificationProvider);
  return notificationState.unreadCount;
});

// Provider để theo dõi việc skip permission request
final permissionRequestSkippedProvider = StateProvider<bool>((ref) => false);

final appointmentProvider =
    StateNotifierProvider<AppointmentNotifier, AppointmentState>((ref) {
      final updateAppointmentUseCase = ref.watch(
        updateAppointmentUseCaseProvider,
      );
      return AppointmentNotifier(updateAppointmentUseCase);
    });
