import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trao_doi_do_app/theme/extensions/app_theme_extension.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _progressController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Khởi tạo animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Tạo animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));

    // Bắt đầu animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Bắt đầu fade và scale animation
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    
    // Bắt đầu progress animation sau 500ms
    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();
    
    // Điều hướng sau khi hoàn thành
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<AppThemeExtension>()!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              ext.primary?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
              ext.background ?? Colors.white,
              ext.primary?.withOpacity(0.05) ?? Colors.blue.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Center(
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Logo với shadow và glow effect
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: ext.primary?.withOpacity(0.3) ?? 
                                             Colors.blue.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    height: 120,
                                    width: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 32),
                              
                              // Tiêu đề với hiệu ứng gradient
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [
                                    ext.primary ?? Colors.blue,
                                    ext.primary?.withOpacity(0.7) ?? Colors.blue.withOpacity(0.7),
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  'Trao Đổi Đồ Cũ',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 12),
                              
                              // Subtitle
                              Text(
                                'Kết nối - Chia sẻ - Tái sử dụng',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: ext.primaryTextColor?.withOpacity(0.7),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Progress indicator và loading text
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Progress bar với animation
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 200,
                          height: 4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: ext.primary?.withOpacity(0.2) ?? 
                                   Colors.blue.withOpacity(0.2),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                width: 200 * _progressAnimation.value,
                                height: 4,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  gradient: LinearGradient(
                                    colors: [
                                      ext.primary ?? Colors.blue,
                                      ext.primary?.withOpacity(0.7) ?? Colors.blue.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Loading text với fade animation
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Đang khởi tạo ứng dụng...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: ext.primaryTextColor?.withOpacity(0.6),
                            ),
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}