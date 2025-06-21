import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:trao_doi_do_app/core/di/dependency_injection.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';

class TransactionStatusHelpers {
  static Future<void> handleTransactionStatusUpdate({
    required WidgetRef ref,
    required BuildContext context,
    required Transaction transaction,
    required int newStatus,
    Function(Transaction)? onTransactionUpdated,
  }) async {
    // Hiển thị loading dialog
    context.showLoadingDialog(message: _getLoadingMessage(newStatus));

    try {
      final updateUseCase = ref.read(updateTransactionStatusUseCaseProvider);
      final transactionsNotifier = ref.read(transactionsListProvider.notifier);

      final result = await updateUseCase(transaction.id, newStatus);

      // Đóng loading dialog
      if (context.mounted) {
        context.dismissDialog();
      }

      result.fold(
        (failure) {
          if (context.mounted) {
            context.showErrorDialog(
              title: 'Lỗi cập nhật',
              message: failure.message,
            );
          }
        },
        (updatedTransaction) {
          // Refresh transactions list sau khi update status thành công
          transactionsNotifier.refresh();

          if (context.mounted) {
            final statusText = _getSuccessMessage(newStatus);
            context.showSuccessDialog(title: 'Thành công', message: statusText);
          }
          onTransactionUpdated?.call(updatedTransaction);
        },
      );
    } catch (e) {
      // Đóng loading dialog nếu có lỗi
      if (context.mounted) {
        context.dismissDialog();
        context.showErrorDialog(
          title: 'Lỗi hệ thống',
          message: 'Có lỗi xảy ra: ${e.toString()}',
        );
      }
    }
  }

  static Future<void> showUndoConfirmationDialog({
    required BuildContext context,
    required WidgetRef ref,
    required Transaction transaction,
    Function(Transaction)? onTransactionUpdated,
  }) async {
    final result = await context.showConfirmDialog(
      title: 'Xác nhận hoàn tác',
      content:
          'Bạn chỉ nên sử dụng chức năng này nếu giao dịch đã được đánh dấu hoàn tất '
          'nhưng thực tế không diễn ra. Hành động này sẽ chuyển giao dịch sang trạng thái thất bại '
          'và không thể khôi phục.\n\n'
          'Bạn có chắc chắn muốn tiếp tục?',
      confirmText: 'Hoàn tác',
      cancelText: 'Hủy',
      isDangerous: true,
    );

    if (result == true) {
      await handleTransactionStatusUpdate(
        ref: ref,
        context: context,
        transaction: transaction,
        newStatus: 4, // Failed status
        onTransactionUpdated: onTransactionUpdated,
      );
    }
  }

  // Helper methods để lấy message phù hợp
  static String _getLoadingMessage(int status) {
    switch (status) {
      case 2:
        return 'Đang hoàn tất giao dịch...';
      case 3:
        return 'Đang từ chối giao dịch...';
      case 4:
        return 'Đang hoàn tác giao dịch...';
      default:
        return 'Đang cập nhật...';
    }
  }

  static String _getSuccessMessage(int status) {
    switch (status) {
      case 2:
        return 'Giao dịch đã được hoàn tất thành công!';
      case 3:
        return 'Giao dịch đã được từ chối!';
      case 4:
        return 'Giao dịch đã được hoàn tác sang trạng thái thất bại!';
      default:
        return 'Cập nhật thành công!';
    }
  }

  // Thêm method để xác nhận từ chối với thông tin chi tiết
  static Future<void> showRejectConfirmationDialog({
    required BuildContext context,
    required WidgetRef ref,
    required Transaction transaction,
    Function(Transaction)? onTransactionUpdated,
  }) async {
    final result = await context.showConfirmDialog(
      title: 'Xác nhận từ chối',
      content:
          'Bạn có chắc chắn muốn từ chối yêu cầu giao dịch này?\n\n'
          'Hành động này sẽ:\n'
          '• Hủy bỏ yêu cầu giao dịch\n'
          '• Thông báo cho người yêu cầu\n'
          '• Không thể hoàn tác\n\n'
          'Vui lòng xác nhận quyết định của bạn.',
      confirmText: 'Từ chối',
      cancelText: 'Hủy',
      isDangerous: true,
    );

    if (result == true) {
      await handleTransactionStatusUpdate(
        ref: ref,
        context: context,
        transaction: transaction,
        newStatus: 3, // Cancelled
        onTransactionUpdated: onTransactionUpdated,
      );
    }
  }

  // Thêm method để xác nhận hoàn tất với thông tin chi tiết
  static Future<void> showCompleteConfirmationDialog({
    required BuildContext context,
    required WidgetRef ref,
    required Transaction transaction,
    Function(Transaction)? onTransactionUpdated,
  }) async {
    final result = await context.showConfirmDialog(
      title: 'Xác nhận hoàn tất',
      content:
          'Bạn có chắc chắn giao dịch đã được thực hiện thành công?\n\n'
          'Hành động này sẽ:\n'
          '• Đánh dấu giao dịch đã hoàn tất\n'
          '• Kết thúc quá trình giao dịch\n'
          '• Thông báo cho người yêu cầu\n\n'
          'Chỉ chọn "Hoàn tất" khi bạn đã thực sự giao hàng/gặp mặt thành công.',
      confirmText: 'Hoàn tất',
      cancelText: 'Chưa xong',
    );

    if (result == true) {
      await handleTransactionStatusUpdate(
        ref: ref,
        context: context,
        transaction: transaction,
        newStatus: 2, // Success
        onTransactionUpdated: onTransactionUpdated,
      );
    }
  }
}
