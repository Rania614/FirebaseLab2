import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoService {
  CollectionReference todo = FirebaseFirestore.instance.collection('todo');

  Future<List<Map<String, dynamic>>> getTodos() async {
    try {
      QuerySnapshot snapshot = await todo
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .get();
      if (snapshot.docs.isEmpty) {
        print('No todos found.');
        return [];
      }
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error getting todos: $e');
      return [];
    }
  }

  Future<void> createTodo(String title) async {
    await todo.add({
      'title': title,
      'completed': false,
      'userId': FirebaseAuth.instance.currentUser!.uid,
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> updateTodo(String todoId, Map<String, dynamic> updates) async {
    try {
      await todo
          .doc(todoId)
          .update({...updates, 'updatedAt': Timestamp.now()})
          .then((value) {
            print('Todo updated successfully');
          })
          .catchError((error) {
            print('Failed to update todo: $error');
          });
    } catch (e) {
      print('Error updating todo: $e');
    }
  }

  Future<void> toggleTodoCompletion(String todoId, bool isCompleted) async {
    await todo
        .doc(todoId)
        .update({
          'completed': isCompleted,
          'updatedAt': FieldValue.serverTimestamp(),
        })
        .then((value) {
          print('Todo completion toggled successfully');
        })
        .catchError((error) {
          print('Failed to toggle todo completion: $error');
        });
  }

  Future<void> deleteTodo(String todoId) async {
    try {
      await todo
          .doc(todoId)
          .delete()
          .then((value) {
            print('Todo deleted successfully');
          })
          .catchError((error) {
            print('Failed to delete todo: $error');
          });
      print('Todo deleted successfully');
    } catch (e) {
      print('Error deleting todo: $e');
    }
  }
} 