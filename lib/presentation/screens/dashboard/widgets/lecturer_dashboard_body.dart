import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../../domain/entities/task.dart';

class LecturerDashboardBody extends StatefulWidget {
  const LecturerDashboardBody({super.key});

  @override
  State<LecturerDashboardBody> createState() => _LecturerDashboardBodyState();
}

class _LecturerDashboardBodyState extends State<LecturerDashboardBody> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadLecturerData();
  }

  void _loadLecturerData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadUsersByRole('mahasiswa');
      Provider.of<TaskProvider>(context, listen: false).loadSubmittedTasks();
    });
  }

  Future<void> _handleApprove(Task task) async {
    setState(() => _isProcessing = true);
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.approveQuest(task.id, task.userId, task.xpReward);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Approved quest "${task.title}". XP rewarded to student!'),
            backgroundColor: const Color(0xFF4E7A51),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to approve quest. Please check connection.'),
            backgroundColor: Color(0xFFB3492F),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleReject(Task task) async {
    setState(() => _isProcessing = true);
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.rejectQuest(task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rejected quest "${task.title}". Status reverted to In Progress.'),
            backgroundColor: const Color(0xFFC48A2D),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject quest.'),
            backgroundColor: Color(0xFFB3492F),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    final studentsCount = authProvider.users.length;
    final submittedTasks = taskProvider.submittedTasks;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stat cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Active Students',
                  '$studentsCount',
                  Icons.people_alt_rounded,
                  const Color(0xFFC15F3C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Pending Reviews',
                  '${submittedTasks.length}',
                  Icons.rate_review_rounded,
                  const Color(0xFFC48A2D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick action buttons
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/students'),
                  icon: const Icon(Icons.people_alt_rounded),
                  label: const Text('Students list'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.go('/tasks'),
                  icon: const Icon(Icons.add_box_rounded),
                  label: const Text('Create Quest'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Submitted quests review list
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Submitted Quests (${submittedTasks.length})',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              if (submittedTasks.isNotEmpty)
                TextButton(
                  onPressed: () => context.go('/review-submissions'),
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (taskProvider.isLoading && submittedTasks.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (submittedTasks.isEmpty)
            Card(
              color: const Color(0xFFEDE9DE).withAlpha(120),
              child: const Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.done_all_rounded,
                      size: 48,
                      color: Color(0xFF4E7A51),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'All caught up!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'No student quests waiting for approval.',
                      style: TextStyle(
                        color: Color(0xFF6B6862),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: submittedTasks.length > 3 ? 3 : submittedTasks.length,
              itemBuilder: (context, index) {
                final task = submittedTasks[index];
                return _buildSubmittedTaskCard(context, task);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    color: const Color(0xFF2D2B26),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B6862),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmittedTaskCard(BuildContext context, Task task) {
    final formattedDate =
        '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}';
    final studentName = task.studentUsername ?? 'Student';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9DE),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'From: $studentName',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC15F3C),
                    ),
                  ),
                ),
                Text(
                  'Due: $formattedDate',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B6862),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2B26),
              ),
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B6862),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.bolt,
                      color: Color(0xFFC48A2D),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Reward: ${task.xpReward} XP',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC48A2D),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () => context.push('/tasks/${task.id}'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('Review Detail'),
                ),
              ],
            ),
            if (task.proofPhotoPath != null) ...[
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: _isProcessing ? null : () => _handleReject(task),
                    icon: const Icon(Icons.close, color: Color(0xFFB3492F)),
                    label: const Text(
                      'Reject',
                      style: TextStyle(color: Color(0xFFB3492F)),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFB3492F)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _isProcessing ? null : () => _handleApprove(task),
                    icon: const Icon(Icons.check),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E7A51),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
