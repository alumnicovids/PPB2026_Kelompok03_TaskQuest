import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/local/sqlite_helper.dart';
import 'data/datasources/local/sqlite_task_datasource.dart';
import 'data/datasources/local/sqlite_location_datasource.dart';
import 'data/datasources/local/sqlite_xp_log_datasource.dart';
import 'data/datasources/local/session_datasource.dart';
import 'data/datasources/remote/supabase_remote_datasource.dart';
import 'data/datasources/remote/quotes_datasource.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/character_repository_impl.dart';
import 'data/repositories/location_repository_impl.dart';
import 'data/repositories/xp_log_repository_impl.dart';
import 'domain/repositories/task_repository.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/character_repository.dart';
import 'domain/repositories/location_repository.dart';
import 'domain/repositories/xp_log_repository.dart';
import 'domain/usecases/calculate_xp_use_case.dart';
import 'domain/usecases/level_up_use_case.dart';
import 'presentation/navigation/app_router.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/character_provider.dart';
import 'presentation/providers/task_provider.dart';

import 'presentation/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

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
  final sqliteLocationDatasource = SqliteLocationDatasource(sqliteHelper);
  final sqliteXpLogDatasource = SqliteXpLogDatasource(sqliteHelper);
  final sessionDatasource = SessionDatasource(sharedPreferences);
  final httpClient = http.Client();
  final quotesDatasource = QuotesDatasource(httpClient);

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

  final authRepository = AuthRepositoryImpl(
    supabaseRemoteDatasource,
    sessionDatasource,
  );

  final characterRepository = CharacterRepositoryImpl(
    supabaseRemoteDatasource,
    sharedPreferences,
  );

  final locationRepository = LocationRepositoryImpl(
    sqliteLocationDatasource,
    supabaseRemoteDatasource,
  );

  final xpLogRepository = XpLogRepositoryImpl(
    sqliteXpLogDatasource,
    supabaseRemoteDatasource,
  );

  final calculateXpUseCase = CalculateXpUseCase();
  final levelUpUseCase = LevelUpUseCase();

  runApp(
    MultiProvider(
      providers: [
        Provider<TaskRepository>.value(value: taskRepository),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<CharacterRepository>.value(value: characterRepository),
        Provider<LocationRepository>.value(value: locationRepository),
        Provider<XpLogRepository>.value(value: xpLogRepository),
        Provider<QuotesDatasource>.value(value: quotesDatasource),
        ChangeNotifierProvider(create: (_) => ThemeProvider(sharedPreferences)),
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(create: (_) => TaskProvider(taskRepository)),
        ChangeNotifierProvider(
          create: (_) => CharacterProvider(
            calculateXpUseCase,
            levelUpUseCase,
            characterRepository,
            xpLogRepository,
          ),
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: AppRouter.router,
    );
  }
}
