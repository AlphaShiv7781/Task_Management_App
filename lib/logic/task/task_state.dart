import 'package:equatable/equatable.dart';
import '../../data/models/task_model.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskModel> tasks;
  final int total;
  final int page;
  final bool hasMore;

  TaskLoaded({
    required this.tasks,
    required this.total,
    required this.page,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [tasks, total, page, hasMore];
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);
}

class TaskEmpty extends TaskState {}
