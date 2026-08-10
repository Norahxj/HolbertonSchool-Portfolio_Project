import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/localization_extension.dart';
import '../controllers/auth_controller.dart';
import '../models/auth_action_result.dart';
import '../widgets/auth_view.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onLanguageToggle;
  final Future<void> Function() onAuthenticated;

  const AuthScreen({
    super.key,
    required this.onLanguageToggle,
    required this.onAuthenticated,
  });

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  late final AuthController _controller;

  bool _isSignInSelected = true;
  String _guardianType = 'mother';

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _familyNameController;
  late final TextEditingController _registerEmailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _registerPasswordController;
  late final TextEditingController _confirmPasswordController;

  String? _loginEmailErrorText;
  String? _loginPasswordErrorText;

  String? _firstNameErrorText;
  String? _familyNameErrorText;
  String? _registerEmailErrorText;
  String? _phoneErrorText;
  String? _registerPasswordErrorText;
  String? _confirmPasswordErrorText;

  @override
  void initState() {
    super.initState();

    _controller = AuthController();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _firstNameController = TextEditingController();
    _familyNameController = TextEditingController();
    _registerEmailController = TextEditingController();
    _phoneController = TextEditingController();
    _registerPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _familyNameController.dispose();
    _registerEmailController.dispose();
    _phoneController.dispose();
    _registerPasswordController.dispose();
    _confirmPasswordController.dispose();

    _controller.dispose();

    super.dispose();
  }

  void _clearErrors() {
    setState(() {
      _loginEmailErrorText = null;
      _loginPasswordErrorText = null;

      _firstNameErrorText = null;
      _familyNameErrorText = null;
      _registerEmailErrorText = null;
      _phoneErrorText = null;
      _registerPasswordErrorText = null;
      _confirmPasswordErrorText = null;
    });
  }

  Future<void> _submit() async {
    _clearErrors();

    if (_isSignInSelected) {
      await _login();
      return;
    }

    await _register();
  }

  Future<void> _login() async {
    final result = await _controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _applyLoginError(result);
      return;
    }

    _showMessage(
      context.l10n.authLoginSuccess,
    );

    await widget.onAuthenticated();
  }

  void _applyLoginError(AuthActionResult result) {
    if (result.fieldErrors.isNotEmpty) {
      setState(() {
        _loginEmailErrorText =
            result.fieldErrors['email'];

        _loginPasswordErrorText =
            result.fieldErrors['password'];
      });

      return;
    }

    _showMessage(
      result.backendMessage ??
          context.l10n.authServerError,
    );
  }

  Future<void> _register() async {
    if (_registerPasswordController.text !=
        _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordErrorText =
            context.l10n.authPasswordsDoNotMatch;
      });

      return;
    }

    final result = await _controller.register(
      firstName: _firstNameController.text.trim(),
      lastName: _familyNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _registerEmailController.text.trim(),
      password: _registerPasswordController.text,
      guardianType: _guardianType,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _applyRegisterError(result);
      return;
    }

    _clearRegisterFields();

    _showMessage(
      context.l10n.authAccountCreatedSuccess,
    );

    await widget.onAuthenticated();
  }

  void _applyRegisterError(
    AuthActionResult result,
  ) {
    if (result.fieldErrors.isNotEmpty) {
      setState(() {
        _firstNameErrorText =
            result.fieldErrors['first_name'];

        _familyNameErrorText =
            result.fieldErrors['last_name'];

        _registerEmailErrorText =
            result.fieldErrors['email'];

        _phoneErrorText =
            result.fieldErrors['phone'];

        _registerPasswordErrorText =
            result.fieldErrors['password'];
      });

      return;
    }

    final backendMessage = result.backendMessage;

    if (backendMessage == 'Email already registered') {
      setState(() {
        _registerEmailErrorText =
            context.l10n.authEmailAlreadyRegistered;
      });

      return;
    }

    if (backendMessage == 'Phone number already used') {
      setState(() {
        _phoneErrorText =
            context.l10n.authPhoneAlreadyUsed;
      });

      return;
    }

    if (backendMessage ==
        'Email or phone number already registered') {
      final message =
          context.l10n.authEmailOrPhoneAlreadyRegistered;

      setState(() {
        _registerEmailErrorText = message;
        _phoneErrorText = message;
      });

      return;
    }

    _showMessage(
      backendMessage ??
          context.l10n.authServerError,
    );
  }

  void _clearRegisterFields() {
    _firstNameController.clear();
    _familyNameController.clear();
    _registerEmailController.clear();
    _phoneController.clear();
    _registerPasswordController.clear();
    _confirmPasswordController.clear();
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

  void _showRegister() {
    _clearErrors();

    setState(() {
      _isSignInSelected = false;
    });
  }

  void _changeGuardianType(String type) {
    setState(() {
      _guardianType = type;
    });
  }

  void _handleBack() {
    if (_isSignInSelected) {
      Navigator.pop(context);
      return;
    }

    _clearErrors();

    setState(() {
      _isSignInSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: AuthView(
        isSignInSelected: _isSignInSelected,
        guardianType: _guardianType,

        emailController: _emailController,
        passwordController: _passwordController,
        firstNameController: _firstNameController,
        familyNameController: _familyNameController,
        registerEmailController:
            _registerEmailController,
        phoneController: _phoneController,
        registerPasswordController:
            _registerPasswordController,
        confirmPasswordController:
            _confirmPasswordController,

        loginEmailErrorText:
            _loginEmailErrorText,
        loginPasswordErrorText:
            _loginPasswordErrorText,

        firstNameErrorText:
            _firstNameErrorText,
        familyNameErrorText:
            _familyNameErrorText,
        registerEmailErrorText:
            _registerEmailErrorText,
        phoneErrorText:
            _phoneErrorText,
        registerPasswordErrorText:
            _registerPasswordErrorText,
        confirmPasswordErrorText:
            _confirmPasswordErrorText,

        onBack: _handleBack,
        onLanguageToggle:
            widget.onLanguageToggle,
        onCreateAccount: _showRegister,
        onGuardianTypeChanged:
            _changeGuardianType,
        onSubmit: _submit,
      ),
    );
  }
}