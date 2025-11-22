import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/task/task_bloc.dart';
import '../../logic/task/task_event.dart';
import '../widgets/app_button.dart';
import '../widgets/input_field.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);

    context.read<TaskBloc>().add(
      CreateTaskEvent(
        titleCtrl.text.trim(),
        descCtrl.text.trim(),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Task"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                InputField(
                  controller: titleCtrl,
                  label: "Title",
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Title is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                InputField(
                  controller: descCtrl,
                  label: "Description (optional)",
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: "Save Task",
                  onPressed: _onSave,
                  loading: _submitting,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
