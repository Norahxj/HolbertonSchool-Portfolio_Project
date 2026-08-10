import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/localization_extension.dart';
import '../controllers/add_wishlist_controller.dart';
import '../models/wishlist_action_result.dart';
import '../widgets/add_wishlist_view.dart';

class AddWishlistScreen extends StatefulWidget {
  const AddWishlistScreen({
    super.key,
  });

  @override
  State<AddWishlistScreen> createState() {
    return _AddWishlistScreenState();
  }
}

class _AddWishlistScreenState extends State<AddWishlistScreen> {
  late final AddWishlistController _controller;
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();

    _controller = AddWishlistController()
      ..loadCurrentWishes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();

    final result = await _controller.createWish(name);

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showActionError(result);
      return;
    }

    Navigator.pop(context, true);
  }

  void _showActionError(
    WishlistActionResult result,
  ) {
    final message =
        result.backendMessage ??
        _localizedError(result.errorCode) ??
        context.l10n.createWishFailed;

    _showMessage(message);
  }

  String? _localizedError(
    WishlistErrorCode? errorCode,
  ) {
    switch (errorCode) {
      case WishlistErrorCode.loadFailed:
        return context.l10n.childWishlistLoadFailed;

      case WishlistErrorCode.createFailed:
        return context.l10n.createWishFailed;

      case WishlistErrorCode.wishlistLimitReached:
        return context.l10n.wishlistLimitReached;

      case WishlistErrorCode.nameTooShort:
        return context.l10n.wishNameTooShort;

      case WishlistErrorCode.nameTooLong:
        return context.l10n.wishNameTooLong;

      case WishlistErrorCode.deleteFailed:
      case WishlistErrorCode.achieveFailed:
      case null:
        return null;
    }
  }

  void _showMessage(String message) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: AddWishlistView(
        nameController: _nameController,
        onBack: _goBack,
        onSubmit: _submit,
      ),
    );
  }
}