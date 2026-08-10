import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/localization_extension.dart';
import '../../widgets/child_nav.dart';
import '../controllers/child_pin_login_controller.dart';
import '../models/child_pin_login_result.dart';
import '../widgets/child_pin_login_view.dart';

class ChildPinLoginScreen
    extends StatefulWidget {
  final VoidCallback onLanguageToggle;

  const ChildPinLoginScreen({
    super.key,
    required this.onLanguageToggle,
  });

  @override
  State<ChildPinLoginScreen>
      createState() {
    return _ChildPinLoginScreenState();
  }
}

class _ChildPinLoginScreenState
    extends State<ChildPinLoginScreen> {
  late final ChildPinLoginController
      _controller;

  late final TextEditingController
      _pinController;

  late final FocusNode _pinFocusNode;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _controller =
        ChildPinLoginController();

    _pinController =
        TextEditingController();

    _pinFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    _controller.dispose();

    super.dispose();
  }

  Future<void> _loginChild() async {
    setState(() {
      _errorMessage = null;
    });

    final result =
        await _controller.login();

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      setState(() {
        _errorMessage =
            _errorText(result);
      });

      return;
    }

    Navigator.pushReplacement<void, void>(
      context,
      MaterialPageRoute(
        builder: (_) {
          return ChildNav(
            onLanguageToggle:
                widget.onLanguageToggle,
          );
        },
      ),
    );
  }

  String _errorText(
    ChildPinLoginResult result,
  ) {
    if (result.backendMessage != null &&
        result.backendMessage!.isNotEmpty) {
      return result.backendMessage!;
    }

    switch (result.errorCode) {
      case ChildPinLoginErrorCode
            .incompleteCode:
        return context
            .l10n
            .childPinIncompleteCode;

      case ChildPinLoginErrorCode
            .invalidCode:
        return context
            .l10n
            .childPinInvalidCode;

      case ChildPinLoginErrorCode
            .loginFailed:
      case null:
        return context
            .l10n
            .childPinLoginFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: ChildPinLoginView(
        pinController:
            _pinController,
        pinFocusNode:
            _pinFocusNode,
        onLanguageToggle:
            widget.onLanguageToggle,
        onLogin: _loginChild,
        errorMessage:
            _errorMessage,
      ),
    );
  }
}