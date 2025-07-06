import 'package:fastnotes_flutter/app/app.dart';
import 'package:fastnotes_flutter/core/network/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:fastnotes_flutter/presentation/service_locator.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  setupServiceLocator();
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('auth');
  await Hive.openBox('user');

  DioClient.setupInterceptors();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const App();
  }
}
