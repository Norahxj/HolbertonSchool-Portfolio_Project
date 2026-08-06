import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/reward_suggestion_model.dart';
import '../controllers/add_reward_controller.dart';
import '../models/add_reward_result.dart';
import '../utils/add_reward_localization.dart';
import '../widgets/add_reward_view.dart';

class AddRewardScreen extends StatefulWidget {
  final String childId;
  final RewardSuggestionModel? suggestion;

  const AddRewardScreen({super.key, required this.childId, this.suggestion});

  @override
  State<AddRewardScreen> createState() {
    return _AddRewardScreenState();
  }
}

class _AddRewardScreenState extends State<AddRewardScreen> {
  late final AddRewardController _controller;

  late final TextEditingController _nameController;

  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();

    _controller = AddRewardController(
      childId: widget.childId,
      suggestion: widget.suggestion,
    );

    _nameController = TextEditingController(
      text: widget.suggestion?.rewardName ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.suggestion?.description ?? '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _saveReward() async {
    FocusScope.of(context).unfocus();

    final result = await _controller.saveReward(
      rewardName: _nameController.text,
      description: _descriptionController.text,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      _showSaveError(result);
      return;
    }

    Navigator.pop(context, true);
  }

  void _showSaveError(AddRewardResult result) {
    final message =
        result.backendMessage ?? result.errorCode?.localized(context);

    if (message == null || message.isEmpty) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: AddRewardView(
        nameController: _nameController,
        descriptionController: _descriptionController,
        onSave: _saveReward,
        onBack: _goBack,
      ),
    );
  }
}
