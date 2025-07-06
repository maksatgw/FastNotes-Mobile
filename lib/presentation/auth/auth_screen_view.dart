import 'package:fastnotes_flutter/presentation/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AuthScreenView extends StatefulWidget {
  const AuthScreenView({super.key});

  @override
  State<AuthScreenView> createState() => _AuthScreenViewState();
}

class _AuthScreenViewState extends State<AuthScreenView> {
  final String _title = 'FastNotes';

  final String _subTitle = 'Take your notes with you, anywhere, anytime.';

  final String _loginWithGoogle = 'Login with Google';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 30,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                Text(
                  _title,
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                Text(
                  _subTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: ElevatedButton(
                onPressed: () async {
                  final authProvider = Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  );
                  final result = await authProvider.login();
                  if (result) {
                    context.go('/home');
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 10,
                  children: [
                    Icon(FontAwesomeIcons.google, size: 20),
                    Text(_loginWithGoogle),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
