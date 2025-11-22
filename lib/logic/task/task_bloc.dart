import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  int currentPage = 1;
  String currentSearch = "";
  String currentStatus = "all";
  bool isLoadingMore = false;

  List<TaskModel> loadedTasks = [];

  TaskBloc(this.repository) : super(TaskInitial()) {
    // Load tasks
    on<LoadTasksEvent>(_loadTasks);

    // Load more pages
    on<LoadMoreTasksEvent>(_loadMore);

    // Refresh
    on<RefreshTasksEvent>(_refresh);

    // Search
    on<SearchTasksEvent>(_search);

    // Filter
    on<FilterTasksEvent>(_filter);

    // Create
    on<CreateTaskEvent>(_create);

    // Update
    on<UpdateTaskEvent>(_update);

    // Delete
    on<DeleteTaskEvent>(_delete);

    // Toggle status
    on<ToggleTaskStatusEvent>(_toggleStatus);
  }

  // -----------------------------------------
  // 1) Load tasks (main)
  // -----------------------------------------
  Future<void> _loadTasks(
      LoadTasksEvent event,
      Emitter<TaskState> emit,
      ) async {
    emit(TaskLoading());

    currentPage = event.page;
    currentSearch = event.search ?? "";
    currentStatus = event.status;

    try {
      final result = await repository.fetchTasks(
        page: currentPage,
        limit: event.limit,
        search: currentSearch,
        status: currentStatus,
      );

      loadedTasks = result["tasks"];

      emit(TaskLoaded(
        tasks: loadedTasks,
        total: result["total"],
        page: result["page"],
        hasMore: loadedTasks.length < result["total"],
      ));
    } catch (e) {
      emit(TaskError("Failed to load tasks"));
    }
  }

  // -----------------------------------------
  // 2) Load more
  // -----------------------------------------
  Future<void> _loadMore(
      LoadMoreTasksEvent event,
      Emitter<TaskState> emit,
      ) async {
    if (state is! TaskLoaded || isLoadingMore) return;

    isLoadingMore = true;
    currentPage++;

    try {
      final result = await repository.fetchTasks(
        page: currentPage,
        limit: 10,
        search: currentSearch,
        status: currentStatus,
      );

      final newTasks = result["tasks"];

      loadedTasks.addAll(newTasks);

      emit(TaskLoaded(
        tasks: loadedTasks,
        total: result["total"],
        page: currentPage,
        hasMore: loadedTasks.length < result["total"],
      ));
    } catch (_) {
      // Don't break UI on pagination errors
    }

    isLoadingMore = false;
  }

  // -----------------------------------------
  // 3) Refresh
  // -----------------------------------------
  Future<void> _refresh(
      RefreshTasksEvent event,
      Emitter<TaskState> emit,
      ) async {
    add(LoadTasksEvent(
      page: 1,
      limit: 10,
      search: currentSearch,
      status: currentStatus,
    ));
  }

  // -----------------------------------------
  // 4) Search
  // -----------------------------------------
  Future<void> _search(
      SearchTasksEvent event,
      Emitter<TaskState> emit,
      ) async {
    currentSearch = event.query;
    add(LoadTasksEvent(
      page: 1,
      limit: 10,
      search: event.query,
      status: currentStatus,
    ));
  }

  // -----------------------------------------
  // 5) Filter
  // -----------------------------------------
  Future<void> _filter(
      FilterTasksEvent event,
      Emitter<TaskState> emit,
      ) async {
    currentStatus = event.status;
    add(LoadTasksEvent(
      page: 1,
      limit: 10,
      search: currentSearch,
      status: currentStatus,
    ));
  }

  // -----------------------------------------
  // 6) Create
  // -----------------------------------------
  Future<void> _create(
      CreateTaskEvent event,
      Emitter<TaskState> emit,
      ) async {
    await repository.createTask(event.title, event.description);
    add(RefreshTasksEvent());
  }

  // -----------------------------------------
  // 7) Update
  // -----------------------------------------
  Future<void> _update(
      UpdateTaskEvent event,
      Emitter<TaskState> emit,
      ) async {
    await repository.updateTask(event.id, event.title, event.description);
    add(RefreshTasksEvent());
  }

  // -----------------------------------------
  // 8) Delete
  // -----------------------------------------
  Future<void> _delete(
      DeleteTaskEvent event,
      Emitter<TaskState> emit,
      ) async {
    await repository.deleteTask(event.id);
    add(RefreshTasksEvent());
  }

  // -----------------------------------------
  // 9) Toggle Status
  // -----------------------------------------
  Future<void> _toggleStatus(
      ToggleTaskStatusEvent event,
      Emitter<TaskState> emit,
      ) async {
    await repository.toggleTask(event.id);
    add(RefreshTasksEvent());
  }
}
