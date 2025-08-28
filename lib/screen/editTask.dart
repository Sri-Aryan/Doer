import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      height: MediaQuery.of(context).size.height * 0.8, // 80% height
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            const Text("Edit Task",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            TextFormField(
              initialValue: _title,
              decoration: const InputDecoration(labelText: "Title"),
              onSaved: (val) => _title = val ?? "",
              validator: (val) => val!.isEmpty ? "Enter title" : null,
            ),

            TextFormField(
              initialValue: _description,
              decoration: const InputDecoration(labelText: "Description"),
              onSaved: (val) => _description = val ?? "",
            ),

            const SizedBox(height: 12),

            // Priority dropdown
            DropdownButtonFormField<Priority>(
              value: _priority,
              decoration: const InputDecoration(labelText: "Priority"),
              onChanged: (val) => setState(() => _priority = val!),
              items: Priority.values
                  .map((p) => DropdownMenuItem(
                value: p,
                child: Text(p.name.toUpperCase()),
              ))
                  .toList(),
            ),

            const SizedBox(height: 12),

            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Due Date"),
              subtitle: Text(
                  "${_dueDate.day}/${_dueDate.month}/${_dueDate.year}"),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                );
                if (picked != null) {
                  setState(() => _dueDate = picked);
                }
              },
            ),

            const SizedBox(height: 20),

            ElevatedButton(
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
                  );

                  await service.updateTask(updatedTask);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save Changes",style: TextStyle(color: Colors.blue),),
            )
          ],
        ),
      ),
    );
  }
}
