import 'package:fastnotes_flutter/data/models/note_model.dart';
import 'package:fastnotes_flutter/presentation/auth/auth_screen_view.dart';
import 'package:fastnotes_flutter/presentation/home/home_screen_view.dart';
import 'package:fastnotes_flutter/presentation/note/note_detail_screen_view.dart';
import 'package:fastnotes_flutter/presentation/note/note_form_screen_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fastnotes_flutter/domain/repositories/auth_repository.dart';
import 'package:fastnotes_flutter/presentation/service_locator.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final authRepository = serviceLocator<AuthRepository>();
      final isLoggedIn = authRepository.isUserLoggedIn();

      // Ana sayfa veya giriş sayfasına yönlendirme
      if (state.uri.path == '/') {
        return isLoggedIn ? '/home' : '/auth';
      }

      // Kullanıcı giriş yapmışsa auth sayfasına erişimi engelle
      if (state.uri.path == '/auth' && isLoggedIn) {
        return '/home';
      }

      // Kullanıcı giriş yapmamışsa sadece auth sayfasına erişebilir
      if (!isLoggedIn && state.uri.path != '/auth') {
        return '/auth';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'root',
        builder: (context, state) => const SizedBox(), // Dummy widget
      ),
      GoRoute(
        path: '/auth',
        name: 'auth',
        builder: (context, state) => const AuthScreenView(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreenView(),
      ),
      GoRoute(
        path: '/note/new',
        name: 'note-new',
        builder: (context, state) => const NoteFormScreenView(),
      ),
      GoRoute(
        path: '/note/:id',
        name: 'note-detail',
        builder: (context, state) {
          final note = state.extra as NoteModel;
          return NoteDetailScreenView(note: note);
        },
      ),
    ],
  );
}
