import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class RegisterDosenScreen extends StatefulWidget {
  const RegisterDosenScreen({super.key});

  @override
  State<RegisterDosenScreen> createState() => _RegisterDosenScreenState();
}

class _RegisterDosenScreenState extends State<RegisterDosenScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _errorMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.registerLecturer(
      username,
      email,
      password,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _isSuccess = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lecturer "$username" registered successfully!'),
          backgroundColor: const Color(0xFF4E7A51),
        ),
      );
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.go('/dashboard');
        }
      });
    } else {
      setState(() {
        _errorMessage =
            'Registration failed. Username or email might be taken.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Lecturer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.supervised_user_circle_rounded,
                    size: 64,
                    color: Color(0xFFC15F3C),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Create Lecturer Account',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2B26),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Fill in credentials to register a new verified Dosen.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6B6862)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB3492F).withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFB3492F)),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Color(0xFFB3492F)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Enter lecturer username',
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'Enter lecturer email',
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Create secure password',
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter password',
                    ),
                  ),
                  const SizedBox(height: 24),

                  if (authProvider.isLoading || _isSuccess)
                    const Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('Register Lecturer'),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
