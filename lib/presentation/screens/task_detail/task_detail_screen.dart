import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  Task? _task;
  String? _proofPhotoPath;
  bool _isCompleting = false;
  late CameraDatasource _cameraDatasource;

  @override
  void initState() {
    super.initState();
    _cameraDatasource = CameraDatasource(ImagePicker());
    _loadTask();
  }

  void _loadTask() {
    final taskProvider = context.read<TaskProvider>();
    try {
      _task = taskProvider.tasks.firstWhere((t) => t.id == widget.taskId);
      if (_task != null) {
        _proofPhotoPath = _task!.proofPhotoPath;
      }
    } catch (_) {
      _task = null;
    }
    setState(() {});
  }

  Future<void> _capturePhoto() async {
    final path = await _cameraDatasource.captureTaskProof();
    if (path != null) {
      setState(() => _proofPhotoPath = path);
    }
  }

  Future<void> _selectFromGallery() async {
    final path = await _cameraDatasource.selectTaskProofFromGallery();
    if (path != null) {
      setState(() => _proofPhotoPath = path);
    }
  }

  Future<void> _completeTask() async {
    if (_task == null) return;
    setState(() => _isCompleting = true);

    final now = DateTime.now();
    final updatedTask = _task!.copyWith(
      status: 'completed',
      completedAt: now,
      proofPhotoPath: _proofPhotoPath,
    );

    final charProvider = context.read<CharacterProvider>();
    final taskProvider2 = context.read<TaskProvider>();

    await taskProvider2.updateTask(updatedTask);

    final result = await charProvider.completeTask(_task!, now);

    if (!mounted) return;

    setState(() => _isCompleting = false);

    final xpGained = result['xpGained'] as int;
    final leveledUp = result['leveledUp'] as bool;

    if (leveledUp) {
      // Navigate back to dashboard to show the level-up animation
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quest Complete! +$xpGained XP · LEVEL UP! 🎉'),
          backgroundColor: const Color(0xFF4E7A51),
        ),
      );
      context.go('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quest Complete! +$xpGained XP gained!'),
          backgroundColor: const Color(0xFF4E7A51),
        ),
      );
      context.go('/tasks');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_task == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Quest Details'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/tasks'),
          ),
        ),
        body: const Center(child: Text('Task not found.')),
      );
    }

    final task = _task!;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quest Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/tasks'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(task.title, style: Theme.of(context).textTheme.displayMedium),
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
              '${task.deadline.day}/${task.deadline.month}/${task.deadline.year}',
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Status',
              task.status.toUpperCase(),
              Icons.hourglass_empty,
              color: isCompleted ? const Color(0xFF4E7A51) : null,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'XP Reward',
              '${task.xpReward} XP (base)',
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

            // Proof of completion (Camera)
            Text(
              'Proof of Completion',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            if (_proofPhotoPath != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(_proofPhotoPath!),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9DE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE3E0D6)),
                ),
                child: const Center(
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
            const SizedBox(height: 16),
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
                onPressed: _isCompleting ? null : _completeTask,
                icon: _isCompleting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle),
                label: Text(_isCompleting ? 'Completing...' : 'Complete Quest'),
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
