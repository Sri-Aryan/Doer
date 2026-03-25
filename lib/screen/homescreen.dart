import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../provider/taskProvider.dart';
import 'addTaskScreen.dart';
import '../repo/task.dart';
import '../widgets/taskCard.dart';
import '../widgets/weeklyProgressCard.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksStreamProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      appBar: AppBar(
        title: const Text("Taskify"),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () => _showFilterDialog(context, ref),
            tooltip: "Filter",
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Floating search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              elevation: 3,
              shadowColor: const Color(0xFF2196F3).withOpacity(0.12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  hintStyle: GoogleFonts.poppins(
                      color: const Color(0xFF5A7184), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Color(0xFF2196F3)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 14, horizontal: 16),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
          ),

          // Task list (chart scrolls with it)
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                final query =
                    ref.watch(searchQueryProvider).toLowerCase();

                final filteredTasks = tasks.where((t) {
                  return t.title.toLowerCase().contains(query);
                }).toList();

                final taskService = ref.read(taskServiceProvider);
                final today = DateTime.now();

                // Build merged list:
                // [chart, header?, ...todayTasks, header?, ...otherTasks]
                final items = <_ListItem>[];
                items.add(const _ListItem(isChart: true)); // always first

                if (filteredTasks.isEmpty) {
                  // Still show chart; empty state goes after it
                  items.add(const _ListItem(isEmpty: true));
                } else {
                  final todayTasks = filteredTasks.where((t) {
                    final d = t.dueDate;
                    return d.year == today.year &&
                        d.month == today.month &&
                        d.day == today.day;
                  }).toList();
                  final otherTasks = filteredTasks.where((t) {
                    final d = t.dueDate;
                    return !(d.year == today.year &&
                        d.month == today.month &&
                        d.day == today.day);
                  }).toList();

                  if (todayTasks.isNotEmpty) {
                    items.add(const _ListItem(header: "Today"));
                    items.addAll(
                        todayTasks.map((t) => _ListItem(task: t)));
                  }
                  if (otherTasks.isNotEmpty) {
                    items.add(const _ListItem(header: "Upcoming"));
                    items.addAll(
                        otherTasks.map((t) => _ListItem(task: t)));
                  }
                }

                return ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  // Drag handles are added manually on task cards only
                  buildDefaultDragHandles: false,
                  itemCount: items.length,
                  onReorder: (oldIndex, newIndex) {
                    // Only task items are draggable
                    if (!items[oldIndex].isTask) return;
                    if (newIndex > oldIndex) newIndex--;
                    if (newIndex < items.length &&
                        !items[newIndex].isTask) return;

                    final taskItems =
                        items.where((i) => i.isTask).toList();
                    final oldTask = items[oldIndex].task!;
                    final oldTaskIdx = taskItems
                        .indexWhere((i) => i.task!.id == oldTask.id);

                    int newTaskIdx = 0;
                    for (int i = 0; i < newIndex && i < items.length; i++) {
                      if (items[i].isTask) newTaskIdx++;
                    }
                    if (newTaskIdx > oldTaskIdx) newTaskIdx--;

                    final reordered =
                        List<Task>.from(taskItems.map((i) => i.task!));
                    final moved = reordered.removeAt(oldTaskIdx);
                    reordered.insert(newTaskIdx, moved);

                    final updated = reordered
                        .asMap()
                        .entries
                        .map((e) => e.value.copyWith(sortOrder: e.key))
                        .toList();
                    taskService.batchUpdateSortOrders(updated);
                  },
                  itemBuilder: (context, index) {
                    final item = items[index];

                    if (item.isChart) {
                      return const Padding(
                        key: ValueKey('__chart__'),
                        padding: EdgeInsets.only(bottom: 0),
                        child: WeeklyProgressCard(),
                      );
                    }

                    if (item.isEmpty) {
                      return _EmptyState(
                        key: const ValueKey('__empty__'),
                        query: query,
                      );
                    }

                    if (item.isHeader) {
                      return _SectionHeader(
                        key: ValueKey("hdr_${item.header}"),
                        title: item.header!,
                      );
                    }

                    // Task card — wrapped with drag listener
                    return ReorderableDelayedDragStartListener(
                      key: ValueKey(item.task!.id),
                      index: index,
                      child: TaskCard(
                        task: item.task!,
                        searchQuery: query,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Color(0xFF2196F3)),
              ),
              error: (e, _) => Center(child: Text("Error: $e")),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
        ),
        icon: const Icon(Icons.add_rounded),
        label: Text(
          "New Task",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, WidgetRef ref) {
    final priority = ref.read(priorityFilterProvider);
    final status = ref.read(statusFilterProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 20),
              Text(
                "Filter Tasks",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0D1B2A),
                ),
              ),
              const SizedBox(height: 16),
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
              const SizedBox(height: 12),
              DropdownButtonFormField<String?>(
                value: status,
                decoration: const InputDecoration(labelText: "Status"),
                onChanged: (val) =>
                    ref.read(statusFilterProvider.notifier).state = val,
                items: const [
                  DropdownMenuItem(value: null, child: Text("All")),
                  DropdownMenuItem(
                      value: "completed", child: Text("Completed")),
                  DropdownMenuItem(
                      value: "incomplete", child: Text("Incomplete")),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Apply Filters"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── helpers ──────────────────────────────────────────────────────────────────

class _ListItem {
  final String? header;
  final Task? task;
  final bool isChart;
  final bool isEmpty;

  const _ListItem({
    this.header,
    this.task,
    this.isChart = false,
    this.isEmpty = false,
  });

  bool get isHeader => header != null;
  bool get isTask => task != null;
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2196F3),
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query, required ValueKey<String> key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded,
              size: 64,
              color: const Color(0xFF2196F3).withOpacity(0.35)),
          const SizedBox(height: 16),
          Text(
            query.isEmpty ? "No tasks yet" : "No tasks match \"$query\"",
            style: GoogleFonts.poppins(
                color: const Color(0xFF5A7184), fontSize: 15),
          ),
          if (query.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Tap + to add your first task",
              style: GoogleFonts.poppins(
                  color: const Color(0xFF5A7184), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
