import 'package:fastnotes_flutter/core/utils/snackbar_utils.dart';
import 'package:fastnotes_flutter/presentation/auth/auth_provider.dart';
import 'package:fastnotes_flutter/presentation/home/home_provider.dart';
import 'package:fastnotes_flutter/presentation/note/note_provider.dart';
import 'package:fastnotes_flutter/presentation/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Providers
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => NoteProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        scaffoldMessengerKey: SnackbarUtils.scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
