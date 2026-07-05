import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock task list
    final List<Map<String, dynamic>> mockTasks = [
      {
        'id': '1',
        'title': 'Laporan Praktikum Pemrograman Mobile',
        'category': 'kuliah',
        'priority': 'high',
        'status': 'pending',
      },
      {
        'id': '2',
        'title': 'Beli Bahan Makanan Mingguan',
        'category': 'pribadi',
        'priority': 'low',
        'status': 'in_progress',
      },
      {
        'id': '3',
        'title': 'Rapat Evaluasi Program Kerja HIMA',
        'category': 'organisasi',
        'priority': 'medium',
        'status': 'completed',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Quest Board')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: mockTasks.length,
        itemBuilder: (context, index) {
          final task = mockTasks[index];
          final isCompleted = task['status'] == 'completed';

          Color priorityColor;
          switch (task['priority']) {
            case 'high':
              priorityColor = const Color(0xFFB3492F);
              break;
            case 'medium':
              priorityColor = const Color(0xFFC48A2D);
              break;
            default:
              priorityColor = const Color(0xFF4E7A51);
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              onTap: () => context.go('/tasks/${task['id']}'),
              leading: Icon(
                isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isCompleted
                    ? const Color(0xFF4E7A51)
                    : const Color(0xFF6B6862),
              ),
              title: Text(
                task['title'],
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Category: ${task['category']}',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priorityColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: priorityColor, width: 0.5),
                ),
                child: Text(
                  task['priority'].toUpperCase(),
                  style: TextStyle(
                    color: priorityColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Trigger a dialog or navigate to create
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Mock: Add new task dialog')),
          );
        },
        backgroundColor: const Color(0xFFC15F3C),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: const Color(0xFFC15F3C),
        unselectedItemColor: const Color(0xFF6B6862),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Quests',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 0) {
            context.go('/dashboard');
          } else if (index == 2) {
            context.go('/profile');
          }
        },
      ),
    );
  }
}
