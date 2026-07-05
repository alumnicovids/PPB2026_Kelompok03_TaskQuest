import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/task.dart';
import '../../providers/auth_provider.dart';
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
    _loadTasks();
  }

  void _loadTasks() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      if (userId != null) {
        Provider.of<TaskProvider>(context, listen: false).loadTasks(userId);
      }
    });
  }

  void _showAddTaskDialog(BuildContext context, String userId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String category = 'kuliah';
    String priority = 'medium';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setDialogState) {
            return AlertDialog(
              title: const Text('New Quest (Task)'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Quest Title',
                        hintText: 'e.g., Study Flutter',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'What needs to be done?',
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: const [
                        DropdownMenuItem(value: 'kuliah', child: Text('Kuliah')),
                        DropdownMenuItem(value: 'organisasi', child: Text('Organisasi')),
                        DropdownMenuItem(value: 'pribadi', child: Text('Pribadi')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            category = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: priority,
                      decoration: const InputDecoration(labelText: 'Priority / Difficulty'),
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low (Bronze)')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium (Silver)')),
                        DropdownMenuItem(value: 'high', child: Text('High (Gold)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() {
                            priority = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Deadline: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: statefulContext,
                              initialDate: selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null && statefulContext.mounted) {
                              final time = await showTimePicker(
                                context: statefulContext,
                                initialTime: TimeOfDay.fromDateTime(selectedDate),
                              );
                              if (time != null) {
                                setDialogState(() {
                                  selectedDate = DateTime(
                                    date.year,
                                    date.month,
                                    date.day,
                                    time.hour,
                                    time.minute,
                                  );
                                });
                              }
                            }
                          },
                          child: Text(
                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year} ${selectedDate.hour.toString().padLeft(2, '0')}:${selectedDate.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    // Calculate default XP reward based on priority
                    int xpReward = 10;
                    if (priority == 'medium') xpReward = 20;
                    if (priority == 'high') xpReward = 35;

                    final newTask = Task(
                      id: const Uuid().v4(),
                      userId: userId,
                      title: title,
                      description: descController.text.trim(),
                      category: category,
                      priority: priority,
                      deadline: selectedDate,
                      status: 'pending',
                      xpReward: xpReward,
                      createdAt: DateTime.now(),
                      isSynced: false,
                    );

                    Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Add Quest'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    final userId = authProvider.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadTasks,
          )
        ],
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : taskProvider.tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox_rounded, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'Quest board is empty!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the "+" button below to add your first quest.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (context, index) {
                    final task = taskProvider.tasks[index];
                    final isCompleted = task.status == 'completed';

                    Color priorityColor;
                    switch (task.priority.toLowerCase()) {
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
                        onTap: () => context.go('/tasks/${task.id}'),
                        leading: Icon(
                          isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isCompleted ? const Color(0xFF4E7A51) : const Color(0xFF6B6862),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          'Category: ${task.category}',
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
                            task.priority.toUpperCase(),
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
      floatingActionButton: userId == null
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context, userId),
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
