import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/character_provider.dart';
import '../../providers/task_provider.dart';
import '../../../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;
  String? _errorMessage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final email = _emailController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Username and password cannot be empty';
      });
      return;
    }

    if (_isRegisterMode && email.isEmpty) {
      setState(() {
        _errorMessage = 'Email cannot be empty';
      });
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success;

    if (_isRegisterMode) {
      success = await authProvider.register(username, email, password);
    } else {
      success = await authProvider.login(username, password);
    }

    if (!mounted) return;

    if (success) {
      final userId = authProvider.userId;
      if (userId != null) {
        await Provider.of<CharacterProvider>(
          context,
          listen: false,
        ).loadCharacter(userId);
        if (mounted) {
          await Provider.of<TaskProvider>(
            context,
            listen: false,
          ).loadTasks(userId);
        }
      }
      if (mounted) {
        context.go('/dashboard');
      }
    } else {
      setState(() {
        _errorMessage = _isRegisterMode
            ? 'Registration failed. Username might be taken.'
            : 'Login failed. Invalid username or password.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppColors.darkGroundGradient
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.oldMap, AppColors.agedParchment],
                ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28.0,
                  vertical: 24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo / Icon ─────────────────────────────────────
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.goldShimmerGradient.createShader(bounds),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── App Title ───────────────────────────────────────
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.goldShimmerGradient.createShader(bounds),
                      child: Text(
                        'TaskQuest',
                        style: Theme.of(
                          context,
                        ).textTheme.displayLarge?.copyWith(
                          color: Colors.white,
                          shadows: [
                            const Shadow(
                              color: AppColors.burnishedGold,
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isRegisterMode
                          ? 'Create your hero account'
                          : 'Enter the realm, brave hero',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.dustyScript
                            : AppColors.brownInk,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // ── Form Card ───────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkStone
                            : AppColors.vellum,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? AppColors.agedBorder
                              : AppColors.parchmentBorder,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.dungeonBlack.withAlpha(
                              isDark ? 120 : 40,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── Title ─────────────────────────────────────
                          Text(
                            _isRegisterMode ? 'Join the Guild' : 'Enter Gate',
                            style: Theme.of(
                              context,
                            ).textTheme.displaySmall?.copyWith(
                              color: AppColors.ancientGold,
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppColors.agedBorder
                                      : AppColors.parchmentBorder,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Text(
                                  '⚔',
                                  style: TextStyle(
                                    color: AppColors.ancientGold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? AppColors.agedBorder
                                      : AppColors.parchmentBorder,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // ── Error ─────────────────────────────────────
                          if (_errorMessage != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.dangerRed.withAlpha(25),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.dangerRed.withAlpha(150),
                                ),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.emberRed,
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // ── Username Field ────────────────────────────
                          TextField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              hintText: 'Your hero name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),

                          // ── Email (register only) ─────────────────────
                          if (_isRegisterMode) ...[
                            const SizedBox(height: 14),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                hintText: 'For thy records',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                            ),
                          ],
                          const SizedBox(height: 14),

                          // ── Password ──────────────────────────────────
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'The secret phrase',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Submit Button ─────────────────────────────
                          if (authProvider.isLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.ancientGold,
                              ),
                            )
                          else
                            ElevatedButton(
                              onPressed: _handleSubmit,
                              child: Text(
                                _isRegisterMode
                                    ? '⚔  Forge My Account'
                                    : '🗡  Enter the Realm',
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Toggle Register/Login ───────────────────────────
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isRegisterMode = !_isRegisterMode;
                          _errorMessage = null;
                        });
                      },
                      child: Text(
                        _isRegisterMode
                            ? 'Already a member? Enter gate →'
                            : "No account yet? Join the guild →",
                        style: const TextStyle(color: AppColors.ancientGold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
