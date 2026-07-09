import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/datasources/local/camera_datasource.dart';
import '../../../domain/entities/task.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  final String? studentUserId;

  const TaskDetailScreen({super.key, required this.taskId, this.studentUserId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  String? _localPhotoPath;
  bool _isProcessing = false;
  late CameraDatasource _cameraDatasource;

  @override
  void initState() {
    super.initState();
    _cameraDatasource = CameraDatasource(ImagePicker());
  }

  Future<void> _capturePhoto() async {
    final path = await _cameraDatasource.captureTaskProof();
    if (path != null) {
      setState(() => _localPhotoPath = path);
    }
  }

  Future<void> _selectFromGallery() async {
    final path = await _cameraDatasource.selectTaskProofFromGallery();
    if (path != null) {
      setState(() => _localPhotoPath = path);
    }
  }

  Future<void> _completeQuest(Task task) async {
    if (task.proofPhotoPath == null && _localPhotoPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture or select a photo proof first!'),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final updatedTask = task.copyWith(
        status: 'submitted',
        proofPhotoPath: _localPhotoPath ?? task.proofPhotoPath,
      );

      // 1. Update task in TaskProvider
      await Provider.of<TaskProvider>(
        context,
        listen: false,
      ).updateTask(updatedTask);

      if (!mounted) return;

      // Show dialog detailing submission
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.send_rounded, color: Color(0xFFC15F3C)),
                SizedBox(width: 8),
                Text('Quest Submitted!'),
              ],
            ),
            content: const Text(
              'Your quest has been submitted for review. XP will be awarded once your lecturer approves the submission.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.go('/tasks');
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to submit quest. Please check connection.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _deleteQuest() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isDosenOrAdmin =
        authProvider.role == 'dosen' || authProvider.role == 'superadmin';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isDosenOrAdmin ? 'Delete Quest' : 'Abandon Quest'),
        content: Text(
          isDosenOrAdmin
              ? 'Are you sure you want to delete this quest?'
              : 'Are you sure you want to abandon this quest?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB3492F),
            ),
            child: Text(isDosenOrAdmin ? 'Delete' : 'Abandon'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isProcessing = true;
      });
      try {
        await Provider.of<TaskProvider>(
          context,
          listen: false,
        ).deleteTask(widget.taskId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isDosenOrAdmin ? 'Quest deleted.' : 'Quest abandoned.',
              ),
            ),
          );
          context.go('/tasks');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete quest: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isProcessing = false;
          });
        }
      }
    }
  }

  Future<void> _dosenApprove(Task task) async {
    setState(() => _isProcessing = true);
    try {
      await Provider.of<TaskProvider>(
        context,
        listen: false,
      ).approveQuest(task.id, task.userId, task.xpReward);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quest approved successfully!'),
            backgroundColor: Color(0xFF4E7A51),
          ),
        );
        context.go('/tasks');
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to approve quest.'),
            backgroundColor: Color(0xFFB3492F),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _dosenReject(Task task) async {
    setState(() => _isProcessing = true);
    try {
      await Provider.of<TaskProvider>(
        context,
        listen: false,
      ).rejectQuest(task.id, task.userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quest rejected. Reverted to In Progress.'),
            backgroundColor: Color(0xFFC48A2D),
          ),
        );
        context.go('/tasks');
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
    final taskIndex = taskProvider.tasks.indexWhere(
      (t) =>
          t.id == widget.taskId &&
          (widget.studentUserId == null || t.userId == widget.studentUserId),
    );

    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quest Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/tasks'),
          ),
        ),
        body: const Center(child: Text('Quest not found!')),
      );
    }

    final task = taskProvider.tasks[taskIndex];
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

    final displayPhotoPath = _localPhotoPath ?? task.proofPhotoPath;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/tasks'),
        ),
        actions: [
          if (!isCompleted)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFB3492F)),
              onPressed: _isProcessing ? null : _deleteQuest,
              tooltip:
                  (authProvider.role == 'dosen' ||
                      authProvider.role == 'superadmin')
                  ? 'Delete Quest'
                  : 'Abandon Quest',
            ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Category',
                    task.category.toUpperCase(),
                    Icons.school,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Priority',
                    task.priority.toUpperCase(),
                    Icons.flag,
                    color: priorityColor,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Deadline',
                    '${task.deadline.day}/${task.deadline.month}/${task.deadline.year} ${task.deadline.hour.toString().padLeft(2, '0')}:${task.deadline.minute.toString().padLeft(2, '0')}',
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Status',
                    task.status.toUpperCase(),
                    isCompleted ? Icons.check_circle : Icons.hourglass_empty,
                    color: isCompleted ? const Color(0xFF4E7A51) : null,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'XP Reward',
                    '${task.xpReward} XP',
                    Icons.bolt,
                    color: const Color(0xFFC48A2D),
                  ),
                  if (authProvider.role == 'dosen' ||
                      authProvider.role == 'superadmin') ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(context, 'Student', () {
                      final student = authProvider.users.firstWhere(
                        (u) => u.id == task.userId,
                        orElse: () => UserEntity(
                          id: task.userId,
                          username: task.studentUsername ?? 'Student',
                          email: '',
                          role: 'mahasiswa',
                          createdAt: DateTime.now(),
                        ),
                      );
                      return student.username;
                    }(), Icons.person),
                  ],
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.description!,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  const SizedBox(height: 32),
                  // Proof of completion
                  Text(
                    'Proof of Completion',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9DE),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE3E0D6)),
                    ),
                    child: displayPhotoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: displayPhotoPath.startsWith('http')
                                ? Image.network(
                                    displayPhotoPath,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40,
                                                color: Color(0xFFB3492F),
                                              ),
                                            ),
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                          if (loadingProgress == null) {
                                            return child;
                                          }
                                          return const Center(
                                            child: CircularProgressIndicator(),
                                          );
                                        },
                                  )
                                : Image.file(
                                    File(displayPhotoPath),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Color(0xFF6B6862),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'No photo captured yet',
                                  style: TextStyle(color: Color(0xFF6B6862)),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                  if (task.status == 'completed')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4E7A51).withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF4E7A51)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF4E7A51)),
                          SizedBox(width: 8),
                          Text(
                            'Quest Completed!',
                            style: TextStyle(
                              color: Color(0xFF4E7A51),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (task.status == 'submitted')
                    authProvider.role == 'mahasiswa'
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFC48A2D).withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFC48A2D),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.hourglass_empty_rounded,
                                  color: Color(0xFFC48A2D),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Quest Submitted! Waiting for approval.',
                                  style: TextStyle(
                                    color: Color(0xFFC48A2D),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : () => _dosenReject(task),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color(0xFFB3492F),
                                  ),
                                  label: const Text(
                                    'Reject',
                                    style: TextStyle(color: Color(0xFFB3492F)),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Color(0xFFB3492F),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _isProcessing
                                      ? null
                                      : () => _dosenApprove(task),
                                  icon: const Icon(Icons.check_circle_rounded),
                                  label: const Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4E7A51),
                                  ),
                                ),
                              ),
                            ],
                          )
                  else
                    authProvider.role == 'mahasiswa'
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _capturePhoto,
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('Camera'),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _selectFromGallery,
                                      icon: const Icon(Icons.photo_library),
                                      label: const Text('Gallery'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _isProcessing
                                    ? null
                                    : () => _completeQuest(task),
                                icon: const Icon(Icons.check_circle),
                                label: const Text('Complete Quest'),
                              ),
                            ],
                          )
                        : Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B6862).withAlpha(30),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF6B6862),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  color: Color(0xFF6B6862),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Quest is active (student working on it)',
                                  style: TextStyle(
                                    color: Color(0xFF6B6862),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color ?? const Color(0xFF6B6862)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF6B6862),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
