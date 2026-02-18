import 'repair_quote_screen.dart';
import 'admin_quotes_screen.dart';
import 'admin_appointments_screen.dart';
import 'appointment_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

await Supabase.initialize(
  url: 'https://qyxsvjhmfhrgxcmdvcuy.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF5eHN2amhtZmhyZ3hjbWR2Y3V5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzE0MTA0MjcsImV4cCI6MjA4Njk4NjQyN30.hjyjDK0a87pVXfUoVW8sN3ujl3jLUoldScvnUul1p_U',
);


  runApp(const WDriveApp());
}

class WDriveApp extends StatelessWidget {
  const WDriveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'W-Drive',
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session == null) {
          return const AuthScreen();
        }
        return const HomeScreen();
      },
    );
  }
}


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> signUp() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      showMessage('Registrierung erfolgreich. Bitte E-Mail bestätigen.');
    } catch (e) {
      showMessage(e.toString());
    }
    setState(() => loading = false);
  }

  Future<void> signIn() async {
    setState(() => loading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      setState(() {});
    } catch (e) {
      showMessage(e.toString());
    }
    setState(() => loading = false);
  }

  void showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('W-Drive Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'E-Mail'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Passwort'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : signIn,
              child: const Text('Login'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: loading ? null : signUp,
              child: const Text('Registrieren'),
            ),
          ],
        ),
      ),
    );
  }
}


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('W-Drive'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Willkommen bei W-Drive by Walterscheidt',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),

            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AppointmentScreen()),
                );
              },
              child: const Text('Termin anfragen'),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AdminAppointmentsScreen()),
                );
              },
              child: const Text('Admin: Termine ansehen'),
            ),

            const SizedBox(height: 12),

            FilledButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RepairQuoteScreen()),
                );
              },
              child: const Text('Angebot anfragen'),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminQuotesScreen()),
                );
              },
              child: const Text('Admin: Angebote ansehen'),
            ),
          ],
        ),
      ),
    );
  }
}

