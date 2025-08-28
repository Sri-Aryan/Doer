import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/taskProvider.dart';
import 'addTaskScreen.dart';
import '../repo/task.dart';
import '../widgets/taskCard.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Tasks",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list,color: Colors.black,),
            onPressed: () => _showFilterDialog(context, ref),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.lightBlueAccent, // top color
              Colors.white,           // bottom color
            ],
          ),
        ),
        child: Column(
          children: [

            Container(
              decoration: const BoxDecoration(
                color: Colors.lightBlue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // search box inside white
                  hintText: "Search tasks...",
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none, // remove default border
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16,
                  ),
                ),
                onChanged: (query) {
                  ref.read(searchQueryProvider.notifier).state = query;
                },
              ),
            ),

            Expanded(
              child: tasksAsync.when(
                data: (tasks) {
                  final query = ref.watch(searchQueryProvider).toLowerCase();

                  final filteredTasks = tasks.where((task) {
                    final title = task.title.toLowerCase();
                    return title.contains(query);
                  }).toList();

                  if (filteredTasks.isEmpty) {
                    return const Center(child: Text("No tasks found"));
                  }

                  final today = DateTime.now();
                  final todaysTasks = filteredTasks.where((task) {
                    final due = task.dueDate;
                    return due.year == today.year &&
                        due.month == today.month &&
                        due.day == today.day;
                  }).toList();

                  final otherTasks = filteredTasks.where((task) {
                    final due = task.dueDate;
                    return !(due.year == today.year &&
                        due.month == today.month &&
                        due.day == today.day);
                  }).toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (todaysTasks.isNotEmpty) ...[
                        const Text(
                          "Today's Tasks",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...todaysTasks.map((task) => TaskCard(task: task)),
                        const SizedBox(height: 16),
                      ],
                      if (otherTasks.isNotEmpty) ...[
                        const Text(
                          "Other Tasks",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...otherTasks.map((task) => TaskCard(task: task)),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Error: $e")),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final priority = ref.read(priorityFilterProvider);
    final status = ref.read(statusFilterProvider);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Filter Tasks",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              // Priority filter
              DropdownButtonFormField<Priority?>(
                value: priority,
                decoration: const InputDecoration(labelText: "Priority"),
                onChanged: (val) =>
                    ref.read(priorityFilterProvider.notifier).state = val,
                items: [
                  const DropdownMenuItem(value: null, child: Text("All")),
                  ...Priority.values.map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.name.toUpperCase()),
                    ),
                  ),
                ],
              ),

              // Status filter
              DropdownButtonFormField<String?>(
                value: status,
                decoration: const InputDecoration(labelText: "Status"),
                onChanged: (val) =>
                    ref.read(statusFilterProvider.notifier).state = val,
                items: const [
                  DropdownMenuItem(value: null, child: Text("All")),
                  DropdownMenuItem(
                    value: "completed",
                    child: Text("Completed"),
                  ),
                  DropdownMenuItem(
                    value: "incomplete",
                    child: Text("Incomplete"),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Apply",style: TextStyle(color: Colors.blue),),
              ),
            ],
          ),
        );
      },
    );
  }
}
