import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task/repo/task.dart';

import '../provider/taskProvider.dart';

class EditTaskBottomSheet extends ConsumerStatefulWidget {
  final Task task;
  const EditTaskBottomSheet({super.key, required this.task});

  @override
  ConsumerState<EditTaskBottomSheet> createState() =>
      _EditTaskBottomSheetState();
}

class _EditTaskBottomSheetState extends ConsumerState<EditTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late String _title, _description;
  late DateTime _dueDate;
  late Priority _priority;

  @override
  void initState() {
    super.initState();
    _title = widget.task.title;
    _description = widget.task.description;
    _dueDate = widget.task.dueDate;
    _priority = widget.task.priority;
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(taskServiceProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  "Edit Task",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D1B2A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  TextFormField(
                    initialValue: _title,
                    decoration: const InputDecoration(labelText: "Title"),
                    style: GoogleFonts.poppins(fontSize: 14),
                    onSaved: (val) => _title = val ?? "",
                    validator: (val) =>
                        val!.isEmpty ? "Enter title" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    initialValue: _description,
                    decoration:
                        const InputDecoration(labelText: "Description"),
                    style: GoogleFonts.poppins(fontSize: 14),
                    maxLines: 3,
                    onSaved: (val) => _description = val ?? "",
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<Priority>(
                    value: _priority,
                    decoration: const InputDecoration(labelText: "Priority"),
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: const Color(0xFF0D1B2A)),
                    onChanged: (val) => setState(() => _priority = val!),
                    items: Priority.values
                        .map((p) => DropdownMenuItem(
                              value: p,
                              child: Text(p.name.toUpperCase()),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),

                  // Due date picker
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate,
                        firstDate: DateTime.now()
                            .subtract(const Duration(days: 365)),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365 * 5)),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFDCEEFD)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              color: Color(0xFF2196F3), size: 18),
                          const SizedBox(width: 12),
                          Text(
                            "Due Date",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: const Color(0xFF5A7184)),
                          ),
                          const Spacer(),
                          Text(
                            "${_dueDate.day}/${_dueDate.month}/${_dueDate.year}",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF0D1B2A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          final updatedTask = Task(
                            id: widget.task.id,
                            title: _title,
                            description: _description,
                            dueDate: _dueDate,
                            priority: _priority,
                            isCompleted: widget.task.isCompleted,
                            prerequisiteTaskId:
                                widget.task.prerequisiteTaskId,
                            recurringType: widget.task.recurringType,
                            sortOrder: widget.task.sortOrder,
                          );
                          await service.updateTask(updatedTask);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Save Changes"),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
