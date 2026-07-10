import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskquest/main.dart';
import 'package:taskquest/presentation/providers/theme_provider.dart';
import 'package:taskquest/domain/repositories/task_repository.dart';
import 'package:taskquest/domain/repositories/auth_repository.dart';
import 'package:taskquest/domain/repositories/character_repository.dart';
import 'package:taskquest/domain/repositories/location_repository.dart';
import 'package:taskquest/domain/repositories/quotes_repository.dart';
import 'package:taskquest/domain/usecases/get_random_quote_use_case.dart';
import 'package:taskquest/presentation/providers/auth_provider.dart';
import 'package:taskquest/presentation/providers/task_provider.dart';
import 'package:taskquest/presentation/providers/character_provider.dart';
import 'package:taskquest/domain/usecases/calculate_xp_use_case.dart';
import 'package:taskquest/domain/usecases/level_up_use_case.dart';
import 'package:taskquest/domain/usecases/approve_task_use_case.dart';
import 'package:taskquest/domain/entities/task.dart';
import 'package:taskquest/domain/entities/user_entity.dart';
import 'package:taskquest/domain/entities/character.dart';
import 'package:taskquest/domain/entities/study_location.dart';
import 'package:taskquest/domain/entities/xp_log.dart';
import 'package:taskquest/domain/repositories/xp_log_repository.dart';

class FakeTaskRepository implements TaskRepository {
  @override
  Future<void> createTask(Task task) async {}
  @override
  Future<List<Task>> getTasks(String userId) async => [];
  @override
  Future<Task?> getTaskById(String taskId) async => null;
  @override
  Future<void> updateTask(Task task) async {}
  @override
  Future<void> deleteTask(String taskId) async {}
  @override
  Future<void> syncTasks(String userId) async {}
  @override
  Future<List<Task>> getAllTasks() async => [];
  @override
  Future<List<Task>> getSubmittedTasks() async => [];
  @override
  Future<void> approveTask(String taskId, String studentUserId) async {}
  @override
  Future<void> rejectTask(String taskId, String studentUserId) async {}
}

class FakeAuthRepository implements AuthRepository {
  @override
  Future<bool> login(String username, String password) async => false;
  @override
  Future<bool> register(String username, String email, String password) async =>
      false;
  @override
  Future<bool> registerDosen(
    String username,
    String email,
    String password,
  ) async => false;
  @override
  Future<void> logout() async {}
  @override
  bool isLoggedIn() => false;
  @override
  String? getUserId() => null;
  @override
  String? getUsername() => null;
  @override
  String? getRole() => null;
  @override
  Future<List<UserEntity>> getAllUsers() async => [];
  @override
  Future<List<UserEntity>> getUsersByRole(String role) async => [];
  @override
  Future<void> updateUserRole(String userId, String role) async {}
  @override
  Future<void> updateUsername(String userId, String newUsername) async {}
}

class FakeCharacterRepository implements CharacterRepository {
  @override
  Future<Character?> getCharacter(String userId) async => null;
  @override
  Future<void> saveCharacter(Character character) async {}
  @override
  Future<List<Character>> getAllCharacters() async => [];
  @override
  Future<String> uploadCharacterAvatar(
    String localPath,
    String fileName,
  ) async => '';
}

class FakeLocationRepository implements LocationRepository {
  @override
  Future<void> saveLocation(StudyLocation location) async {}
  @override
  Future<List<StudyLocation>> getLocations(String userId) async => [];
  @override
  Future<void> deleteLocation(String id) async {}
  @override
  Future<void> syncLocations(String userId) async {}
}

class FakeXpLogRepository implements XpLogRepository {
  @override
  Future<void> saveXpLog(XpLog xpLog) async {}
  @override
  Future<List<XpLog>> getXpLogs(String userId) async => [];
  @override
  Future<void> syncXpLogs(String userId) async {}
}

class FakeQuotesRepository implements QuotesRepository {
  @override
  Future<Map<String, String>> getRandomQuote() async => {
    'quote': 'Do not watch the clock; do what it does. Keep going.',
    'author': 'Sam Levenson',
  };
}

void main() {
  testWidgets('App renders login screen initially', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPrefs = await SharedPreferences.getInstance();
    final themeProvider = ThemeProvider(sharedPrefs);

    final taskRepo = FakeTaskRepository();
    final authRepo = FakeAuthRepository();
    final charRepo = FakeCharacterRepository();
    final locRepo = FakeLocationRepository();
    final xpLogRepo = FakeXpLogRepository();
    final quotesRepo = FakeQuotesRepository();
    final getRandomQuoteUseCase = GetRandomQuoteUseCase(quotesRepo);
    final approveTaskUseCase = ApproveTaskUseCase(
      taskRepository: taskRepo,
      characterRepository: charRepo,
      xpLogRepository: xpLogRepo,
      calculateXpUseCase: CalculateXpUseCase(),
      levelUpUseCase: LevelUpUseCase(),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<TaskRepository>.value(value: taskRepo),
          Provider<AuthRepository>.value(value: authRepo),
          Provider<CharacterRepository>.value(value: charRepo),
          Provider<LocationRepository>.value(value: locRepo),
          Provider<XpLogRepository>.value(value: xpLogRepo),
          Provider<GetRandomQuoteUseCase>.value(value: getRandomQuoteUseCase),
          ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
          ChangeNotifierProvider(create: (_) => AuthProvider(authRepo)),
          ChangeNotifierProvider(
            create: (_) => TaskProvider(taskRepo, approveTaskUseCase),
          ),
          ChangeNotifierProvider(
            create: (_) => CharacterProvider(
              CharacterProviderParams(
                calculateXpUseCase: CalculateXpUseCase(),
                levelUpUseCase: LevelUpUseCase(),
                characterRepository: charRepo,
                xpLogRepository: xpLogRepo,
                sharedPreferences: sharedPrefs,
              ),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('TaskQuest'), findsOneWidget);
    expect(find.text('Enter Gate'), findsOneWidget);
  });
}
