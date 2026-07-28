import 'package:go_router/go_router.dart';
import 'package:pokemon_app/models/pokemon.dart';
import 'package:pokemon_app/screens/detail_screen.dart';
import 'package:pokemon_app/screens/favorites_screen.dart';
import 'package:pokemon_app/screens/home_screen.dart';
import 'package:pokemon_app/widgets/app_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/favorites',
              builder: (context, state) => const FavoritesScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/pokemon/:id',
      builder: (context, state) => DetailScreen(
        pokemon: state.extra as Pokemon,
      ),
    ),
  ],
);
