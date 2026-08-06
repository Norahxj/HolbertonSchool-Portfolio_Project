import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../models/reward_suggestion_model.dart';
import '../controllers/add_reward_controller.dart';
import '../utils/add_reward_localization.dart';
import '../widgets/add_reward_view.dart';

class AddRewardScreen extends StatefulWidget {
  final String childId;
  final RewardSuggestionModel? suggestion;

  const AddRewardScreen({super.key, required this.childId, this.suggestion});

  @override
  State<AddRewardScreen> createState() => _AddRewardScreenState();
}

class _AddRewardScreenState extends State<AddRewardScreen> {
  late final AddRewardController _controller;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _controller = AddRewardController(
      childId: widget.childId,
      suggestion: widget.suggestion,
    );

    final suggestion = widget.suggestion;

    if (suggestion != null) {
      nameController.text = suggestion.rewardName;
      descriptionController.text = suggestion.description;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    nameController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  Future<void> _saveReward() async {
    final result = await _controller.saveReward(
      rewardName: nameController.text,
      description: descriptionController.text,
    );

    if (!mounted) {
      return;
    }

    if (!result.isSuccess) {
      final message =
          result.backendMessage ?? result.errorCode?.localized(context);

      if (message != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }

      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: AddRewardView(
        nameController: nameController,
        descriptionController: descriptionController,
        onSave: _saveReward,
        onBack: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
