import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'widgets/gradient_background.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
      ],
      child: MaterialApp(
        title: 'Campus Incident Reporter',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) => GradientBackground(child: child!),
        home: const AuthGate(),
      ),
    );
  }
}