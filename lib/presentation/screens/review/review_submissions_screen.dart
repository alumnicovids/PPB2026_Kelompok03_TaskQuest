import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/task_provider.dart';
import '../../../domain/entities/task.dart';

class ReviewSubmissionsScreen extends StatefulWidget {
  const ReviewSubmissionsScreen({super.key});

  @override
  State<ReviewSubmissionsScreen> createState() =>
      _ReviewSubmissionsScreenState();
}

class _ReviewSubmissionsScreenState extends State<ReviewSubmissionsScreen> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskProvider>(context, listen: false).loadSubmittedTasks();
    });
  }

  Future<void> _handleApprove(Task task) async {
    setState(() => _isProcessing = true);
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      await taskProvider.approveQuest(task.id, task.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quest "${task.title}" approved! XP rewarded.'),
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
      await taskProvider.rejectQuest(task.id, task.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Quest "${task.title}" rejected. Reverted to In Progress.',
            ),
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
    final taskProvider = Provider.of<TaskProvider>(context);
    final submittedTasks = taskProvider.submittedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Submissions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: taskProvider.isLoading && submittedTasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                _loadData();
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Pending Approvals (${submittedTasks.length})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B6862),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: submittedTasks.isEmpty
                          ? ListView(
                              children: const [
                                SizedBox(height: 120),
                                Icon(
                                  Icons.done_all_rounded,
                                  size: 64,
                                  color: Color(0xFF4E7A51),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'All Caught Up!',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF2D2B26),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No student quests are currently waiting for your verification.',
                                  style: TextStyle(color: Color(0xFF6B6862)),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: submittedTasks.length,
                              itemBuilder: (context, index) {
                                final task = submittedTasks[index];
                                return _buildSubmittedTaskListItem(
                                  context,
                                  task,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSubmittedTaskListItem(BuildContext context, Task task) {
    final formattedDate =
        '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}';
    final studentName = task.studentUsername ?? 'Student';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student name & category
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
                    'Student: $studentName',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC15F3C),
                    ),
                  ),
                ),
                Text(
                  'Category: ${task.category.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B6862),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title & Description
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2B26),
              ),
            ),
            if (task.description != null && task.description!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description!,
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B6862)),
              ),
            ],
            const SizedBox(height: 12),

            // Reward details & Deadline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt, color: Color(0xFFC48A2D), size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${task.xpReward} XP',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC48A2D),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Due: $formattedDate',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B6862),
                  ),
                ),
              ],
            ),

            // Display uploaded proof photo if exists
            if (task.proofPhotoPath != null) ...[
              const Divider(height: 24),
              const Text(
                'Submission Proof:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2B26),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  // Show full image dialog
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          InteractiveViewer(
                            child: Image.network(task.proofPhotoPath!),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    task.proofPhotoPath!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 100,
                      color: const Color(0xFFEDE9DE),
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: Color(0xFFB3492F),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],

            const Divider(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: _isProcessing ? null : () => _handleReject(task),
                  icon: const Icon(Icons.close, color: Color(0xFFB3492F)),
                  label: const Text(
                    'Reject Quest',
                    style: TextStyle(color: Color(0xFFB3492F)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFB3492F)),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isProcessing ? null : () => _handleApprove(task),
                  icon: const Icon(Icons.check_circle_rounded),
                  label: const Text('Approve Quest'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4E7A51),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
