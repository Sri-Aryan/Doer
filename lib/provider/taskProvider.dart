import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task/repo/task.dart';
import 'package:task/repo/taskService.dart';

final taskServiceProvider = Provider((ref) => TaskService());

// User-selected
final priorityFilterProvider = StateProvider<Priority?>((ref) => null);
final statusFilterProvider = StateProvider<String?>((ref) => null); // "completed" / "incomplete" / null
final searchQueryProvider = StateProvider<String>((ref) => "");

//  Stream
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final service = ref.watch(taskServiceProvider);
  final priorityFilter = ref.watch(priorityFilterProvider);
  final statusFilter = ref.watch(statusFilterProvider);

  return service.getTasks().map((tasks) {
    var filtered = tasks;

    // Filter by priority
    if (priorityFilter != null) {
      filtered = filtered.where((t) => t.priority == priorityFilter).toList();
    }

    // Filter by status
    if (statusFilter == "completed") {
      filtered = filtered.where((t) => t.isCompleted).toList();
    } else if (statusFilter == "incomplete") {
      filtered = filtered.where((t) => !t.isCompleted).toList();
    }

    // Sort by custom sortOrder if any task has one set, else by due date
    final hasCustomOrder = filtered.any((t) => t.sortOrder != null);
    if (hasCustomOrder) {
      filtered.sort((a, b) {
        if (a.sortOrder != null && b.sortOrder != null) {
          return a.sortOrder!.compareTo(b.sortOrder!);
        }
        if (a.sortOrder != null) return -1;
        if (b.sortOrder != null) return 1;
        return a.dueDate.compareTo(b.dueDate);
      });
    } else {
      filtered.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    }

    return filtered;
  });
});
