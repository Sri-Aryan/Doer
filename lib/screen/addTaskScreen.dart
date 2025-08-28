import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
    } else {
      _title = "";
      _description = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.read(taskServiceProvider);

    return Scaffold(
//      backgroundColor: Colors.lightBlue,
      appBar: AppBar(backgroundColor: Colors.lightBlue,title: Text(widget.task == null ? "Add Task" : "Edit Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
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
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  final task = Task(
                    id: widget.task?.id ?? "",
                    title: _title,
                    description: _description,
                    dueDate: _dueDate,
                    priority: _priority,
                  );

                  if (widget.task == null) {
                    await service.addTask(task);
                  } else {
                    await service.updateTask(task);
                  }
                  //Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false, // removes all previous routes
                  );
                }
              },
              child: Text(widget.task == null ? "Add" : "Update",style: TextStyle(color: Colors.blue),),
            )
          ]),
        ),
      ),
    );
  }
}
