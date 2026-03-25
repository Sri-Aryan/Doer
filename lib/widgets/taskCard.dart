import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task/repo/task.dart';
import 'package:task/screen/taskDetail.dart';
import 'package:task/screen/editTask.dart';

import '../provider/taskProvider.dart';

class TaskCard extends ConsumerWidget {
  final Task task;
  final String searchQuery;

  const TaskCard({super.key, required this.task, this.searchQuery = ""});

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.high:
        return const Color(0xFFEF4444);
      case Priority.medium:
        return const Color(0xFFF59E0B);
      case Priority.low:
        return const Color(0xFF10B981);
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Widget _highlightedText(String text, String query, TextStyle baseStyle) {
    if (query.isEmpty) return Text(text, style: baseStyle);

    final lower = text.toLowerCase();
    final lowerQ = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(lowerQ, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: baseStyle));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: baseStyle.copyWith(
          backgroundColor: const Color(0xFFFFF176),
          fontWeight: FontWeight.w700,
        ),
      ));
      start = idx + query.length;
    }
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverdue =
        !task.isCompleted && task.dueDate.isBefore(DateTime.now());
    final taskService = ref.watch(taskServiceProvider);
    final priorityColor = _priorityColor(task.priority);

    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCEEFD)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2196F3).withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left priority strip
              Container(
                width: 4,
                color: task.isCompleted
                    ? Colors.grey[300]
                    : priorityColor,
              ),

              // Content
              Expanded(
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => TaskDetailScreen(task: task)),
                  ),
                  child: Opacity(
                    opacity: task.isCompleted ? 0.45 : 1.0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _highlightedText(
                                  task.title,
                                  searchQuery,
                                  GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF0D1B2A),
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),
                              // Checkbox
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: task.isCompleted,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  onChanged: (value) async {
                                    if ((value ?? false) &&
                                        task.prerequisiteTaskId != null) {
                                      final allTasks =
                                          ref.read(tasksStreamProvider).value ??
                                              [];
                                      final prereq = allTasks
                                          .where((t) =>
                                              t.id == task.prerequisiteTaskId)
                                          .firstOrNull;
                                      if (prereq != null &&
                                          !prereq.isCompleted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'Complete "${prereq.title}" first'),
                                          ),
                                        );
                                        return;
                                      }
                                    }

                                    if ((value ?? false) &&
                                        task.recurringType !=
                                            RecurringType.none) {
                                      // Single batch: marks done + creates
                                      // next occurrence atomically.
                                      await taskService.markComplete(task);
                                    } else {
                                      await taskService.updateTask(
                                        task.copyWith(
                                            isCompleted: value ?? false),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),

                          // Description
                          if (task.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              task.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF5A7184),
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),

                          // Bottom row: due date + badges + actions
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 12,
                                color: isOverdue
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF5A7184),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatDate(task.dueDate),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: isOverdue
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF5A7184),
                                  fontWeight: isOverdue
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),

                              // Recurring pill
                              if (task.recurringType != RecurringType.none) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.repeat_rounded,
                                          size: 10,
                                          color: Color(0xFF2196F3)),
                                      const SizedBox(width: 3),
                                      Text(
                                        task.recurringType ==
                                                RecurringType.daily
                                            ? "Daily"
                                            : "Weekly",
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: const Color(0xFF2196F3),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const Spacer(),

                              // Edit button
                              _CardIconButton(
                                icon: Icons.edit_outlined,
                                color: const Color(0xFF2196F3),
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(24)),
                                    ),
                                    builder: (_) =>
                                        EditTaskBottomSheet(task: task),
                                  );
                                },
                              ),

                              // Delete button
                              _CardIconButton(
                                icon: Icons.delete_outline_rounded,
                                color: const Color(0xFFEF4444),
                                onTap: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      title: Text("Delete task?",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600)),
                                      content: Text(
                                          "\"${task.title}\" will be permanently deleted.",
                                          style: GoogleFonts.poppins(
                                              fontSize: 14)),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFFEF4444),
                                            minimumSize: Size.zero,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 20, vertical: 10),
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text("Delete"),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirmed == true) {
                                    await taskService.deleteTask(task.id);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Hero(tag: task.id, child: card);
  }
}

class _CardIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CardIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
