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
}
