import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'widgets/gradient_background.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Incident Reporter',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => GradientBackground(child: child!),
      home: Scaffold(
        body: Center(
          child: Text(
            'Firebase connected!',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ),
    );
  }
}