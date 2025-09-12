import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final goingToLogin =
          state.uri.toString() == '/login' || state.uri.toString() == '/register';


      return null;
    },
    routes: [

    ],
  );
});
