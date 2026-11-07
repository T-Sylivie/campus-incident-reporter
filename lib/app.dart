import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/incident_service.dart';
import 'widgets/gradient_background.dart';
import 'services/storage_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        // Follows the signed-in user: starts listening after login,
        // stops and clears after logout.
        ChangeNotifierProxyProvider<AuthProvider, IncidentProvider>(
          /* create: (_) => IncidentProvider(IncidentService()), */
          create: (_) => IncidentProvider(IncidentService(), StorageService()),          
          update: (_, auth, incidents) {
            incidents!.bind(
              auth.isLoggedIn && auth.isVerified ? auth.profile : null,
            );
            return incidents;
          },
        ),
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