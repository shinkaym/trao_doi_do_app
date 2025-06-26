import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class SplashScreen extends HookConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    final logoController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    );
    final textController = useAnimationController(
      duration: const Duration(milliseconds: 600),
    );
    final progressController = useAnimationController(
      duration: const Duration(milliseconds: 3500),
    );

    // Animations using useMemoized for performance
    final logoScaleAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: logoController, curve: Curves.elasticOut),
      ),
      [logoController],
    );

    final logoOpacityAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: logoController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
        ),
      ),
      [logoController],
    );

    final textOpacityAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: textController, curve: Curves.easeInOut),
      ),
      [textController],
    );

    final textSlideAnimation = useMemoized(
      () => Tween<double>(begin: 30.0, end: 0.0).animate(
        CurvedAnimation(parent: textController, curve: Curves.easeOutCubic),
      ),
      [textController],
    );

    final progressAnimation = useMemoized(
      () => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: progressController,
          curve: Curves.easeInOutCubic,
        ), // Đổi curve cho mượt hơn
      ),
      [progressController],
    );

    // State for preventing multiple initializations
    final isInitialized = useRef(false);

    // Enhanced splash sequence function với progress tracking
    final startSplashSequence = useCallback(() async {
      if (isInitialized.value) return;
      isInitialized.value = true;

      try {
        // Start splash state
        ref.read(splashProvider.notifier).startSplash();

        // Stage 1: Logo animation (0-300ms)
        logoController.forward();
        await Future.delayed(const Duration(milliseconds: 300));

        // Stage 2: Text animation (300-900ms)
        textController.forward();

        // Stage 3: Start progress immediately với logo/text (0-3500ms total)
        progressController.forward();
        await Future.delayed(const Duration(milliseconds: 600));

        // Stage 4: Wait for progress to complete (total ~4000ms)
        await Future.delayed(const Duration(milliseconds: 3100));

        // Complete splash
        ref.read(splashProvider.notifier).completeSplash();
      } catch (e) {
        debugPrint('Error in splash sequence: $e');
        ref.read(splashProvider.notifier).completeSplash();
      }
    }, [ref, logoController, textController, progressController]);

    // Start splash sequence on first build
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        startSplashSequence();
      });
      return null;
    }, []);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: colorScheme.background,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.1),
                colorScheme.background,
                colorScheme.primaryContainer.withOpacity(0.05),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                _LogoSection(
                  isTablet: isTablet,
                  colorScheme: colorScheme,
                  scaleAnimation: logoScaleAnimation,
                  opacityAnimation: logoOpacityAnimation,
                ),
                SizedBox(height: isTablet ? 40 : 30),
                _TextSection(
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  opacityAnimation: textOpacityAnimation,
                  slideAnimation: textSlideAnimation,
                ),
                const Spacer(flex: 2),
                _LoadingSection(
                  isTablet: isTablet,
                  theme: theme,
                  colorScheme: colorScheme,
                  progressAnimation: progressAnimation,
                ),
                // _BottomBranding(isTablet: isTablet, theme: theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoSection extends HookWidget {
  final bool isTablet;
  final ColorScheme colorScheme;
  final Animation<double> scaleAnimation;
  final Animation<double> opacityAnimation;

  const _LogoSection({
    required this.isTablet,
    required this.colorScheme,
    required this.scaleAnimation,
    required this.opacityAnimation,
  });

  @override
  Widget build(BuildContext context) {
    useAnimation(scaleAnimation);
    useAnimation(opacityAnimation);

    return Transform.scale(
      scale: scaleAnimation.value,
      child: Opacity(
        opacity: opacityAnimation.value,
        child: Container(
          width: isTablet ? 200 : 150,
          height: isTablet ? 200 : 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Icons.apps,
                    size: isTablet ? 80 : 60,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TextSection extends HookWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Animation<double> opacityAnimation;
  final Animation<double> slideAnimation;

  const _TextSection({
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.opacityAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    useAnimation(opacityAnimation);
    useAnimation(slideAnimation);

    return Transform.translate(
      offset: Offset(0, slideAnimation.value),
      child: Opacity(
        opacity: opacityAnimation.value,
        child: Column(
          children: [
            Text(
              'ShareAndSave',
              style: theme.textTheme.headlineLarge?.copyWith(
                color: colorScheme.onBackground,
                fontWeight: FontWeight.bold,
                fontSize: isTablet ? 36 : 28,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              '"Kết nối - Tìm lại - Trao đi"',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.hintColor,
                fontSize: isTablet ? 18 : 16,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSection extends HookWidget {
  final bool isTablet;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final Animation<double> progressAnimation;

  const _LoadingSection({
    required this.isTablet,
    required this.theme,
    required this.colorScheme,
    required this.progressAnimation,
  });

  @override
  Widget build(BuildContext context) {
    useAnimation(progressAnimation);

    return Padding(
      padding: EdgeInsets.only(
        bottom: isTablet ? 60 : 40,
        left: isTablet ? 60 : 40,
        right: isTablet ? 60 : 40,
      ),
      child: Column(
        children: [
          // Enhanced progress bar với animation mượt mà hơn
          Container(
            width: double.infinity,
            height: 6, // Tăng từ 4 lên 6 để dễ nhìn hơn
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(3),
            ),
            child: Stack(
              children: [
                // Progress bar chính
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progressAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
                // Shimmer effect (tùy chọn)
                if (progressAnimation.value > 0)
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progressAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.0),
                              Colors.white.withOpacity(0.1),
                              Colors.white.withOpacity(0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          // Progress percentage text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Đang khởi tạo...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
              Text(
                '${(progressAnimation.value * 100).toInt()}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.primary,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// class _BottomBranding extends StatelessWidget {
//   final bool isTablet;
//   final ThemeData theme;

//   const _BottomBranding({required this.isTablet, required this.theme});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: isTablet ? 40 : 24),
//       child: Column(
//         children: [
//           Text(
//             'Version 1.0.0',
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.hintColor.withOpacity(0.6),
//               fontSize: isTablet ? 14 : 12,
//             ),
//           ),
//           SizedBox(height: isTablet ? 8 : 4),
//           Text(
//             '© 2025 ShareAndSave App',
//             style: theme.textTheme.bodySmall?.copyWith(
//               color: theme.hintColor.withOpacity(0.4),
//               fontSize: isTablet ? 12 : 10,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
