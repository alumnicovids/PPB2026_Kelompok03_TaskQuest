import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/task_list/task_list_screen.dart';
import '../screens/task_detail/task_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/level_up/level_up_screen.dart';
import '../screens/locations/locations_map_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/tasks/:id',
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return TaskDetailScreen(taskId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/level-up',
        builder: (context, state) => const LevelUpScreen(),
      ),
      GoRoute(
        path: '/locations',
        builder: (context, state) => const LocationsMapScreen(),
      ),
    ],
  );
}
