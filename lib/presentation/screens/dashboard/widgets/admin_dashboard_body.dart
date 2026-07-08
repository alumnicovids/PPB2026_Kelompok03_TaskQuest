import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/auth_provider.dart';
import '../../../../domain/entities/user_entity.dart';

class AdminDashboardBody extends StatefulWidget {
  const AdminDashboardBody({super.key});

  @override
  State<AdminDashboardBody> createState() => _AdminDashboardBodyState();
}

class _AdminDashboardBodyState extends State<AdminDashboardBody> {
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  void _loadAdminData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadAllUsers();
    });
  }

  Future<void> _handleChangeRole(UserEntity user, String newRole) async {
    if (user.role == newRole) return;
    setState(() => _isProcessing = true);
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.changeUserRole(user.id, newRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated role of "${user.username}" to $newRole.'),
            backgroundColor: const Color(0xFF4E7A51),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update user role.'),
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
    final allUsers = authProvider.users;

    final dosenCount = allUsers.where((u) => u.role == 'dosen').length;
    final mahasiswaCount = allUsers.where((u) => u.role == 'mahasiswa').length;

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
                  'Lecturers',
                  '$dosenCount',
                  Icons.supervised_user_circle_rounded,
                  const Color(0xFFC15F3C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Students',
                  '$mahasiswaCount',
                  Icons.school_rounded,
                  const Color(0xFF4E7A51),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Register Dosen quick action
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.person_add_rounded, color: Color(0xFFC15F3C)),
                      SizedBox(width: 12),
                      Text(
                        'Lecturer Registration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2B26),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'As SuperAdmin, you have exclusive permission to register official lecturer accounts.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B6862)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/register-dosen'),
                    child: const Text('Register Lecturer Account'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Avatar Manager quick action
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.photo_library_rounded,
                        color: Color(0xFFC15F3C),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Avatar Asset Manager',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2B26),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'As SuperAdmin, you can upload and replace kustom class avatar files stored in the cloud.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B6862)),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/character-avatars'),
                    child: const Text('Manage Cloud Avatars'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // User Management section
          Text(
            'User Management (${allUsers.length})',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 12),

          if (authProvider.isLoading && allUsers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (allUsers.isEmpty)
            const Center(
              child: Text(
                'No users registered in the system.',
                style: TextStyle(color: Color(0xFF6B6862)),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: allUsers.length,
              itemBuilder: (context, index) {
                final user = allUsers[index];
                return _buildUserManagementCard(context, user);
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

  Widget _buildUserManagementCard(BuildContext context, UserEntity user) {
    final currentRole = user.role;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2D2B26),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B6862),
                    ),
                  ),
                ],
              ),
            ),
            DropdownButton<String>(
              value: currentRole,
              underline: const SizedBox(),
              iconEnabledColor: const Color(0xFFC15F3C),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFC15F3C),
              ),
              items: const [
                DropdownMenuItem(value: 'mahasiswa', child: Text('Mahasiswa')),
                DropdownMenuItem(value: 'dosen', child: Text('Dosen')),
                DropdownMenuItem(
                  value: 'superadmin',
                  child: Text('SuperAdmin'),
                ),
              ],
              onChanged: _isProcessing
                  ? null
                  : (newRole) {
                      if (newRole != null) {
                        _handleChangeRole(user, newRole);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }
}
