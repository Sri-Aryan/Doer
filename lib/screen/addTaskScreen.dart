import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:task/repo/task.dart';
import 'package:task/screen/homeScreen.dart';

import '../provider/taskProvider.dart';

class AddEditTaskScreen extends ConsumerStatefulWidget {
  final Task? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  ConsumerState<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends ConsumerState<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title, _description;
  DateTime _dueDate = DateTime.now();
  Priority _priority = Priority.low;
  String? _selectedPrerequisiteId;
  RecurringType _recurringType = RecurringType.none;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
      _selectedPrerequisiteId = widget.task!.prerequisiteTaskId;
      _recurringType = widget.task!.recurringType;
    } else {
      _title = "";
      _description = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(taskServiceProvider);
    final tasksAsync = ref.watch(tasksStreamProvider);
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Task" : "New Task"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel("Task Details"),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(
                  labelText: "Title",
                  hintText: "What needs to be done?",
                ),
                style: GoogleFonts.poppins(fontSize: 14),
                onSaved: (val) => _title = val ?? "",
                validator: (val) =>
                    val!.isEmpty ? "Please enter a title" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(
                  labelText: "Description",
                  hintText: "Add details (optional)",
                ),
                style: GoogleFonts.poppins(fontSize: 14),
                maxLines: 3,
                onSaved: (val) => _description = val ?? "",
              ),
              const SizedBox(height: 24),

              _sectionLabel("Settings"),
              const SizedBox(height: 12),

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

              DropdownButtonFormField<RecurringType>(
                value: _recurringType,
                decoration: const InputDecoration(labelText: "Recurring"),
                style: GoogleFonts.poppins(
                    fontSize: 14, color: const Color(0xFF0D1B2A)),
                onChanged: (val) => setState(
                    () => _recurringType = val ?? RecurringType.none),
                items: const [
                  DropdownMenuItem(
                      value: RecurringType.none, child: Text("None")),
                  DropdownMenuItem(
                      value: RecurringType.daily, child: Text("Daily")),
                  DropdownMenuItem(
                      value: RecurringType.weekly, child: Text("Weekly")),
                ],
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _dueDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
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
                            fontSize: 14, color: const Color(0xFF5A7184)),
                      ),
                      const Spacer(),
                      Text(
                        "${_dueDate.year}-"
                        "${_dueDate.month.toString().padLeft(2, '0')}-"
                        "${_dueDate.day.toString().padLeft(2, '0')}",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right_rounded,
                          color: Color(0xFF5A7184), size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              tasksAsync.when(
                data: (allTasks) {
                  final otherTasks = allTasks
                      .where((t) => t.id != (widget.task?.id ?? ""))
                      .toList();
                  return DropdownButtonFormField<String?>(
                    value: _selectedPrerequisiteId,
                    decoration: const InputDecoration(
                      labelText: "Must complete first",
                      hintText: "None",
                    ),
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: const Color(0xFF0D1B2A)),
                    onChanged: (val) =>
                        setState(() => _selectedPrerequisiteId = val),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null, child: Text("None")),
                      ...otherTasks.map((t) => DropdownMenuItem<String?>(
                            value: t.id,
                            child: Text(
                              t.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();

                      final task = Task(
                        id: widget.task?.id ?? "",
                        title: _title,
                        description: _description,
                        dueDate: _dueDate,
                        priority: _priority,
                        prerequisiteTaskId: _selectedPrerequisiteId,
                        recurringType: _recurringType,
                      );

                      if (!isEditing) {
                        await service.addTask(task);
                      } else {
                        await service.updateTask(task);
                      }

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    }
                  },
                  child: Text(isEditing ? "Save Changes" : "Add Task"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF2196F3),
        letterSpacing: 1.2,
      ),
    );
  }
}
