import 'package:hooks_riverpod/hooks_riverpod.dart';

// Import all modules
import 'modules/core_module.dart';
import 'modules/network_module.dart';
import 'modules/auth_module.dart';
import 'modules/data_module.dart';
import 'modules/domain_module.dart';
import 'modules/presentation_module.dart';
import 'modules/websocket_module.dart';

// Re-export all providers for easy access
export 'modules/core_module.dart';
export 'modules/network_module.dart';
export 'modules/auth_module.dart';
export 'modules/data_module.dart';
export 'modules/domain_module.dart';
export 'modules/presentation_module.dart';
export 'modules/websocket_module.dart';

/// Main dependency injection setup
class DependencyInjection {
  static void initialize() {
    // Initialize modules if needed
    CoreModule.initialize();
    NetworkModule.initialize();
    AuthModule.initialize();
    DataModule.initialize();
    DomainModule.initialize();
    PresentationModule.initialize();
    WebSocketModule.initialize();
  }
}

/// Dispose function
void disposeDependencies(ProviderContainer container) {
  container.dispose();
}

/// Dispose all dependencies including WebSocket cleanup
void disposeAllDependencies(ProviderContainer container) {
  // Dispose WebSocket connections first
  try {
    final chatWebSocketNotifier = container.read(
      chatWebSocketProvider.notifier,
    );
    chatWebSocketNotifier.disconnect();
  } catch (e) {
    // Handle case where provider might not be initialized
  }

  // Dispose container
  container.dispose();
}
