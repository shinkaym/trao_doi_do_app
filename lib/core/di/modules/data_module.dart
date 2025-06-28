import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/data/datasources/local/category_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/local/onboarding_local_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/appointment_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/category_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/item_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/item_warehouse_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/ranking_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/transaction_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/interest_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/post_remote_datasource.dart';
import 'package:trao_doi_do_app/data/datasources/remote/message_remote_datasource.dart';
import '../modules/core_module.dart';
import '../modules/network_module.dart';

/// Data Module - Contains data source dependencies
class DataModule {
  static void initialize() {
    // Module initialization logic if needed
  }
}

// =============================================================================
// LOCAL DATA SOURCES
// =============================================================================

final onboardingLocalDataSourceProvider = Provider<OnboardingLocalDataSource>((
  ref,
) {
  final box = ref.watch(settingsBoxProvider);
  return OnboardingLocalDataSourceImpl(box);
});

final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((
  ref,
) {
  return CategoryLocalDataSourceImpl();
});

// =============================================================================
// REMOTE DATA SOURCES
// =============================================================================

final itemRemoteDataSourceProvider = Provider.autoDispose<ItemRemoteDataSource>(
  (ref) {
    final dioClient = ref.watch(dioClientProvider);
    return ItemRemoteDataSourceImpl(dioClient);
  },
);

final categoryRemoteDataSourceProvider =
    Provider.autoDispose<CategoryRemoteDataSource>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return CategoryRemoteDataSourceImpl(dioClient);
    });

final transactionRemoteDataSourceProvider =
    Provider.autoDispose<TransactionRemoteDataSource>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return TransactionRemoteDataSourceImpl(dioClient);
    });

final interestRemoteDataSourceProvider =
    Provider.autoDispose<InterestRemoteDataSource>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return InterestRemoteDataSourceImpl(dioClient);
    });

final postRemoteDataSourceProvider = Provider.autoDispose<PostRemoteDataSource>(
  (ref) {
    final dioClient = ref.watch(dioClientProvider);
    return PostRemoteDataSourceImpl(dioClient);
  },
);

final messageRemoteDataSourceProvider =
    Provider.autoDispose<MessageRemoteDataSource>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return MessageRemoteDataSourceImpl(dioClient);
    });

final itemWarehouseRemoteDataSourceProvider =
    Provider.autoDispose<ItemWarehouseRemoteDataSource>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return ItemWarehouseRemoteDataSourceImpl(dioClient);
    });

final appointmentRemoteDataSourceProvider =
    Provider.autoDispose<AppointmentRemoteDataSource>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return AppointmentRemoteDataSourceImpl(dioClient);
    });

final rankingRemoteDataSourceProvider =
    Provider.autoDispose<RankingRemoteDataSource>((ref) {
      final dioClient = ref.watch(dioClientProvider);
      return RankingRemoteDataSourceImpl(dioClient);
    });
