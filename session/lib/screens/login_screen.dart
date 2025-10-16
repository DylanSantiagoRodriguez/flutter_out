import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _error;

  SupabaseClient get _client => Supabase.instance.client;

  Future<void> _ensureUserRow({String? name}) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final email = user.email;
    try {
      await _client
          .from('users')
          .upsert({
            'id': user.id,
            'email': email,
            if (name != null && name.isNotEmpty) 'name': name,
          });
    } catch (e) {
      // Puede fallar si hay RLS. No bloqueamos el flujo de login.
      debugPrint('ensureUserRow error: $e');
    }
  }

  Future<void> _signUp() async {
    setState(() { _loading = true; _error = null; });
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final name = _nameController.text.trim();
      final res = await _client.auth.signUp(
        email: email,
        password: password,
        data: name.isNotEmpty ? {'name': name} : null,
      );
      if (res.user != null) {
        await _ensureUserRow(name: name);
      }
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _signIn() async {
    setState(() { _loading = true; _error = null; });
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      await _client.auth.signInWithPassword(email: email, password: password);
      await _ensureUserRow(name: _nameController.text.trim());
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _signOut() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _client.auth.signOut();
    } catch (e) {
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 12),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre (opcional)')),
            const SizedBox(height: 20),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loading ? null : _signIn, child: const Text('Iniciar sesión')),
            ElevatedButton(onPressed: _loading ? null : _signUp, child: const Text('Registrarse')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loading ? null : _signOut, child: const Text('Cerrar sesión')),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}