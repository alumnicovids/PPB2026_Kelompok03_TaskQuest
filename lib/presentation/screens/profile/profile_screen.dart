import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/character_asset_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/character_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final charProvider = Provider.of<CharacterProvider>(context);
    final username = authProvider.username ?? 'Hero';
    final character = charProvider.character;
    final role = authProvider.role ?? 'mahasiswa';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).colorScheme.primary;

    if (_isLoggingOut) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.ancientGold),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Hero Banner ───────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.dungeonBlack, AppColors.obsidian],
                      )
                    : const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [AppColors.oldMap, AppColors.agedParchment],
                      ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.agedBorder
                        : AppColors.parchmentBorder,
                    width: 1,
                  ),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: Column(
                children: [
                  // Avatar with gold ring
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.ancientGold,
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ancientGold.withAlpha(60),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: isDark
                          ? AppColors.weatheredStone
                          : AppColors.oldMap,
                      child: character != null && role == 'mahasiswa'
                          ? ClipOval(
                              child: Image.asset(
                                CharacterAssetHelper.getAssetPath(
                                  character.classType.toLowerCase(),
                                  character.appearanceStage,
                                ),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    _classIcon(character.classType),
                                    size: 52,
                                    color: AppColors.ancientGold,
                                  );
                                },
                              ),
                            )
                          : const Icon(
                              Icons.person_rounded,
                              size: 52,
                              color: AppColors.ancientGold,
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Username
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.goldShimmerGradient.createShader(bounds),
                    child: Text(
                      username,
                      style: const TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.ancientGold.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.ancientGold.withAlpha(120),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      role == 'superadmin'
                          ? '👑 Super Admin'
                          : role == 'dosen'
                          ? '🎓 Lecturer'
                          : '⚔ Adventurer',
                      style: const TextStyle(
                        color: AppColors.ancientGold,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                  // Character info (mahasiswa only)
                  if (character != null && role == 'mahasiswa') ...[
                    const SizedBox(height: 16),
                    _buildCharacterStatsRow(character, isDark),
                  ],
                ],
              ),
            ),

            // ── Menu Section ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section header
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 8),
                    child: Text(
                      'TAVERN MENU',
                      style: TextStyle(
                        fontFamily: 'Cinzel',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: primary,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  // Menu card
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkStone : AppColors.vellum,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark
                            ? AppColors.agedBorder
                            : AppColors.parchmentBorder,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        _buildMenuItem(
                          context,
                          icon: Icons.map_rounded,
                          iconColor: AppColors.forestDeep,
                          label: 'Study Locations Map',
                          subtitle: 'Find places to study or consult',
                          onTap: () => context.push('/locations'),
                          isDark: isDark,
                          showDivider: true,
                        ),
                        _buildMenuItem(
                          context,
                          icon: Icons.settings_outlined,
                          iconColor: isDark
                              ? AppColors.fadedInk
                              : AppColors.brownInk,
                          label: 'Settings',
                          subtitle: 'Theme, account & preferences',
                          onTap: () => context.push('/settings'),
                          isDark: isDark,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Logout button ───────────────────────────────────────
                  OutlinedButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.dangerRed,
                    ),
                    label: const Text(
                      'Leave the Realm',
                      style: TextStyle(color: AppColors.dangerRed),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.dangerRed),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
          if (index == 1) context.go('/tasks');
        },
      ),
    );
  }

  Widget _buildCharacterStatsRow(dynamic character, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.weatheredStone.withAlpha(180)
            : AppColors.parchmentBorder.withAlpha(80),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? AppColors.agedBorder : AppColors.parchmentBorder,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            '⚔',
            character.classType[0].toUpperCase() +
                character.classType.substring(1),
            'Class',
          ),
          _buildStatDivider(isDark),
          _buildStat('Lv.', '${character.level}', 'Level'),
          _buildStatDivider(isDark),
          _buildStat('★', '${character.currentXp}', 'XP'),
          _buildStatDivider(isDark),
          _buildStat('◆', '${character.appearanceStage}', 'Stage'),
        ],
      ),
    );
  }

  Widget _buildStat(String prefix, String value, String label) {
    return Column(
      children: [
        Text(
          '$prefix $value',
          style: const TextStyle(
            fontFamily: 'Cinzel',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.ancientGold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 10,
            color: AppColors.dustyScript,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(bool isDark) {
    return Container(
      height: 28,
      width: 1,
      color: isDark ? AppColors.agedBorder : AppColors.parchmentBorder,
    );
  }

  IconData _classIcon(String classType) {
    switch (classType.toLowerCase()) {
      case 'mage':
        return Icons.auto_stories_rounded;
      case 'archer':
        return Icons.gps_fixed_rounded;
      case 'assassin':
        return Icons.bolt_rounded;
      default:
        return Icons.shield_rounded;
    }
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    required bool showDivider,
  }) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              color: AppColors.dustyScript,
            ),
          ),
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? AppColors.dustyScript : AppColors.brownInk,
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: isDark ? AppColors.ironGray : AppColors.parchmentBorder,
          ),
      ],
    );
  }
}
