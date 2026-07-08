import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/character_provider.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final _usernameController = TextEditingController();
  String _selectedClass = 'knight';
  bool _isProcessing = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _classes = [
    {
      'id': 'knight',
      'name': 'Knight',
      'icon': Icons.shield_rounded,
      'desc': 'Ksatria dengan pertahanan kokoh, siap menghadapi rintangan akademik dengan kedisiplinan dan ketangguhan tinggi.',
    },
    {
      'id': 'mage',
      'name': 'Mage',
      'icon': Icons.auto_stories_rounded,
      'desc': 'Penyihir dengan pengetahuan luas, memecahkan masalah kompleks dan tugas sulit menggunakan kecerdasan analitis.',
    },
    {
      'id': 'archer',
      'name': 'Archer',
      'icon': Icons.gps_fixed_rounded,
      'desc': 'Pemanah dengan akurasi tinggi, selalu fokus dan tepat sasaran pada target pencapaian nilai serta tepat waktu.',
    },
    {
      'id': 'assassin',
      'name': 'Assassin',
      'icon': Icons.bolt_rounded,
      'desc': 'Pembunuh bayangan dengan kecepatan kilat, bertindak cepat, efisien, dan andal menyelesaikan misi dalam waktu singkat.',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      _usernameController.text = authProvider.username ?? '';
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final newUsername = _usernameController.text.trim();
    if (newUsername.isEmpty) {
      setState(() {
        _errorMessage = 'Username cannot be empty';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final characterProvider = Provider.of<CharacterProvider>(context, listen: false);
      final userId = authProvider.userId;

      if (userId != null) {
        // 1. Update username if changed
        if (newUsername != authProvider.username) {
          await authProvider.changeUsername(newUsername);
        }

        // 2. Create character
        await characterProvider.createInitialCharacter(userId, _selectedClass);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Hero setup complete! Let the adventure begin!'),
              backgroundColor: Color(0xFF4E7A51),
            ),
          );
          context.go('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to setup profile: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedClassData = _classes.firstWhere((c) => c['id'] == _selectedClass);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup Hero Profile'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Customize Your Hero',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2B26),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose your username and class to start your academic adventure.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B6862),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3492F).withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFB3492F)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Color(0xFFB3492F)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Username input card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hero Username',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2B26),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your hero name',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Character selector title
              const Text(
                'Choose Class Type',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2B26),
                ),
              ),
              const SizedBox(height: 12),

              // Classes selection grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                itemCount: _classes.length,
                itemBuilder: (context, index) {
                  final item = _classes[index];
                  final isSelected = item['id'] == _selectedClass;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedClass = item['id'] as String;
                      });
                    },
                    child: Card(
                      color: isSelected ? const Color(0xFFC15F3C) : const Color(0xFFFAF9F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected ? const Color(0xFFC15F3C) : const Color(0xFFE3E0D6),
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 32,
                              color: isSelected ? Colors.white : const Color(0xFFC15F3C),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['name'] as String,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: isSelected ? Colors.white : const Color(0xFF2D2B26),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Class Description Card
              Card(
                color: const Color(0xFFEDE9DE).withAlpha(120),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            selectedClassData['icon'] as IconData,
                            color: const Color(0xFFC15F3C),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            selectedClassData['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF2D2B26),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selectedClassData['desc'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B6862),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_isProcessing)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _handleSave,
                  child: const Text('Start Adventure!'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
