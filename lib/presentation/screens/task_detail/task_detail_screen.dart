import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/datasources/local/camera_datasource.dart';
import '../../../domain/entities/task.dart';
import '../../providers/character_provider.dart';
import '../../providers/task_provider.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

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
        const SnackBar(content: Text('Please capture or select a photo proof first!')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final completedAt = DateTime.now();
      final updatedTask = task.copyWith(
        status: 'completed',
        completedAt: completedAt,
        proofPhotoPath: _localPhotoPath ?? task.proofPhotoPath,
      );

      // 1. Update task in TaskProvider
      await Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);

      if (!mounted) return;

      // 2. Add XP in CharacterProvider
      final result = await Provider.of<CharacterProvider>(context, listen: false)
          .completeTask(updatedTask, completedAt);

      final xpGained = result['xpGained'] as int;
      final leveledUp = result['leveledUp'] as bool;

      if (!mounted) return;

      // 3. Show dialog detailing rewards
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  leveledUp ? Icons.celebration_rounded : Icons.offline_bolt_rounded,
                  color: const Color(0xFFC15F3C),
                ),
                const SizedBox(width: 8),
                Text(leveledUp ? 'Level Up!' : 'Quest Cleared!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('XP Gained: +$xpGained XP'),
                if (leveledUp) ...[
                  const SizedBox(height: 8),
                  const Text('Congratulations! Your character has grown stronger!'),
                  const SizedBox(height: 8),
                  const Text(
                    'Tip: Rotate your phone to control the level-up energy!',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                      color: Color(0xFFC15F3C),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  if (leveledUp) {
                    context.go('/level-up');
                  } else {
                    context.go('/tasks');
                  }
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to complete quest: $e')),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Quest'),
        content: const Text('Are you sure you want to abandon this quest?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB3492F)),
            child: const Text('Abandon'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _isProcessing = true;
      });
      try {
        await Provider.of<TaskProvider>(context, listen: false).deleteTask(widget.taskId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quest abandoned.')),
          );
          context.go('/tasks');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete quest: $e')),
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
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final taskIndex = taskProvider.tasks.indexWhere((t) => t.id == widget.taskId);

    if (taskIndex == -1) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quest Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/tasks'),
          ),
        ),
        body: const Center(
          child: Text('Quest not found!'),
        ),
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
              tooltip: 'Abandon Quest',
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
                  _buildDetailRow(context, 'Category', task.category.toUpperCase(), Icons.school),
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
                  if (task.description != null && task.description!.isNotEmpty) ...[
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
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Icon(Icons.broken_image, size: 40, color: Color(0xFFB3492F)),
                                    ),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(child: CircularProgressIndicator());
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
                                Icon(Icons.camera_alt, size: 40, color: Color(0xFF6B6862)),
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
                  if (!isCompleted) ...[
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
                      onPressed: _isProcessing ? null : () => _completeQuest(task),
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Complete Quest'),
                    ),
                  ] else
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
