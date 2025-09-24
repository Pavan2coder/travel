import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../state/app_state.dart';
import '../home/home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  static const route = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    final ok = await context.read<AuthService>().signIn(_email.text, _pass.text);
    setState(() => _loading = false);
    if (ok && mounted) {
      await NotificationService.instance.showSimple('Trip', 'Tap Start to begin tracking');
      Navigator.pushReplacementNamed(context, HomePage.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stars = context.watch<AppState>().totalStars;
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Stars: $stars'),
            const SizedBox(height: 12),
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 8),
            TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _login,
              child: _loading ? const CircularProgressIndicator() : const Text('Sign In'),
            ),
            TextButton(onPressed: () => Navigator.pushNamed(context, SignupPage.route), child: const Text('Create account')),
          ],
        ),
      ),
    );
  }
}

