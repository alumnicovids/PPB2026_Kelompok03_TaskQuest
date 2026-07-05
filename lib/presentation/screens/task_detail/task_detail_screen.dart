import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TaskDetailScreen extends StatelessWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Laporan Praktikum Pemrograman Mobile',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            _buildDetailRow(context, 'Category', 'KULIAH', Icons.school),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Priority',
              'HIGH',
              Icons.flag,
              color: const Color(0xFFB3492F),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Deadline',
              '5 July 2026, 23:59',
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              context,
              'Status',
              'PENDING',
              Icons.hourglass_empty,
            ),
            const SizedBox(height: 24),
            Text(
              'Quest Description',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Menyelesaikan modul 5 praktikum mengenai SQLite Local Database dan SharedPreferences Session. Wajib dilampirkan screenshot aplikasi yang berjalan di emulator/device.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            // Proof of completion placeholder (Camera requirement)
            Text(
              'Proof of Completion',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
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
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mock: Capture photo using camera'),
                  ),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Photo Proof'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B6862),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mock: Quest completed! +35 XP Gained!'),
                  ),
                );
                context.go('/dashboard');
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Complete Quest'),
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
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
