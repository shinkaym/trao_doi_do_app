import 'package:flutter/material.dart';
import 'package:trao_doi_do_app/core/extensions/extensions.dart';
import 'package:trao_doi_do_app/domain/entities/transaction.dart';

class TransactionActionButtons extends StatelessWidget {
  final Transaction transaction;
  final bool isPostOwner;
  final int index;
  final bool isEditing;
  final bool isLoading;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final VoidCallback? onReject;
  final VoidCallback? onComplete;
  final VoidCallback? onUndo;
  final int? postType;

  const TransactionActionButtons({
    super.key,
    required this.transaction,
    required this.isPostOwner,
    required this.index,
    this.isEditing = false,
    this.isLoading = false,
    this.onEdit,
    this.onCancel,
    this.onSave,
    this.onReject,
    this.onComplete,
    this.onUndo,
    this.postType,
  });

  // Thêm method xử lý dialog từ chối
  Future<void> _handleRejectWithDialog(BuildContext context) async {
    final result = await context.showConfirmDialog(
      title: 'Xác nhận từ chối',
      content:
          'Bạn có chắc chắn muốn từ chối yêu cầu giao dịch này? '
          'Hành động này không thể hoàn tác.',
      confirmText: 'Từ chối',
      cancelText: 'Hủy',
      isDangerous: true,
    );

    if (result == true) {
      onReject?.call();
    }
  }

  // Thêm method xử lý dialog hoàn tất
  Future<void> _handleCompleteWithDialog(BuildContext context) async {
    final result = await context.showConfirmDialog(
      title: 'Xác nhận hoàn tất',
      content:
          'Bạn có chắc chắn giao dịch đã được thực hiện thành công? '
          'Việc đánh dấu hoàn tất sẽ kết thúc giao dịch này.',
      confirmText: 'Hoàn tất',
      cancelText: 'Hủy',
    );

    if (result == true) {
      onComplete?.call();
    }
  }

  // Thêm method xử lý dialog lưu thay đổi
  Future<void> _handleSaveWithDialog(BuildContext context) async {
    final result = await context.showConfirmDialog(
      title: 'Xác nhận lưu thay đổi',
      content:
          'Bạn có chắc chắn muốn lưu các thay đổi đã thực hiện? '
          'Người yêu cầu sẽ nhận được thông báo về việc cập nhật.',
      confirmText: 'Lưu thay đổi',
      cancelText: 'Hủy',
    );

    if (result == true) {
      onSave?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;

    if (!isPostOwner) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(height: isTablet ? 16 : 12),

        // Edit mode actions (chỉ cho pending transactions và postType != 3)
        if (isEditing && transaction.status == 1 && postType != 3) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : onCancel,
                  child: const Text('Hủy'),
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Expanded(
                child: ElevatedButton(
                  onPressed:
                      isLoading ? null : () => _handleSaveWithDialog(context),
                  child:
                      isLoading
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Lưu thay đổi'),
                ),
              ),
            ],
          ),
        ] else if (transaction.status == 1) ...[
          // Normal actions for pending transactions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleRejectWithDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
                  ),
                  child: Text(
                    'Từ chối',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Chỉ hiện nút chỉnh sửa nếu postType != 3
              if (postType != 3) ...[
                SizedBox(width: isTablet ? 12 : 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onEdit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 12 : 8,
                      ),
                    ),
                    child: Text(
                      'Chỉnh sửa',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: isTablet ? 12 : 8),

          // Complete transaction button
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleCompleteWithDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
                  ),
                  child: Text(
                    'Hoàn tất giao dịch',
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else if (transaction.status == 2 && index == 0) ...[
          // Actions for completed transactions (allow undo to failed)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onUndo,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.undo, size: isTablet ? 16 : 14),
                      SizedBox(width: isTablet ? 8 : 6),
                      Text(
                        'Hoàn tác',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
