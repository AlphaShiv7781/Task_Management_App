import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task_model.dart';
import '../../logic/task/task_bloc.dart';
import '../../logic/task/task_event.dart';
import '../widgets/app_button.dart';
import '../widgets/input_field.dart';

class EditTaskScreen extends StatefulWidget {
  final TaskModel task;

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;

  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.task.title);
    descCtrl = TextEditingController(text: widget.task.description ?? "");
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  void _onSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    context.read<TaskBloc>().add(
      UpdateTaskEvent(
        widget.task.id,
        titleCtrl.text.trim(),
        descCtrl.text.trim(),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  void _onDelete() async {
    setState(() => _deleting = true);

    context.read<TaskBloc>().add(
      DeleteTaskEvent(widget.task.id),
    );

    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() => _deleting = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.task.status == "completed";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Task"),
        actions: [
          IconButton(
            onPressed: _deleting ? null : _onDelete,
            icon: _deleting
                ? const SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Icon(Icons.delete_outline),
          ),
        ],
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("Status: "),
                    const SizedBox(width: 8),
                    Chip(
                      label: Text(
                        isCompleted ? "COMPLETED" : "PENDING",
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                AppButton(
                  label: "Save Changes",
                  onPressed: _onSave,
                  loading: _saving,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
