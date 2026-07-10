import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/task.dart';
import '../../../core/theme/app_colors.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  void _loadTasks() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;
    if (userId != null) {
      final role = authProvider.role;
      if (role == 'mahasiswa') {
        Provider.of<TaskProvider>(context, listen: false).loadTasks(userId);
        Provider.of<TaskProvider>(context, listen: false)
            .syncTasks(userId, role: role);
      } else {
        Provider.of<TaskProvider>(context, listen: false).loadAllTasks();
        authProvider.loadUsersByRole('mahasiswa');
        Provider.of<TaskProvider>(context, listen: false)
            .syncTasks(userId, role: role);
      }
    }
  }

  void _showAddTaskDialog(BuildContext context, String userId) {
    final taskProv = Provider.of<TaskProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedCategory = 'kuliah';
    String selectedPriority = 'medium';
    String selectedStudent = 'all';
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 3));
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.weatheredStone : AppColors.vellum,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(
          color: isDark ? AppColors.agedBorder : AppColors.parchmentBorder,
          width: 1,
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setBottomState) {
            return Consumer<AuthProvider>(
              builder: (context, auth, _) {
                final role = auth.role;
                final students = auth.users;

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
                      Row(
                        children: [
                          const Text('⚔', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 8),
                          Text(
                            'New Quest',
                            style: Theme.of(sheetContext).textTheme.displaySmall
                                ?.copyWith(
                                  color: AppColors.ancientGold,
                                  fontSize: 20,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Divider(
                        color: isDark
                            ? AppColors.agedBorder
                            : AppColors.parchmentBorder,
                      ),
                      const SizedBox(height: 12),

                      if (role != 'mahasiswa') ...[
                        DropdownButtonFormField<String>(
                          initialValue: selectedStudent,
                          decoration: const InputDecoration(
                            labelText: 'Assign Quest To',
                            prefixIcon: Icon(Icons.group_outlined),
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
                          onChanged: isSubmitting
                              ? null
                              : (v) => setBottomState(
                                    () => selectedStudent = v!,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        if (students.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              '⚠️ No students registered yet.',
                              style: const TextStyle(
                                color: AppColors.dangerRed,
                                fontSize: 12,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                      ],

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Quest Title *',
                          prefixIcon: Icon(Icons.title_rounded),
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: descController,
                        decoration: const InputDecoration(
                          labelText: 'Description (optional)',
                          prefixIcon: Icon(Icons.notes_rounded),
                        ),
                        maxLines: 2,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
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
                        onChanged: isSubmitting
                            ? null
                            : (v) => setBottomState(
                                  () => selectedCategory = v!,
                                ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'low',
                            child: Text('🟢 Low — 10 XP'),
                          ),
                          DropdownMenuItem(
                            value: 'medium',
                            child: Text('🟡 Medium — 20 XP'),
                          ),
                          DropdownMenuItem(
                            value: 'high',
                            child: Text('🔴 High — 35 XP'),
                          ),
                        ],
                        onChanged: isSubmitting
                            ? null
                            : (v) => setBottomState(
                                  () => selectedPriority = v!,
                                ),
                      ),
                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today_outlined),
                        label: Text(
                          'Deadline: ${selectedDeadline.day}/${selectedDeadline.month}/${selectedDeadline.year} '
                          '${selectedDeadline.hour.toString().padLeft(2, '0')}:'
                          '${selectedDeadline.minute.toString().padLeft(2, '0')}',
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final date = await showDatePicker(
                                  context: sheetContext,
                                  initialDate: selectedDeadline,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(
                                    const Duration(days: 365),
                                  ),
                                );
                                if (date != null && sheetContext.mounted) {
                                  final time = await showTimePicker(
                                    context: sheetContext,
                                    initialTime: TimeOfDay.fromDateTime(
                                      selectedDeadline,
                                    ),
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

                      if (isSubmitting)
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.ancientGold,
                          ),
                        )
                      else
                        ElevatedButton.icon(
                          icon: const Text(
                            '⚔',
                            style: TextStyle(fontSize: 16),
                          ),
                          label: const Text('Add Quest'),
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

                            setBottomState(() => isSubmitting = true);

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

                                final assignments = targets
                                    .map(
                                      (s) => TaskAssignment(
                                        studentId: s.id,
                                        studentUsername: s.username,
                                        status: 'pending',
                                      ),
                                    )
                                    .toList();

                                final newTask = Task(
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
                                  assignments: assignments,
                                );

                                await taskProv.addTask(newTask);
                                await taskProv.loadAllTasks();
                              }
                              if (sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                              }
                            } catch (e) {
                              if (sheetContext.mounted) {
                                ScaffoldMessenger.of(sheetContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to create quest: $e'),
                                  ),
                                );
                              }
                            } finally {
                              setBottomState(() => isSubmitting = false);
                            }
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChips() {
    final statuses = [
      {'value': 'all', 'label': '⚔ All'},
      {'value': 'pending', 'label': '🗡 Active'},
      {'value': 'submitted', 'label': '⏳ Reviewing'},
      {'value': 'completed', 'label': '✅ Done'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: statuses.map((status) {
          final isSelected = _statusFilter == status['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                status['label']!,
                style: TextStyle(
                  color: isSelected
                      ? AppColors.dungeonBlack
                      : Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
              selected: isSelected,
              selectedColor: AppColors.ancientGold,
              backgroundColor: Theme.of(context).cardTheme.color ??
                  Theme.of(context).colorScheme.surface,
              side: BorderSide(
                color: isSelected
                    ? AppColors.ancientGold
                    : Theme.of(context).dividerColor,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
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
            tooltip: 'Refresh quests',
          ),
        ],
      ),
      body: taskProvider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.ancientGold),
            )
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
                            Icon(
                              Icons.assignment_outlined,
                              size: 64,
                              color: Theme.of(
                                context,
                              ).textTheme.labelSmall?.color,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _statusFilter == 'all'
                                  ? 'The quest board is empty.\nBegin your adventure — tap + to add a quest.'
                                  : 'No quests match this filter.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontStyle: FontStyle.italic),
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
      floatingActionButton:
          (userId == null || authProvider.role == 'mahasiswa')
          ? null
          : FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context, userId),
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Priority color ────────────────────────────────────────────────
    Color priorityColor;
    IconData priorityIcon;
    switch (task.priority.toLowerCase()) {
      case 'high':
        priorityColor = AppColors.bloodCrimson;
        priorityIcon = Icons.keyboard_double_arrow_up_rounded;
        break;
      case 'medium':
        priorityColor = AppColors.questGold;
        priorityIcon = Icons.remove_rounded;
        break;
      default:
        priorityColor = AppColors.victoryGreen;
        priorityIcon = Icons.keyboard_double_arrow_down_rounded;
    }

    // ── Status color & label ──────────────────────────────────────────
    Color statusColor;
    String statusText;
    IconData leadingIcon;
    final isCompleted = task.status == 'completed';

    switch (task.status.toLowerCase()) {
      case 'completed':
        statusColor = AppColors.victoryGreen;
        statusText = 'APPROVED';
        leadingIcon = Icons.check_circle_rounded;
        break;
      case 'submitted':
        statusColor = AppColors.questGold;
        statusText = 'REVIEWING';
        leadingIcon = Icons.hourglass_top_rounded;
        break;
      default:
        statusColor = AppColors.manaBlue;
        statusText = 'IN PROGRESS';
        leadingIcon = Icons.radio_button_unchecked_rounded;
    }

    // ── Left border color ─────────────────────────────────────────────
    Color borderLeftColor;
    switch (task.status.toLowerCase()) {
      case 'completed':
        borderLeftColor = AppColors.victoryGreen;
        break;
      case 'submitted':
        borderLeftColor = AppColors.questGold;
        break;
      default:
        borderLeftColor = task.priority.toLowerCase() == 'high'
            ? AppColors.bloodCrimson
            : isDark
            ? AppColors.agedBorder
            : AppColors.parchmentBorder;
    }

    return Dismissible(
      key: Key(task.id),
      direction: (authProvider.role == 'mahasiswa')
          ? DismissDirection.none
          : DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: AppColors.dangerRed,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.delete_forever_rounded, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Quest?'),
            content: Text('Remove "${task.title}" from the quest board?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.dangerRed),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => provider.deleteTask(task.id, role: authProvider.role),
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDark ? AppColors.agedBorder : AppColors.parchmentBorder,
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => context.go(
            '/tasks/${task.id}${authProvider.role != 'mahasiswa' ? '?userId=${task.userId}' : ''}',
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left border strip
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: borderLeftColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(7),
                      bottomLeft: Radius.circular(7),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Status icon box
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(30),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(leadingIcon, color: statusColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        // Title + meta
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                task.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AppColors.dustyScript,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted
                                      ? Theme.of(
                                          context,
                                        ).textTheme.labelSmall?.color
                                      : Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 11,
                                    color: AppColors.ancientGold,
                                  ),
                                  const SizedBox(width: 3),
                                  Flexible(
                                    child: Text(
                                      '${task.xpReward} XP  ·  ${task.category}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.labelSmall?.color,
                                        fontFamily: 'Inter',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              // Student badge (non-mahasiswa)
                              if (authProvider.role != 'mahasiswa' &&
                                  task.studentUsername != null) ...[
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.ancientGold.withAlpha(25),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.ancientGold.withAlpha(
                                        100,
                                      ),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 10,
                                        color: AppColors.ancientGold,
                                      ),
                                      const SizedBox(width: 3),
                                      Flexible(
                                        child: Text(
                                          '@${task.studentUsername}',
                                          style: const TextStyle(
                                            color: AppColors.ancientGold,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Inter',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Trailing badges
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Priority badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: priorityColor.withAlpha(30),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: priorityColor.withAlpha(120),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    priorityIcon,
                                    size: 9,
                                    color: priorityColor,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    task.priority.toUpperCase(),
                                    style: TextStyle(
                                      color: priorityColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Inter',
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 5),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withAlpha(25),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: statusColor.withAlpha(120),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'Inter',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
