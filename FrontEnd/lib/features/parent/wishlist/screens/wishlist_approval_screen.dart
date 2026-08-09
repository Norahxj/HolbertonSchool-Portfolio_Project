import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/localization_extension.dart';
import '../controllers/wishlist_approval_controller.dart';
import '../models/wishlist_action_result.dart';
import '../widgets/wishlist_approval_view.dart';

class WishlistApprovalScreen extends StatelessWidget {
  const WishlistApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        return WishlistApprovalController()
          ..loadWishes();
      },
      child: const _WishlistApprovalContent(),
    );
  }
}

class _WishlistApprovalContent extends StatelessWidget {
  const _WishlistApprovalContent();

  Future<void> _refresh(
    BuildContext context,
  ) async {
    final success = await context
        .read<WishlistApprovalController>()
        .refresh();

    if (!context.mounted || success) {
      return;
    }

    _showMessage(
      context,
      context.l10n.failedToRefreshWishes,
    );
  }

  Future<void> _approveWish(
    BuildContext context, {
    required String wishId,
    required int targetPoints,
  }) async {
    final result = await context
        .read<WishlistApprovalController>()
        .approveWish(
          wishId: wishId,
          targetPoints: targetPoints,
        );

    if (!context.mounted || result.isSuccess) {
      return;
    }

    _showActionError(
      context,
      result,
    );
  }

  Future<void> _rejectWish(
    BuildContext context, {
    required String wishId,
  }) async {
    final result = await context
        .read<WishlistApprovalController>()
        .rejectWish(
          wishId: wishId,
        );

    if (!context.mounted || result.isSuccess) {
      return;
    }

    _showActionError(
      context,
      result,
    );
  }

  void _showActionError(
    BuildContext context,
    WishlistActionResult result,
  ) {
    final message = switch (result.errorCode) {
      WishlistActionErrorCode.approveFailed =>
        context.l10n.failedToApproveWish,
      WishlistActionErrorCode.rejectFailed =>
        context.l10n.failedToRejectWish,
      null => null,
    };

    if (message != null) {
      _showMessage(
        context,
        message,
      );
    }
  }

  void _showMessage(
    BuildContext context,
    String message,
  ) {
    final messenger =
        ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return WishlistApprovalView(
      onRefresh: () => _refresh(context),
      onApprove: ({
        required wishId,
        required targetPoints,
      }) {
        return _approveWish(
          context,
          wishId: wishId,
          targetPoints: targetPoints,
        );
      },
      onReject: ({
        required wishId,
      }) {
        return _rejectWish(
          context,
          wishId: wishId,
        );
      },
    );
  }
}