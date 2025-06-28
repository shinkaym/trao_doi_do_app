import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/presentation/enums/index.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/providers/appointment_detail_provider.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/providers/appointment_provider.dart';
import 'package:trao_doi_do_app/presentation/features/appointments/providers/appointments_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/interest_detail_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/transaction_by_interest_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/transaction_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/transactions_provider.dart';
import 'package:trao_doi_do_app/presentation/features/interests/providers/interests_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/post_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/posts_provider.dart';
import 'package:trao_doi_do_app/presentation/features/post/providers/post_detail_provider.dart';
import 'package:trao_doi_do_app/presentation/features/profile/providers/my_posts_provider.dart';
import 'package:trao_doi_do_app/presentation/features/splash/providers/splash_provider.dart';
import 'package:trao_doi_do_app/presentation/features/onboarding/providers/onboarding_provider.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/providers/claim_request_provider.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/providers/claim_requests_list_provider.dart';
import 'package:trao_doi_do_app/presentation/features/item_warehouse/providers/old_stock_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/category_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/item_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/interest_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/messages_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/search_suggestion_provider.dart';
import 'package:trao_doi_do_app/presentation/providers/unread_count_provider.dart';
import '../modules/core_module.dart';
import '../modules/domain_module.dart';

/// Presentation Module - Contains UI state providers
class PresentationModule {
  static void initialize() {
    // Module initialization logic if needed
  }
}

// =============================================================================
// SPLASH & ONBOARDING PROVIDERS
// =============================================================================

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
  final getTransactionByInterestUseCase = ref.watch(
    getTransactionByInterestUseCaseProvider,
  );
  return TransactionNotifier(
    createTransactionUseCase,
    updateTransactionUseCase,
    getTransactionByInterestUseCase,
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

final interestedPostsProvider = StateNotifierProvider.autoDispose<
  InterestsListNotifier,
  InterestsListState
>((ref) {
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

final postsWithInterestsProvider = StateNotifierProvider.autoDispose<
  InterestsListNotifier,
  InterestsListState
>((ref) {
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
    StateNotifierProvider.autoDispose<UnreadCountNotifier, UnreadCountState>((
      ref,
    ) {
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
    StateNotifierProvider.autoDispose<PostsListNotifier, PostsListState>((ref) {
      final getPostsUseCase = ref.watch(getPostsUseCaseProvider);
      return PostsListNotifier(getPostsUseCase);
    });

final postsProviderFamily = StateNotifierProvider.family
    .autoDispose<PostsListNotifier, PostsListState, PostType>((ref, postType) {
      // Inject GetPostsUseCase dependency here
      final getPostsUseCase = ref.watch(getPostsUseCaseProvider);
      return PostsListNotifier(getPostsUseCase);

      // Temporary mock implementation
    });

final myPostsListProvider =
    StateNotifierProvider.autoDispose<MyPostsListNotifier, MyPostsListState>((
      ref,
    ) {
      final getMyPostsUseCase = ref.watch(getMyPostsUseCaseProvider);
      return MyPostsListNotifier(getMyPostsUseCase);
    });

final postDetailProvider =
    StateNotifierProvider.autoDispose<PostDetailNotifier, PostDetailState>((
      ref,
    ) {
      final getPostDetailUseCase = ref.watch(getPostDetailUseCaseProvider);
      return PostDetailNotifier(getPostDetailUseCase);
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

final oldStockProvider =
    StateNotifierProvider.autoDispose<OldStockNotifier, OldStockState>((ref) {
      final getOldStockUseCase = ref.watch(getOldStockUseCaseProvider);
      return OldStockNotifier(getOldStockUseCase);
    });

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

final appointmentsListProvider = StateNotifierProvider.autoDispose<
  AppointmentsListNotifier,
  AppointmentsListState
>((ref) {
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
