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
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;
    if (userId != null) {
      if (authProvider.role == 'mahasiswa') {
        Provider.of<TaskProvider>(context, listen: false).loadTasks(userId);
        Provider.of<TaskProvider>(context, listen: false).syncTasks(userId);
      } else {
        Provider.of<TaskProvider>(context, listen: false).loadAllTasks();
        authProvider.loadUsersByRole('mahasiswa');
        Provider.of<TaskProvider>(context, listen: false).syncTasks(userId);
      }
    }
  }

  void _showAddTaskDialog(BuildContext context, String userId) {
    // Capture all provider data BEFORE showing the modal.
    // This eliminates the need for Consumer<AuthProvider> inside the builder,
    // which was causing context staleness after notifyListeners() rebuilds.
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final taskProv = Provider.of<TaskProvider>(context, listen: false);
    final role = auth.role;
    final students = List.of(auth.users); // snapshot

    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'kuliah';
    String selectedPriority = 'medium';
    String selectedStudent = 'all';
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 3));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF9F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        // StatefulBuilder only — NO Consumer inside.
        // sheetContext is the builder's own context and is the most reliable
        // reference for Navigator.of(...).pop() on a bottom sheet route.
        return StatefulBuilder(
          builder: (_, setBottomState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'New Quest',
                    style: Theme.of(sheetContext).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  if (role != 'mahasiswa') ...[
                    DropdownButtonFormField<String>(
                      initialValue: selectedStudent,
                      decoration: const InputDecoration(
                        labelText: 'Assign Quest To',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'all',
                          child: Text('👥 All Students'),
                        ),
                        ...students.map((student) {
                          return DropdownMenuItem(
                            value: student.id,
                            child: Text('🧍 ${student.username}'),
                          );
                        }),
                      ],
                      onChanged: (v) =>
                          setBottomState(() => selectedStudent = v!),
                    ),
                    const SizedBox(height: 12),
                    if (students.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '⚠️ No students registered yet.',
                          style: TextStyle(
                            color: Color(0xFFB3492F),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
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
                      'Deadline: ${selectedDeadline.day}/${selectedDeadline.month}/${selectedDeadline.year} '
                      '${selectedDeadline.hour.toString().padLeft(2, '0')}:'
                      '${selectedDeadline.minute.toString().padLeft(2, '0')}',
                    ),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: sheetContext,
                        initialDate: selectedDeadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null && sheetContext.mounted) {
                        final time = await showTimePicker(
                          context: sheetContext,
                          initialTime: TimeOfDay.fromDateTime(selectedDeadline),
                        );
                        if (time != null) {
                          setBottomState(() {
                            selectedDeadline = DateTime(
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
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final title = titleController.text.trim();
                      if (title.isEmpty) return;

                      if (role != 'mahasiswa' &&
                          selectedStudent == 'all' &&
                          students.isEmpty) {
                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cannot assign quest: No students registered yet.',
                            ),
                            backgroundColor: Color(0xFFB3492F),
                          ),
                        );
                        return;
                      }

                      final baseXp = selectedPriority == 'high'
                          ? 35
                          : selectedPriority == 'medium'
                          ? 20
                          : 10;
                      final desc = descController.text.trim().isEmpty
                          ? null
                          : descController.text.trim();

                      try {
                        if (role == 'mahasiswa') {
                          await taskProv.addTask(
                            Task(
                              id: const Uuid().v4(),
                              userId: userId,
                              title: title,
                              description: desc,
                              category: selectedCategory,
                              priority: selectedPriority,
                              deadline: selectedDeadline,
                              status: 'pending',
                              xpReward: baseXp,
                              createdAt: DateTime.now(),
                              isSynced: false,
                            ),
                          );
                        } else {
                          final targets = selectedStudent == 'all'
                              ? students
                              : students
                                    .where((s) => s.id == selectedStudent)
                                    .toList();
                          for (final student in targets) {
                            await taskProv.addTask(
                              Task(
                                id: const Uuid().v4(),
                                userId: student.id,
                                title: title,
                                description: desc,
                                category: selectedCategory,
                                priority: selectedPriority,
                                deadline: selectedDeadline,
                                status: 'pending',
                                xpReward: baseXp,
                                createdAt: DateTime.now(),
                                isSynced: false,
                              ),
                            );
                          }
                          await taskProv.loadAllTasks();
                        }
                        // sheetContext is the builder's context — it is NOT
                        // rebuilt by notifyListeners() so .mounted stays true.
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      } catch (e) {
                        if (sheetContext.mounted) {
                          ScaffoldMessenger.of(sheetContext).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create task: $e'),
                              backgroundColor: const Color(0xFFB3492F),
                            ),
                          );
                        }
                      }
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

  Widget _buildFilterChips() {
    final statuses = [
      {'value': 'all', 'label': 'All'},
      {'value': 'pending', 'label': 'Active'},
      {'value': 'submitted', 'label': 'Pending Review'},
      {'value': 'completed', 'label': 'Completed'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: statuses.map((status) {
          final isSelected = _statusFilter == status['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(status['label']!),
              selected: isSelected,
              selectedColor: const Color(0xFFC15F3C),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF6B6862),
                fontWeight: FontWeight.bold,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _statusFilter = status['value']!;
                  });
                }
              },
            ),
          );
        }).toList(),
      ),
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
          ),
        ],
      ),
      body: taskProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildFilterChips(),
                Expanded(
                  child: () {
                    final filteredTasks = taskProvider.tasks.where((task) {
                      if (_statusFilter == 'all') return true;
                      return task.status == _statusFilter;
                    }).toList();

                    if (filteredTasks.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Color(0xFF6B6862),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _statusFilter == 'all'
                                  ? 'No quests yet!\nTap + to add your first quest.'
                                  : 'No quests match this filter.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Color(0xFF6B6862)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return _buildTaskCard(context, task, taskProvider);
                      },
                    );
                  }(),
                ),
              ],
            ),
      floatingActionButton: (userId == null || authProvider.role == 'mahasiswa')
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

    Color statusColor;
    String statusText;
    IconData leadingIcon;
    switch (task.status.toLowerCase()) {
      case 'completed':
        statusColor = const Color(0xFF4E7A51);
        statusText = 'APPROVED';
        leadingIcon = Icons.check_circle_rounded;
        break;
      case 'submitted':
        statusColor = const Color(0xFFC48A2D);
        statusText = 'PENDING REVIEW';
        leadingIcon = Icons.hourglass_empty_rounded;
        break;
      default:
        statusColor = const Color(0xFF6B6862);
        statusText = 'IN PROGRESS';
        leadingIcon = Icons.radio_button_unchecked_rounded;
    }

    final isCompleted = task.status == 'completed';

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
          leading: Icon(leadingIcon, color: statusColor),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text('${task.category} · ${task.xpReward} XP'),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
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
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: statusColor, width: 0.5),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
