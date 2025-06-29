import 'dart:async';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/services/connectivity_service.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final ConnectivityService _connectivityService;
  final ILogger _logger;
  StreamSubscription<ConnectivityStatus>? _statusSubscription;

  ConnectivityNotifier(this._connectivityService, this._logger)
    : super(const ConnectivityState()) {
    _initializeConnectivity();
  }

  Future<void> _initializeConnectivity() async {
    try {
      state = state.copyWith(isLoading: true);

      // Initialize connectivity service
      await _connectivityService.initialize();

      // Get initial connectivity info
      final info = await _connectivityService.getConnectivityInfo();

      state = state.copyWith(
        status: info.status,
        connectionType: info.connectionType,
        hasInternetAccess: info.hasInternetAccess,
        lastUpdated: info.timestamp,
        isLoading: false,
      );

      // Listen for connectivity changes
      _statusSubscription = _connectivityService.statusStream.listen(
        (status) async {
          await _updateConnectivityStatus(status);
        },
        onError: (error) {
          _logger.e('Connectivity stream error', error);
          state = state.copyWith(
            status: ConnectivityStatus.unknown,
            error: 'Lỗi theo dõi kết nối: $error',
          );
        },
      );

      _logger.i('Connectivity monitoring initialized');
    } catch (e, stackTrace) {
      _logger.e('Error initializing connectivity', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi khởi tạo theo dõi kết nối: $e',
      );
    }
  }

  Future<void> _updateConnectivityStatus(ConnectivityStatus status) async {
    try {
      final info = await _connectivityService.getConnectivityInfo();

      state = state.copyWith(
        status: info.status,
        connectionType: info.connectionType,
        hasInternetAccess: info.hasInternetAccess,
        lastUpdated: info.timestamp,
        error: null,
      );

      _logger.i('Connectivity updated: ${info.toString()}');
    } catch (e, stackTrace) {
      _logger.e('Error updating connectivity status', e, stackTrace);
      state = state.copyWith(
        status: status,
        error: 'Lỗi cập nhật trạng thái kết nối: $e',
      );
    }
  }

  Future<void> checkConnection() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final info = await _connectivityService.getConnectivityInfo();

      state = state.copyWith(
        status: info.status,
        connectionType: info.connectionType,
        hasInternetAccess: info.hasInternetAccess,
        lastUpdated: info.timestamp,
        isLoading: false,
      );

      _logger.i('Manual connectivity check: ${info.toString()}');
    } catch (e, stackTrace) {
      _logger.e('Error checking connection', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi kiểm tra kết nối: $e',
      );
    }
  }

  Future<bool> testInternetAccess() async {
    try {
      state = state.copyWith(isLoading: true);

      final hasInternet = await _connectivityService.hasInternetAccess();

      state = state.copyWith(
        hasInternetAccess: hasInternet,
        lastUpdated: DateTime.now(),
        isLoading: false,
      );

      return hasInternet;
    } catch (e, stackTrace) {
      _logger.e('Error testing internet access', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Lỗi kiểm tra truy cập internet: $e',
      );
      return false;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }
}

class ConnectivityState {
  final bool isLoading;
  final ConnectivityStatus status;
  final String connectionType;
  final bool hasInternetAccess;
  final DateTime? lastUpdated;
  final String? error;

  const ConnectivityState({
    this.isLoading = false,
    this.status = ConnectivityStatus.unknown,
    this.connectionType = '',
    this.hasInternetAccess = false,
    this.lastUpdated,
    this.error,
  });

  bool get hasError => error != null;
  bool get isConnected =>
      status == ConnectivityStatus.connected && hasInternetAccess;
  bool get isDisconnected => status == ConnectivityStatus.disconnected;
  bool get hasLimitedConnection =>
      status == ConnectivityStatus.limitedConnection;

  ConnectivityState copyWith({
    bool? isLoading,
    ConnectivityStatus? status,
    String? connectionType,
    bool? hasInternetAccess,
    DateTime? lastUpdated,
    String? error,
  }) {
    return ConnectivityState(
      isLoading: isLoading ?? this.isLoading,
      status: status ?? this.status,
      connectionType: connectionType ?? this.connectionType,
      hasInternetAccess: hasInternetAccess ?? this.hasInternetAccess,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: error,
    );
  }

  @override
  String toString() {
    return 'ConnectivityState(isLoading: $isLoading, status: $status, type: $connectionType, hasInternet: $hasInternetAccess, error: $error)';
  }
}
