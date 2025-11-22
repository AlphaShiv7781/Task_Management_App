import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskEvent {
  final int page;
  final int limit;
  final String? search;
  final String status;

  LoadTasksEvent({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.status = "all",
  });
}

class LoadMoreTasksEvent extends TaskEvent {}

class RefreshTasksEvent extends TaskEvent {}

class SearchTasksEvent extends TaskEvent {
  final String query;
  SearchTasksEvent(this.query);
}

class FilterTasksEvent extends TaskEvent {
  final String status;
  FilterTasksEvent(this.status);
}

class ToggleTaskStatusEvent extends TaskEvent {
  final int id;
  ToggleTaskStatusEvent(this.id);
}

class DeleteTaskEvent extends TaskEvent {
  final int id;
  DeleteTaskEvent(this.id);
}

class UpdateTaskEvent extends TaskEvent {
  final int id;
  final String title;
  final String description;
  UpdateTaskEvent(this.id, this.title, this.description);
}

class CreateTaskEvent extends TaskEvent {
  final String title;
  final String description;
  CreateTaskEvent(this.title, this.description);
}
