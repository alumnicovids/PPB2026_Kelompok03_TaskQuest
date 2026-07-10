import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/gyroscope_service.dart';
import '../../../domain/usecases/get_random_quote_use_case.dart';
import '../../../core/utils/character_asset_helper.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/character_provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/level_up_animation.dart';
import 'widgets/admin_dashboard_body.dart';
import 'widgets/lecturer_dashboard_body.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, String>? _quote;
  bool _isLoadingQuote = true;
  GyroscopeService? _gyroscopeService;
  bool _showLevelUpOverlay = false;
  int _levelUpLevel = 1;
  int _xpGained = 0;
  final GlobalKey<LevelUpAnimationWidgetState> _animKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadData();
    _fetchQuote();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.role == 'mahasiswa') {
      _gyroscopeService = GyroscopeService();
      _gyroscopeService!.startListening();
      _gyroscopeService!.addListener(_onGyroUpdate);
    }
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.userId;
      if (userId != null) {
        final role = authProvider.role ?? 'mahasiswa';
        if (role == 'mahasiswa') {
          final charProvider = Provider.of<CharacterProvider>(
            context,
            listen: false,
          );
          final taskProvider = Provider.of<TaskProvider>(
            context,
            listen: false,
          );

          // Check if there is already a pending level up from login screen
          if (charProvider.pendingLevelUpLevel != null) {
            final pendingLevel = charProvider.pendingLevelUpLevel!;
            charProvider.consumeLevelUp();
            _triggerLevelUpOverlay(pendingLevel, 0);
          }

          // Load cached character first for quick display
          await charProvider.loadCharacter(userId);
          taskProvider.loadTasks(userId);

          // Sync tasks from remote
          await taskProvider.syncTasks(userId, role: role);

          // After sync, refresh character from remote to pick up any XP changes
          // made by dosen approval
          if (mounted) {
            await charProvider.loadCharacter(userId);
            if (charProvider.pendingLevelUpLevel != null) {
              final pendingLevel = charProvider.pendingLevelUpLevel!;
              charProvider.consumeLevelUp();
              _triggerLevelUpOverlay(pendingLevel, 0);
            }
          }
        } else if (role == 'dosen') {
          Provider.of<AuthProvider>(
            context,
            listen: false,
          ).loadUsersByRole('mahasiswa');
          Provider.of<TaskProvider>(
            context,
            listen: false,
          ).loadSubmittedTasks();
          Provider.of<TaskProvider>(
            context,
            listen: false,
          ).syncTasks(userId, role: role);
        } else if (role == 'superadmin') {
          Provider.of<AuthProvider>(context, listen: false).loadAllUsers();
        }
      }
    });
  }

  Future<void> _fetchQuote() async {
    if (!mounted) return;
    setState(() {
      _isLoadingQuote = true;
    });
    try {
      final getRandomQuoteUseCase = Provider.of<GetRandomQuoteUseCase>(
        context,
        listen: false,
      );
      final quote = await getRandomQuoteUseCase.execute();
      if (mounted) {
        setState(() {
          _quote = quote;
          _isLoadingQuote = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingQuote = false;
        });
      }
    }
  }

  void _onGyroUpdate() {
    if (_showLevelUpOverlay && _gyroscopeService != null) {
      _animKey.currentState?.applyGyroTilt(
        _gyroscopeService!.x,
        _gyroscopeService!.y,
      );
    }
  }

  void _triggerLevelUpOverlay(int newLevel, int xp) {
    setState(() {
      _showLevelUpOverlay = true;
      _levelUpLevel = newLevel;
      _xpGained = xp;
    });
  }

  Future<void> _syncData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;
    if (userId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Syncing with remote database...')),
      );

      final role = authProvider.role ?? 'mahasiswa';
      if (role == 'mahasiswa') {
        final charProvider = Provider.of<CharacterProvider>(
          context,
          listen: false,
        );

        await Provider.of<TaskProvider>(
          context,
          listen: false,
        ).syncTasks(userId, role: role);
        if (mounted) {
          await charProvider.loadCharacter(userId);
          if (charProvider.pendingLevelUpLevel != null) {
            final pendingLevel = charProvider.pendingLevelUpLevel!;
            charProvider.consumeLevelUp();
            _triggerLevelUpOverlay(pendingLevel, 0);
          }
        }
      } else if (role == 'dosen') {
        await Provider.of<TaskProvider>(
          context,
          listen: false,
        ).loadSubmittedTasks();
        if (mounted) {
          await Provider.of<AuthProvider>(
            context,
            listen: false,
          ).loadUsersByRole('mahasiswa');
        }
      } else if (role == 'superadmin') {
        await Provider.of<AuthProvider>(context, listen: false).loadAllUsers();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data synced successfully!')),
        );
      }
    }
  }

  @override
  void dispose() {
    if (_gyroscopeService != null) {
      _gyroscopeService!.removeListener(_onGyroUpdate);
      _gyroscopeService!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final role = authProvider.role ?? 'mahasiswa';

    if (role == 'dosen') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync_rounded),
              onPressed: _syncData,
              tooltip: 'Sync data',
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => context.go('/profile'),
              tooltip: 'Profile',
            ),
          ],
        ),
        body: const LecturerDashboardBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          selectedItemColor: const Color(0xFFC15F3C),
          unselectedItemColor: const Color(0xFF6B6862),
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
            if (index == 1) context.go('/tasks');
            if (index == 2) context.go('/profile');
          },
        ),
      );
    }

    if (role == 'superadmin') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.sync_rounded),
              onPressed: _syncData,
              tooltip: 'Sync data',
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () => context.go('/profile'),
              tooltip: 'Profile',
            ),
          ],
        ),
        body: const AdminDashboardBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
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
            if (index == 1) context.go('/tasks');
            if (index == 2) context.go('/profile');
          },
        ),
      );
    }

    final characterProvider = Provider.of<CharacterProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);

    final character = characterProvider.character;

    if (role == 'mahasiswa' &&
        character == null &&
        !characterProvider.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/setup-profile');
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final username = authProvider.username ?? 'Hero';
    final tasks = taskProvider.tasks;

    final activeQuests = tasks.where((t) => t.status != 'completed').length;
    final completedQuests = tasks.where((t) => t.status == 'completed').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: _syncData,
            tooltip: 'Sync data',
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              _loadData();
              await _fetchQuote();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome Text
                  Text(
                    'Welcome back, $username!',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.ancientGold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Character Card
                  if (characterProvider.isLoading && character == null)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (character != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: AppColors.weatheredStone,
                              child: ClipOval(
                                child: Image.asset(
                                  CharacterAssetHelper.getAssetPath(
                                    character.classType.toLowerCase(),
                                    character.appearanceStage,
                                  ),
                                  fit: BoxFit.cover,
                                  width: 80,
                                  height: 80,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      character.classType.toLowerCase() ==
                                              'mage'
                                          ? Icons.auto_stories_rounded
                                          : character.classType.toLowerCase() ==
                                                'archer'
                                          ? Icons.gps_fixed_rounded
                                          : character.classType.toLowerCase() ==
                                                'assassin'
                                          ? Icons.bolt_rounded
                                          : Icons.shield_rounded,
                                      size: 40,
                                      color: AppColors.ancientGold,
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${character.classType[0].toUpperCase()}${character.classType.substring(1)} Hero',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.displaySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Level ${character.level} (Stage ${character.appearanceStage})',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.ancientGold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  // XP Progress Bar
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: character.xpToNextLevel > 0
                                                ? character.currentXp /
                                                      character.xpToNextLevel
                                                : 0.0,
                                            minHeight: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${character.currentXp}/${character.xpToNextLevel} XP',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // Gyroscope live indicator
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListenableBuilder(
                        listenable: _gyroscopeService!,
                        builder: (context, _) {
                          return Row(
                            children: [
                              const Icon(
                                Icons.screen_rotation,
                                color: AppColors.ancientGold,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Gyroscope Active',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'x: ${_gyroscopeService!.x.toStringAsFixed(2)}  '
                                    'y: ${_gyroscopeService!.y.toStringAsFixed(2)}  '
                                    'z: ${_gyroscopeService!.z.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: AppColors.dustyScript,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quote of the Day
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _isLoadingQuote
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.ancientGold,
                              ),
                            )
                          : Column(
                              children: [
                                const Text(
                                  '✦  ORACLE OF THE DAY  ✦',
                                  style: TextStyle(
                                    fontFamily: 'Cinzel',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ancientGold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _quote?['quote'] ??
                                      'A hero is forged through action, not intention.',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontStyle: FontStyle.italic,
                                    fontSize: 14,
                                    height: 1.5,
                                    color: AppColors.fadedInk,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '— ${_quote?['author'] ?? 'Unknown Sage'}',
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: AppColors.dustyScript,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Stats
                  Text(
                    'Your Quest Stats',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildStatCard(
                        context,
                        'Active Quests',
                        '$activeQuests',
                        Icons.directions_run,
                      ),
                      _buildStatCard(
                        context,
                        'Completed',
                        '$completedQuests',
                        Icons.task_alt,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Call to Action
                  ElevatedButton.icon(
                    onPressed: () => context.go('/tasks'),
                    icon: const Icon(Icons.list_alt_rounded),
                    label: const Text('View Quest Board (Task List)'),
                  ),
                ],
              ),
            ),
          ),
          if (_showLevelUpOverlay)
            Positioned.fill(
              child: LevelUpAnimationWidget(
                key: _animKey,
                newLevel: _levelUpLevel,
                xpGained: _xpGained,
                onAnimationEnd: () {
                  setState(() => _showLevelUpOverlay = false);
                },
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
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
          if (index == 1) context.go('/tasks');
          if (index == 2) context.go('/profile');
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.ancientGold),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.displaySmall),
            Text(title, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
