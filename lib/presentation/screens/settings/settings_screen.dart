// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  bool _isSavingUsername = false;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _usernameController = TextEditingController(
      text: authProvider.username ?? '',
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _saveUsername() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSavingUsername = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.changeUsername(_usernameController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username updated successfully!'),
            backgroundColor: Color(0xFF4E7A51),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update username: $e'),
            backgroundColor: Color(0xFFC62828),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingUsername = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentRole = authProvider.role ?? 'mahasiswa';
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section: Profile Settings
            Text(
              'Profile Settings',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: primaryColor),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Display Name / Username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a valid display name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _isSavingUsername ? null : _saveUsername,
                        icon: _isSavingUsername
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Icon(Icons.save_rounded),
                        label: const Text('Save Display Name'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Appearance (Theme)
            Text(
              'Appearance',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: primaryColor),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    RadioListTile<ThemeMode>(
                      title: const Text('System Default'),
                      subtitle: const Text(
                        'Matches system appearance settings',
                      ),
                      value: ThemeMode.system,
                      groupValue: themeProvider.themeMode,
                      activeColor: primaryColor,
                      onChanged: (mode) {
                        if (mode != null) themeProvider.setThemeMode(mode);
                      },
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    RadioListTile<ThemeMode>(
                      title: const Text('Light Mode'),
                      subtitle: const Text(
                        'Parchment by day — classic RPG scroll',
                      ),
                      value: ThemeMode.light,
                      groupValue: themeProvider.themeMode,
                      activeColor: primaryColor,
                      onChanged: (mode) {
                        if (mode != null) themeProvider.setThemeMode(mode);
                      },
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    RadioListTile<ThemeMode>(
                      title: const Text('Dark Mode'),
                      subtitle: const Text(
                        'Dungeon dark — for night adventuring',
                      ),
                      value: ThemeMode.dark,
                      groupValue: themeProvider.themeMode,
                      activeColor: primaryColor,
                      onChanged: (mode) {
                        if (mode != null) themeProvider.setThemeMode(mode);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section: Account Info / Role Info
            Text(
              'Account Information',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: primaryColor),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context,
                      'Role',
                      currentRole.toUpperCase(),
                      Icons.shield_outlined,
                    ),
                    Divider(height: 20, color: Theme.of(context).dividerColor),
                    _buildInfoRow(
                      context,
                      'User ID',
                      authProvider.userId ?? '-',
                      Icons.tag,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final secondaryColor = Theme.of(context).textTheme.bodyMedium?.color;
    return Row(
      children: [
        Icon(icon, size: 22, color: secondaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: secondaryColor,
            fontFamily: 'Inter',
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
