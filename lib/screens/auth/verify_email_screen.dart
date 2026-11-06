import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/loading_button.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.profile?.email ?? 'your ALU email';

    return AuthScaffold(
      title: 'Verify your email',
      subtitle: 'We sent a link to $email. Open it, then come back here. '
          'Check your spam folder if you cannot find it.',
      child: Column(
        children: [
          LoadingButton(
            label: "I've verified my email",
            loading: auth.busy,
            onPressed: () async {
              final ok = await context.read<AuthProvider>().checkVerified();
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Not verified yet.')),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () async {
              await context.read<AuthProvider>().resendVerification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email sent.')),
                );
              }
            },
            child: const Text('Resend email'),
          ),
          TextButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            child: const Text('Use a different account'),
          ),
        ],
      ),
    );
  }
}