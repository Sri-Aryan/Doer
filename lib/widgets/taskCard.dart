import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task/repo/task.dart';
import 'package:task/screen/taskDetail.dart';
import 'package:task/screen/editTask.dart';

import '../provider/taskProvider.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  Color getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.redAccent;
      case Priority.medium:
        return Colors.orangeAccent;
      case Priority.low:
        return Colors.greenAccent;
    }
  }

  String formatDate(DateTime date) {
    return date.toLocal().toString().split(' ')[0]; // yyyy-MM-dd
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue =
        !task.isCompleted && task.dueDate.isBefore(DateTime.now());

    final taskService = ref.watch(taskServiceProvider);

    return Hero(
      tag: task.id,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                );
              },
              child: Row(

                children: [

                  // Task details
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: task.isCompleted
                                  ? Colors.grey
                                  : Colors.black87,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Description
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: task.isCompleted
                                  ? Colors.grey
                                  : Colors.black54,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Due date
                          Text(
                            "Due: ${formatDate(task.dueDate)}",
                            style: TextStyle(
                              fontSize: 14,
                              color: isOverdue
                                  ? Colors.red
                                  : Colors.grey[700],
                              fontWeight: isOverdue
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "${task.priority.name.toUpperCase()}",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: getPriorityColor(task.priority),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                        ),
                                        builder: (_) =>
                                            EditTaskBottomSheet(task: task),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.blue),
                                    onPressed: () async {
                                      await taskService.deleteTask(task.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Task deleted"),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 4),

                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: Checkbox(
                value: task.isCompleted,
                onChanged: (value) async {
                  await taskService.updateTask(
                    task.copyWith(isCompleted: value ?? false),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
