import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/localization_extension.dart';
import '../controllers/child_wishlist_controller.dart';
import '../models/wishlist_action_result.dart';
import '../widgets/child_wishlist_view.dart';
import 'add_wishlist_screen.dart';

class ChildWishlistScreen extends StatefulWidget {
  const ChildWishlistScreen({
    super.key,
  });

  @override
  State<ChildWishlistScreen> createState() {
    return _ChildWishlistScreenState();
  }
}

class _ChildWishlistScreenState extends State<ChildWishlistScreen> {
  late final ChildWishlistController _controller;

  @override
  void initState() {
    super.initState();

    _controller = ChildWishlistController()
      ..loadWishlist();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _openAddWish() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return const AddWishlistScreen();
        },
      ),
    );

    if (!mounted || created != true) {
      return;
    }

    await _controller.loadWishlist();
  }

  Future<void> _confirmDeleteWish(
    String wishId,
    String wishName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            context.l10n.deleteWishTitle,
          ),
          content: Text(
            context.l10n.deleteWishConfirmation(
              wishName,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                context.l10n.cancel,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: Text(
                context.l10n.delete,
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final result =
        await _controller.deleteWish(wishId);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showActionError(
        result,
        context.l10n.deleteWishFailed,
      );
      return;
    }

    _showMessage(
      context.l10n.deleteWishSuccess,
    );
  }

  Future<void> _achieveWish(
    String wishId,
  ) async {
    final result =
        await _controller.achieveWish(wishId);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showActionError(
        result,
        context.l10n.achieveWishFailed,
      );
      return;
    }

    _showMessage(
      context.l10n.achieveWishSuccess,
    );
  }

  void _showActionError(
    WishlistActionResult result,
    String fallbackMessage,
  ) {
    final message =
        result.backendMessage ??
        fallbackMessage;

    _showMessage(message);
  }

  void _showMessage(String message) {
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

  Future<void> _refresh() async {
    await _controller.loadWishlist();
  }

  Future<void> _retry() async {
    await _controller.loadWishlist();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ChildWishlistView(
        onAddWish: _openAddWish,
        onRetry: _retry,
        onRefresh: _refresh,
        onDeleteWish: _confirmDeleteWish,
        onAchieveWish: _achieveWish,
      ),
    );
  }
}