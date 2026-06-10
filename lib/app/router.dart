import 'package:go_router/go_router.dart';
import '../features/home/home_screen.dart';
import '../features/result/result_screen.dart';
import '../features/history/history_screen.dart';
import '../core/gemini/gemini_service.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final response = state.extra as GeminiRouteResponse;
        return ResultScreen(response: response);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);