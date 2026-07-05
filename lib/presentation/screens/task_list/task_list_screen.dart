import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/task.dart';
import '../../providers/task_provider.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().loadTasks('mock-user-id');
    });
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'kuliah';
    String selectedPriority = 'medium';
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 3));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF9F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setBottomState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'New Quest',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Quest Title *',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: const [
                      DropdownMenuItem(
                        value: 'kuliah',
                        child: Text('📚 Kuliah'),
                      ),
                      DropdownMenuItem(
                        value: 'organisasi',
                        child: Text('🏛️ Organisasi'),
                      ),
                      DropdownMenuItem(
                        value: 'pribadi',
                        child: Text('🧍 Pribadi'),
                      ),
                    ],
                    onChanged: (v) =>
                        setBottomState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPriority,
                    decoration: const InputDecoration(labelText: 'Priority'),
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('🟢 Low')),
                      DropdownMenuItem(
                        value: 'medium',
                        child: Text('🟡 Medium'),
                      ),
                      DropdownMenuItem(value: 'high', child: Text('🔴 High')),
                    ],
                    onChanged: (v) =>
                        setBottomState(() => selectedPriority = v!),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Deadline: ${selectedDeadline.day}/${selectedDeadline.month}/${selectedDeadline.year}',
                    ),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setBottomState(() => selectedDeadline = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (titleController.text.trim().isEmpty) return;
                      final baseXp = selectedPriority == 'high'
                          ? 35
                          : selectedPriority == 'medium'
                          ? 20
                          : 10;
                      final newTask = Task(
                        id: const Uuid().v4(),
                        userId: 'mock-user-id',
                        title: titleController.text.trim(),
                        description: descController.text.trim().isEmpty
                            ? null
                            : descController.text.trim(),
                        category: selectedCategory,
                        priority: selectedPriority,
                        deadline: selectedDeadline,
                        status: 'pending',
                        xpReward: baseXp,
                        createdAt: DateTime.now(),
                        isSynced: false,
                      );
                      context.read<TaskProvider>().addTask(newTask);
                      Navigator.pop(ctx);
                    },
                    child: const Text('Add Quest'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quest Board')),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, _) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (taskProvider.tasks.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Color(0xFF6B6862),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No quests yet!\nTap + to add your first quest.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF6B6862)),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: taskProvider.tasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.tasks[index];
              return _buildTaskCard(context, task, taskProvider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
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
          if (index == 0) context.go('/dashboard');
          if (index == 2) context.go('/profile');
        },
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    TaskProvider provider,
  ) {
    final isCompleted = task.status == 'completed';

    Color priorityColor;
    switch (task.priority) {
      case 'high':
        priorityColor = const Color(0xFFB3492F);
        break;
      case 'medium':
        priorityColor = const Color(0xFFC48A2D);
        break;
      default:
        priorityColor = const Color(0xFF4E7A51);
    }

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFB3492F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Quest?'),
            content: Text('Remove "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Color(0xFFB3492F)),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteTask(task.id),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ListTile(
          onTap: () => context.go('/tasks/${task.id}'),
          leading: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted
                ? const Color(0xFF4E7A51)
                : const Color(0xFF6B6862),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text('${task.category} · ${task.xpReward} XP'),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: priorityColor.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: priorityColor, width: 0.5),
            ),
            child: Text(
              task.priority.toUpperCase(),
              style: TextStyle(
                color: priorityColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
