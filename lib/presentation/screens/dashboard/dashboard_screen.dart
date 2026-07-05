import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/gyroscope_service.dart';
import '../../providers/character_provider.dart';
import '../../widgets/level_up_animation.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late GyroscopeService _gyroscopeService;
  bool _showLevelUpOverlay = false;
  int _levelUpLevel = 1;
  int _xpGained = 0;
  final GlobalKey<LevelUpAnimationWidgetState> _animKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _gyroscopeService = GyroscopeService();
    _gyroscopeService.startListening();
    _gyroscopeService.addListener(_onGyroUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharacterProvider>().loadMockCharacter('mock-user-id');
    });
  }

  void _onGyroUpdate() {
    if (_showLevelUpOverlay) {
      _animKey.currentState?.applyGyroTilt(
        _gyroscopeService.x,
        _gyroscopeService.y,
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

  @override
  void dispose() {
    _gyroscopeService.removeListener(_onGyroUpdate);
    _gyroscopeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
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

  Widget _buildBody() {
    return Consumer<CharacterProvider>(
      builder: (context, charProvider, _) {
        final character = charProvider.character;
        final level = character?.level ?? 1;
        final currentXp = character?.currentXp ?? 0;
        final xpToNext = character?.xpToNextLevel ?? 100;
        final classType = character?.classType ?? 'knight';
        final stage = character?.appearanceStage ?? 1;

        final IconData classIcon = classType == 'mage'
            ? Icons.auto_fix_high
            : classType == 'archer'
            ? Icons.track_changes
            : Icons.shield_rounded;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Character Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFE0A98C),
                        child: Icon(
                          classIcon,
                          size: 40,
                          color: const Color(0xFFC15F3C),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classType[0].toUpperCase() +
                                  classType.substring(1),
                              style: Theme.of(context).textTheme.displaySmall,
                            ),
                            Text(
                              'Level $level · Stage $stage',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: const Color(0xFF6B6862)),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: xpToNext > 0
                                          ? currentXp / xpToNext
                                          : 0,
                                      backgroundColor: const Color(0xFFEDE9DE),
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                            Color(0xFFC15F3C),
                                          ),
                                      minHeight: 8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$currentXp / $xpToNext XP',
                                  style: const TextStyle(fontSize: 12),
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
                    listenable: _gyroscopeService,
                    builder: (context, _) {
                      return Row(
                        children: [
                          const Icon(
                            Icons.screen_rotation,
                            color: Color(0xFFC15F3C),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gyroscope Active',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'x: ${_gyroscopeService.x.toStringAsFixed(2)}  '
                                'y: ${_gyroscopeService.y.toStringAsFixed(2)}  '
                                'z: ${_gyroscopeService.z.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B6862),
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

              Text(
                'Quest Stats',
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
                    'Current Level',
                    '$level',
                    Icons.emoji_events,
                  ),
                  _buildStatCard(
                    context,
                    'XP Progress',
                    '$currentXp XP',
                    Icons.bolt,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: () => _triggerLevelUpOverlay(level + 1, 35),
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Simulate Level Up!'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4E7A51),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: () => context.go('/tasks'),
                icon: const Icon(Icons.list_alt_rounded),
                label: const Text('View Quest Board'),
              ),
            ],
          ),
        );
      },
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
            Icon(icon, color: const Color(0xFFC15F3C)),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.displaySmall),
            Text(title, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
