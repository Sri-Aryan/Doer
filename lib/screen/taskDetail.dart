import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task/repo/task.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

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

  Color _priorityBg(Priority p) {
    switch (p) {
      case Priority.high:
        return const Color(0xFFFFEDED);
      case Priority.medium:
        return const Color(0xFFFFF8E1);
      case Priority.low:
        return const Color(0xFFE8F5E9);
    }
  }

  @override
  Widget build(BuildContext context) {
    final priorityColor = _priorityColor(task.priority);
    final priorityBg = _priorityBg(task.priority);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: const Text("Task Details"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFDCEEFD)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2196F3).withOpacity(0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D1B2A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: task.isCompleted
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFF8E1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            task.isCompleted ? "Completed" : "Pending",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  const Divider(color: Color(0xFFEEF3FF), height: 1),
                  const SizedBox(height: 16),

                  _DetailRow(
                    icon: Icons.notes_rounded,
                    label: "Description",
                    value: task.description.isEmpty
                        ? "No description"
                        : task.description,
                    valueColor: task.description.isEmpty
                        ? const Color(0xFF9AA5B4)
                        : const Color(0xFF3D5A80),
                  ),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: "Due Date",
                    value:
                        "${task.dueDate.day} / ${task.dueDate.month} / ${task.dueDate.year}",
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.flag_outlined,
                            size: 18, color: Color(0xFF5A7184)),
                        const SizedBox(width: 12),
                        Text(
                          "Priority",
                          style: GoogleFonts.poppins(
                              fontSize: 13, color: const Color(0xFF5A7184)),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: priorityBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            task.priority.name.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: priorityColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (task.recurringType != RecurringType.none)
                    _DetailRow(
                      icon: Icons.repeat_rounded,
                      label: "Recurring",
                      value: task.recurringType == RecurringType.daily
                          ? "Daily"
                          : "Weekly",
                      valueColor: const Color(0xFF2196F3),
                    ),

                  if (task.prerequisiteTaskId != null)
                    _DetailRow(
                      icon: Icons.lock_clock_outlined,
                      label: "Has Prerequisite",
                      value: "Yes",
                    ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF2196F3), width: 1.5),
                  foregroundColor: const Color(0xFF2196F3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  textStyle: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF5A7184)),
          const SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(
                fontSize: 13, color: const Color(0xFF5A7184)),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: valueColor ?? const Color(0xFF0D1B2A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
