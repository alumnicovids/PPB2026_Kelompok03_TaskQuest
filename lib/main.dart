import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/local/sqlite_helper.dart';
import 'data/datasources/local/sqlite_task_datasource.dart';
import 'data/datasources/remote/supabase_remote_datasource.dart';
import 'data/repositories/task_repository_impl.dart';
import 'domain/repositories/task_repository.dart';
import 'domain/usecases/calculate_xp_use_case.dart';
import 'domain/usecases/level_up_use_case.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/character_provider.dart';
import 'presentation/providers/task_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SupabaseClient? supabaseClient;
  try {
    if (AppConstants.supabaseUrl != 'YOUR_SUPABASE_URL' &&
        AppConstants.supabaseUrl.startsWith('http')) {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        publishableKey: AppConstants.supabasePublishableKey,
      );
      supabaseClient = Supabase.instance.client;
    } else {
      debugPrint(
        'Supabase Warning: Please configure YOUR_SUPABASE_URL and YOUR_SUPABASE_PUBLISHABLE_KEY in AppConstants',
      );
    }
  } catch (e) {
    debugPrint('Supabase Initialization Error: $e');
  }

  // Setup services and data sources
  final sqliteHelper = SqliteHelper();
  final sqliteTaskDatasource = SqliteTaskDatasource(sqliteHelper);

  // Fallback to dummy client if Supabase not initialized to prevent app crash
  final resolvedSupabaseClient =
      supabaseClient ?? SupabaseClient('https://dummy.supabase.co', 'dummyKey');
  final supabaseRemoteDatasource = SupabaseRemoteDatasource(
    resolvedSupabaseClient,
  );

  final taskRepository = TaskRepositoryImpl(
    sqliteTaskDatasource,
    supabaseRemoteDatasource,
  );

  final calculateXpUseCase = CalculateXpUseCase();
  final levelUpUseCase = LevelUpUseCase();

  runApp(
    MultiProvider(
      providers: [
        Provider<TaskRepository>.value(value: taskRepository),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepository)),
        ChangeNotifierProvider(
          create: (_) => CharacterProvider(calculateXpUseCase, levelUpUseCase),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}
