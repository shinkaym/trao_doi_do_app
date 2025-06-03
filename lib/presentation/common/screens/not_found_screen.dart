import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';

class NotFoundScreen extends StatelessWidget {
  final String? path;

  const NotFoundScreen({Key? key, this.path}) : super(key: key);

  void _handleGoHome(BuildContext context) {
    context.goNamed('posts'); // hoặc tên route chính của bạn
  }

  void _handleGoBack(BuildContext context) {
    if (context.canPop) {
      context.pop();
    } else {
      _handleGoHome(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    final theme = context.theme;
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colorScheme.primary,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          backgroundColor: colorScheme.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => _handleGoBack(context),
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        body: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header section với gradient
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, colorScheme.primary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 60 : 40,
                      horizontal: 24,
                    ),
                    child: Column(
                      children: [
                        // 404 Icon container
                        Container(
                          width: isTablet ? 120 : 100,
                          height: isTablet ? 120 : 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.search_off_outlined,
                                size: isTablet ? 50 : 40,
                                color: Colors.white,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '404',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 12 : 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 24 : 16),
                        Text(
                          'Trang không tìm thấy',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 32 : 28,
                          ),
                        ),
                        SizedBox(height: isTablet ? 12 : 8),
                        Text(
                          'Xin lỗi, trang bạn đang tìm kiếm không tồn tại',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isTablet ? 18 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                // Content section
                Padding(
                  padding: EdgeInsets.all(isTablet ? 32 : 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 500 : double.infinity,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: isTablet ? 40 : 32),

                        // Error details
                        if (path != null) ...[
                          Container(
                            padding: EdgeInsets.all(isTablet ? 20 : 16),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer.withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colorScheme.errorContainer.withOpacity(
                                  0.3,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: colorScheme.error,
                                  size: isTablet ? 24 : 20,
                                ),
                                SizedBox(width: isTablet ? 16 : 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Đường dẫn không hợp lệ:',
                                        style: TextStyle(
                                          color: theme.hintColor,
                                          fontSize: isTablet ? 14 : 12,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        path!,
                                        style: TextStyle(
                                          color: colorScheme.error,
                                          fontSize: isTablet ? 16 : 14,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: isTablet ? 32 : 24),
                        ],

                        // 404 Illustration
                        Container(
                          padding: EdgeInsets.all(isTablet ? 40 : 32),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              // Large 404 text
                              Text(
                                '404',
                                style: TextStyle(
                                  fontSize: isTablet ? 80 : 64,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary.withOpacity(0.7),
                                  height: 1,
                                ),
                              ),
                              SizedBox(height: isTablet ? 16 : 12),
                              // Emoji or icon
                              Text(
                                '🔍',
                                style: TextStyle(fontSize: isTablet ? 48 : 36),
                              ),
                              SizedBox(height: isTablet ? 16 : 12),
                              Text(
                                'Ôi không! Trang này đã biến mất',
                                style: TextStyle(
                                  color: theme.hintColor,
                                  fontSize: isTablet ? 18 : 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isTablet ? 32 : 24),

                        // Suggestions
                        // Container(
                        //   padding: EdgeInsets.all(isTablet ? 20 : 16),
                        //   decoration: BoxDecoration(
                        //     color: colorScheme.primaryContainer.withOpacity(
                        //       0.1,
                        //     ),
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(
                        //       color: colorScheme.primaryContainer.withOpacity(
                        //         0.3,
                        //       ),
                        //       width: 1,
                        //     ),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         children: [
                        //           Icon(
                        //             Icons.lightbulb_outline,
                        //             color: colorScheme.primary,
                        //             size: isTablet ? 24 : 20,
                        //           ),
                        //           SizedBox(width: isTablet ? 12 : 8),
                        //           Text(
                        //             'Có thể bạn muốn:',
                        //             style: TextStyle(
                        //               color: colorScheme.primary,
                        //               fontSize: isTablet ? 16 : 14,
                        //               fontWeight: FontWeight.w600,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       SizedBox(height: isTablet ? 16 : 12),
                        //       Text(
                        //         '• Kiểm tra lại đường dẫn URL\n'
                        //         '• Quay về trang chủ\n'
                        //         '• Sử dụng thanh điều hướng\n'
                        //         '• Liên hệ hỗ trợ nếu cần thiết',
                        //         style: TextStyle(
                        //           color: theme.hintColor,
                        //           fontSize: isTablet ? 14 : 12,
                        //           height: 1.5,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        SizedBox(height: isTablet ? 40 : 32),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: isTablet ? 56 : 50,
                                child: OutlinedButton.icon(
                                  onPressed: () => _handleGoBack(context),
                                  icon: const Icon(Icons.arrow_back),
                                  label: Text(
                                    'Quay lại',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: colorScheme.primary,
                                    side: BorderSide(
                                      color: colorScheme.primary,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: isTablet ? 16 : 12),
                            Expanded(
                              child: SizedBox(
                                height: isTablet ? 56 : 50,
                                child: ElevatedButton.icon(
                                  onPressed: () => _handleGoHome(context),
                                  icon: const Icon(Icons.home),
                                  label: Text(
                                    'Trang chủ',
                                    style: TextStyle(
                                      fontSize: isTablet ? 16 : 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isTablet ? 24 : 20),

                        // Help section
                        // Divider(color: theme.dividerColor),
                        // SizedBox(height: isTablet ? 24 : 20),

                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     Text(
                        //       'Cần hỗ trợ? ',
                        //       style: TextStyle(
                        //         color: theme.hintColor,
                        //         fontSize: isTablet ? 16 : 14,
                        //       ),
                        //     ),
                        //     GestureDetector(
                        //       onTap: () {
                        //         // Navigate to support/contact page
                        //         // context.goNamed('support');
                        //         context.showInfoSnackBar(
                        //           'Chức năng hỗ trợ đang được phát triển',
                        //         );
                        //       },
                        //       child: Text(
                        //         'Liên hệ chúng tôi',
                        //         style: TextStyle(
                        //           color: colorScheme.primary,
                        //           fontSize: isTablet ? 16 : 14,
                        //           fontWeight: FontWeight.w600,
                        //           decoration: TextDecoration.underline,
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        SizedBox(height: isTablet ? 40 : 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
