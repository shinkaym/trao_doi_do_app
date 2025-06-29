import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:trao_doi_do_app/core/utils/logger_utils.dart';

class ConnectivityService {
  final Connectivity _connectivity;
  final ILogger _logger;

  // Sửa lỗi: Thay đổi type từ ConnectivityResult thành List<ConnectivityResult>
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  ConnectivityService(this._connectivity, this._logger);

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final initialStatus = await checkConnectivity();
      _statusController.add(initialStatus);

      // Listen for connectivity changes
      // Sửa lỗi: Thay đổi callback để nhận List<ConnectivityResult>
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) async {
          _logger.i('Connectivity changed: $results');
          final status = await _mapConnectivityResults(results);
          _statusController.add(status);
        },
        onError: (error) {
          _logger.e('Connectivity stream error', error);
          _statusController.add(ConnectivityStatus.unknown);
        },
      );

      _logger.i('Connectivity service initialized');
    } catch (e, stackTrace) {
      _logger.e('Error initializing connectivity service', e, stackTrace);
    }
  }

  /// Check current connectivity status
  Future<ConnectivityStatus> checkConnectivity() async {
    try {
      // Sửa lỗi: checkConnectivity() giờ trả về List<ConnectivityResult>
      final results = await _connectivity.checkConnectivity();
      return await _mapConnectivityResults(results);
    } catch (e, stackTrace) {
      _logger.e('Error checking connectivity', e, stackTrace);
      return ConnectivityStatus.unknown;
    }
  }

  /// Check if device is connected to internet
  Future<bool> isConnected() async {
    final status = await checkConnectivity();
    return status == ConnectivityStatus.connected;
  }

  /// Check if device has no internet connection
  Future<bool> isDisconnected() async {
    final status = await checkConnectivity();
    return status == ConnectivityStatus.disconnected;
  }

  /// Test internet connectivity by pinging a reliable server
  Future<bool> hasInternetAccess() async {
    try {
      // First check basic connectivity
      final basicConnectivity = await isConnected();
      if (!basicConnectivity) {
        return false;
      }

      // Test actual internet access
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      _logger.w('Internet access check failed: $e');
      return false;
    }
  }

  /// Get current connection type
  Future<String> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _getConnectionTypeName(results);
    } catch (e, stackTrace) {
      _logger.e('Error getting connection type', e, stackTrace);
      return 'Unknown';
    }
  }

  /// Get detailed connectivity information
  Future<ConnectivityInfo> getConnectivityInfo() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final status = await _mapConnectivityResults(results);
      final hasInternet = await hasInternetAccess();

      return ConnectivityInfo(
        status: status,
        connectionType: _getConnectionTypeName(results),
        hasInternetAccess: hasInternet,
        timestamp: DateTime.now(),
      );
    } catch (e, stackTrace) {
      _logger.e('Error getting connectivity info', e, stackTrace);
      return ConnectivityInfo(
        status: ConnectivityStatus.unknown,
        connectionType: 'Unknown',
        hasInternetAccess: false,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Dispose the service
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
    _logger.i('Connectivity service disposed');
  }

  /// Map List<ConnectivityResult> to our custom status
  /// Sửa lỗi: Thay đổi method để xử lý List thay vì single result
  Future<ConnectivityStatus> _mapConnectivityResults(
    List<ConnectivityResult> results,
  ) async {
    // Nếu không có kết nối nào
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.disconnected;
    }

    // Kiểm tra xem có kết nối WiFi, Mobile hoặc Ethernet không
    final hasValidConnection = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);

    if (hasValidConnection) {
      // Verify internet access for connected states
      final hasInternet = await hasInternetAccess();
      return hasInternet
          ? ConnectivityStatus.connected
          : ConnectivityStatus.limitedConnection;
    }

    return ConnectivityStatus.unknown;
  }

  /// Get user-friendly connection type name
  /// Sửa lỗi: Thay đổi method để xử lý List<ConnectivityResult>
  String _getConnectionTypeName(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return 'No Connection';
    }

    // Ưu tiên hiển thị theo thứ tự: WiFi > Ethernet > Mobile > Other
    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile Data';
    } else if (results.contains(ConnectivityResult.none)) {
      return 'No Connection';
    } else {
      // Nếu có nhiều kết nối, hiển thị danh sách
      final connectionTypes = results
          .where((result) => result != ConnectivityResult.none)
          .map((result) => _getSingleConnectionTypeName(result))
          .toSet() // Remove duplicates
          .join(', ');
      return connectionTypes.isNotEmpty ? connectionTypes : 'Unknown';
    }
  }

  /// Helper method để get tên cho single ConnectivityResult
  String _getSingleConnectionTypeName(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'WiFi';
      case ConnectivityResult.mobile:
        return 'Mobile Data';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Other';
      case ConnectivityResult.none:
        return 'No Connection';
      default:
        return 'Unknown';
    }
  }
}

/// Connectivity status enum
enum ConnectivityStatus { connected, disconnected, limitedConnection, unknown }

/// Detailed connectivity information
class ConnectivityInfo {
  final ConnectivityStatus status;
  final String connectionType;
  final bool hasInternetAccess;
  final DateTime timestamp;

  ConnectivityInfo({
    required this.status,
    required this.connectionType,
    required this.hasInternetAccess,
    required this.timestamp,
  });

  bool get isConnected => status == ConnectivityStatus.connected;
  bool get isDisconnected => status == ConnectivityStatus.disconnected;
  bool get hasLimitedConnection =>
      status == ConnectivityStatus.limitedConnection;

  @override
  String toString() {
    return 'ConnectivityInfo(status: $status, type: $connectionType, internet: $hasInternetAccess)';
  }
}