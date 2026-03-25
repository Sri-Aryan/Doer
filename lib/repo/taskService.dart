import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task/repo/task.dart';


class TaskService {
  final _tasks = FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    await _tasks.add(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await _tasks.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await _tasks.doc(id).delete();
  }

  Stream<List<Task>> getTasks() {
    return _tasks
        .orderBy('dueDate')
        .snapshots()
        .map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromMap(doc.id, doc.data())).toList());
  }

  Future<void> toggleComplete(Task task) async {
    await _tasks.doc(task.id).update({'isCompleted': !task.isCompleted});
  }

  /// Marks [task] as complete and, if it is recurring, atomically creates
  /// the next occurrence in the same Firestore batch so both writes land
  /// together and trigger a single stream update.
  Future<void> markComplete(Task task) async {
    final batch = FirebaseFirestore.instance.batch();

    // 1. Mark original task done
    batch.update(_tasks.doc(task.id), {'isCompleted': true});

    // 2. Create next occurrence for recurring tasks
    if (task.recurringType != RecurringType.none) {
      final days = task.recurringType == RecurringType.daily ? 1 : 7;
      final nextTask = task.copyWith(
        id: "",
        isCompleted: false,
        dueDate: task.dueDate.add(Duration(days: days)),
        sortOrder: null,
      );
      batch.set(_tasks.doc(), nextTask.toMap());
    }

    await batch.commit();
  }

  Future<void> batchUpdateSortOrders(List<Task> tasks) async {
    final batch = FirebaseFirestore.instance.batch();
    for (final task in tasks) {
      batch.update(_tasks.doc(task.id), {'sortOrder': task.sortOrder});
    }
    await batch.commit();
  }
}
