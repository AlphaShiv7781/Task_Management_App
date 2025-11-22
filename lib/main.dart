import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/providers/auth_provider.dart';
import 'data/providers/task_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/task_repository.dart';
import 'logic/auth/auth_bloc.dart';
import 'logic/task/task_bloc.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  final taskProvider = TaskProvider();
  final authRepository = AuthRepository(authProvider);
  final taskRepository = TaskRepository();

  runApp(MyApp(
    authRepository: authRepository,
    taskRepository: taskRepository,
  ));
}

class MyApp extends StatelessWidget {
  final AuthRepository authRepository;
  final TaskRepository taskRepository;

  const MyApp({
    super.key,
    required this.authRepository,
    required this.taskRepository,
  });

  @override
  Widget build(BuildContext context) {
    final primaryBlue = Colors.blue.shade700;

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(authRepository),
        ),
        BlocProvider<TaskBloc>(
          create: (_) => TaskBloc(taskRepository),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Manager',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: primaryBlue,
            primary: primaryBlue,
          ),
          scaffoldBackgroundColor: Colors.grey.shade50,
          appBarTheme: AppBarTheme(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 1,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryBlue, width: 1.4),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
