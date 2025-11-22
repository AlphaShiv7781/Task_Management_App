import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task_model.dart';
import '../../logic/task/task_bloc.dart';
import '../../logic/task/task_event.dart';
import '../../logic/task/task_state.dart';
import 'add_task_screen.dart';
import 'edit_task_screen.dart';
import 'login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  String _currentStatusFilter = "all"; // all | pending | completed

  @override
  void initState() {
    super.initState();
    // Load first page
    context.read<TaskBloc>().add(
      LoadTasksEvent(page: 1, limit: 10),
    );

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;

    if (current >= maxScroll - 150) {
      context.read<TaskBloc>().add(LoadMoreTasksEvent());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("accessToken");
    await prefs.remove("refreshToken");

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void _onSearchSubmit(String value) {
    context.read<TaskBloc>().add(SearchTasksEvent(value.trim()));
  }

  void _onStatusFilterChange(String status) {
    setState(() {
      _currentStatusFilter = status;
    });
    context.read<TaskBloc>().add(FilterTasksEvent(status));
  }

  Color _statusColor(String status) {
    switch (status) {
      case "completed":
        return Colors.green.shade600;
      case "pending":
      default:
        return Colors.orange.shade700;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case "completed":
        return Icons.check_circle;
      case "pending":
      default:
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchCtrl,
                onSubmitted: _onSearchSubmit,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchCtrl.clear();
                      _onSearchSubmit("");
                    },
                  )
                      : null,
                ),
              ),
            ),
            // Filter chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text("All"),
                    selected: _currentStatusFilter == "all",
                    onSelected: (_) => _onStatusFilterChange("all"),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Pending"),
                    selected: _currentStatusFilter == "pending",
                    onSelected: (_) => _onStatusFilterChange("pending"),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text("Completed"),
                    selected: _currentStatusFilter == "completed",
                    onSelected: (_) => _onStatusFilterChange("completed"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<TaskBloc>().add(RefreshTasksEvent());
                },
                child: BlocBuilder<TaskBloc, TaskState>(
                  builder: (context, state) {
                    if (state is TaskLoading || state is TaskInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is TaskError) {
                      return Center(
                        child: Text(state.message),
                      );
                    }

                    if (state is TaskEmpty) {
                      return const Center(
                        child: Text("No tasks yet. Add your first task!"),
                      );
                    }

                    if (state is TaskLoaded) {
                      final tasks = state.tasks;

                      if (tasks.isEmpty) {
                        return const Center(
                          child: Text("No tasks found."),
                        );
                      }

                      return ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount:
                        state.hasMore ? tasks.length + 1 : tasks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          if (index >= tasks.length) {
                            // Loader at bottom for pagination
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            );
                          }

                          final task = tasks[index];

                          return _buildTaskCard(context, task, primaryBlue);
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTaskScreen()),
          );
          if (!mounted) return;
          context.read<TaskBloc>().add(RefreshTasksEvent());
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
      ),
    );
  }

  Widget _buildTaskCard(
      BuildContext context, TaskModel task, Color primaryBlue) {
    final isCompleted = task.status == "completed";

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EditTaskScreen(task: task),
          ),
        );

        if (result == true && mounted) {
          context.read<TaskBloc>().add(RefreshTasksEvent());
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  context
                      .read<TaskBloc>()
                      .add(ToggleTaskStatusEvent(task.id));
                },
                icon: Icon(
                  _statusIcon(task.status),
                  color: _statusColor(task.status),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (task.description != null &&
                        task.description!.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      task.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        color: _statusColor(task.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
