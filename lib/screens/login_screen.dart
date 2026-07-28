import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/login_guard.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';
import '../widgets/vista_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String _friendlyError(String msg) {
    if (msg.contains('Invalid login')) return 'Email or password is incorrect.';
    if (msg.contains('Email not confirmed')) return 'Please confirm your email first.';
    if (msg.contains('too many requests')) return 'Too many attempts. Please wait.';
    return 'Login failed. Please try again.';
  }

  Future<void> _login() async {
    if (await LoginGuard.isLockedOut()) {
      final secs = await LoginGuard.remainingLockoutSeconds();
      setState(() => _error = 'Too many failed attempts. Try again in ${secs}s.');
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await SupabaseService.signIn(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );
      await LoginGuard.resetOnSuccess();
      if (mounted) Navigator.pushReplacementNamed(context, '/main');
    } on AuthException catch (e) {
      await LoginGuard.recordFailedAttempt();
      setState(() {
        _error = _friendlyError(e.message);
      });
    } catch (e) {
      setState(() {
        _error = 'Connection error. Check your internet.';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _forgotPassword() {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    bool sending = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Enter your email and we\'ll send you a password reset link.',
            style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.gray)),
          const SizedBox(height: 16),
          TextField(controller: ctrl, keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: sending ? null : () async {
              if (ctrl.text.trim().isEmpty || !ctrl.text.contains('@')) return;
              setDialogState(() => sending = true);
              try {
                await SupabaseService.client.auth.resetPasswordForEmail(ctrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) {
                  AppToast.show(context, 'Reset link sent! Check your email.', type: ToastType.success);
                }
              } catch (_) {
                setDialogState(() => sending = false);
                if (ctx.mounted) {
                  AppToast.show(ctx, 'Could not send reset link. Try again.', type: ToastType.error);
                }
              }
            },
            child: sending
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Send Link'),
          ),
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.darkGradient,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    const Center(child: VistaLogo(size: 64)),
                    const SizedBox(height: 24),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'PlayfairDisplay',
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in to explore amazing destinations',
                      style: TextStyle(color: Colors.white70, fontFamily: 'Nunito'),
                    ),
                    const SizedBox(height: 44),

                    TextFormField(
                      controller: _emailCtrl,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email required';
                        if (!v.contains('@')) return 'Enter valid email';
                        return null;
                      },
                      decoration: _fieldDeco('Email', Icons.email),
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _loading ? null : _login(),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password required';
                        return null;
                      },
                      decoration: _fieldDeco(
                        'Password',
                        Icons.lock,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            color: Colors.white54,
                          ),
                          onPressed: () => setState(() {
                            _obscure = !_obscure;
                          }),
                        ),
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _forgotPassword,
                        child: const Text('Forgot Password?', style: TextStyle(color: AppColors.gold, fontFamily: 'Nunito')),
                      ),
                    ),

                    if (_error != null) ...[
                      const SizedBox(height: 4),
                      Text(_error!, style: const TextStyle(color: Colors.red, fontFamily: 'Nunito')),
                    ],

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: AppColors.deepNavy)
                            : const Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.deepNavy,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        'Create New Account',
                        style: TextStyle(color: Colors.white, fontFamily: 'Nunito'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDeco(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontFamily: 'Nunito'),
      prefixIcon: Icon(icon, color: Colors.white54),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
