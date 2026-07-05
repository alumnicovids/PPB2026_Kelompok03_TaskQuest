import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'presentation/navigation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (AppConstants.supabaseUrl != 'YOUR_SUPABASE_URL' &&
        AppConstants.supabaseUrl.startsWith('http')) {
      await Supabase.initialize(
        url: AppConstants.supabaseUrl,
        publishableKey: AppConstants.supabasePublishableKey,
      );
    } else {
      debugPrint(
        'Supabase Warning: Please configure YOUR_SUPABASE_URL and YOUR_SUPABASE_PUBLISHABLE_KEY in AppConstants',
      );
    }
  } catch (e) {
    debugPrint('Supabase Initialization Error: $e');
  }

  runApp(const MyApp());
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
