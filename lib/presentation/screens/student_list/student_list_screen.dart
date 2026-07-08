import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/character_provider.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/entities/character.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadUsersByRole('mahasiswa');
      Provider.of<CharacterProvider>(context, listen: false).loadAllCharacters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final characterProvider = Provider.of<CharacterProvider>(context);

    final students = authProvider.users;
    final characters = characterProvider.allCharacters;

    // Filter students based on search query
    final filteredStudents = students.where((student) {
      final username = student.username.toLowerCase();
      final email = student.email.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return username.contains(query) || email.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: authProvider.isLoading || characterProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search students by name or email...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFFC15F3C)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Results Header
                  Text(
                    'Students Found (${filteredStudents.length})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B6862),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Student List
                  Expanded(
                    child: filteredStudents.isEmpty
                        ? Center(
                            child: Text(
                              _searchQuery.isEmpty
                                  ? 'No students registered.'
                                  : 'No students match your search.',
                              style: const TextStyle(color: Color(0xFF6B6862)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredStudents.length,
                            itemBuilder: (context, index) {
                              final student = filteredStudents[index];
                              // Find student character
                              final character = characters.firstWhere(
                                (c) => c.userId == student.id,
                                orElse: () => Character(
                                  id: '',
                                  userId: student.id,
                                  classType: 'knight',
                                  level: 1,
                                  currentXp: 0,
                                  xpToNextLevel: 100,
                                  appearanceStage: 1,
                                  updatedAt: DateTime.now(),
                                ),
                              );

                              return _buildStudentCard(context, student, character);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    UserEntity student,
    Character character,
  ) {
    final classType = character.classType.toLowerCase();
    final IconData classIcon = classType == 'mage'
        ? Icons.auto_stories_rounded
        : classType == 'archer'
            ? Icons.gps_fixed_rounded
            : classType == 'assassin'
                ? Icons.bolt_rounded
                : Icons.shield_rounded;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Class Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFEDE9DE),
              child: Icon(
                classIcon,
                size: 28,
                color: const Color(0xFFC15F3C),
              ),
            ),
            const SizedBox(width: 16),

            // Student details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.username,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2B26),
                    ),
                  ),
                  Text(
                    student.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B6862),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // RPG Level & Class badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE9DE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          classType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFC15F3C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Level ${character.level} (Stage ${character.appearanceStage})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2B26),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // XP progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: character.xpToNextLevel > 0
                                ? character.currentXp / character.xpToNextLevel
                                : 0,
                            backgroundColor: const Color(0xFFEDE9DE),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFC15F3C),
                            ),
                            minHeight: 4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${character.currentXp}/${character.xpToNextLevel} XP',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF6B6862),
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
    );
  }
}
