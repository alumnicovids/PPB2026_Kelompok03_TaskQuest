import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/setup_profile_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/task_list/task_list_screen.dart';
import '../screens/task_detail/task_detail_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/level_up/level_up_screen.dart';
import '../screens/locations/locations_map_screen.dart';
import '../screens/student_list/student_list_screen.dart';
import '../screens/admin/register_dosen_screen.dart';
import '../screens/admin/character_avatar_manager_screen.dart';
import '../screens/review/review_submissions_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/setup-profile',
        builder: (context, state) => const SetupProfileScreen(),
      ),
      GoRoute(
        path: '/character-avatars',
        builder: (context, state) => const CharacterAvatarManagerScreen(),
      ),
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
      GoRoute(
        path: '/students',
        builder: (context, state) => const StudentListScreen(),
      ),
      GoRoute(
        path: '/register-dosen',
        builder: (context, state) => const RegisterDosenScreen(),
      ),
      GoRoute(
        path: '/review-submissions',
        builder: (context, state) => const ReviewSubmissionsScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
