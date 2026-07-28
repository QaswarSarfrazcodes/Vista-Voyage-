// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _formKey      = GlobalKey<FormState>();
  bool   _loading     = false;
  bool   _obscure1    = true;
  bool   _obscure2    = true;
  String? _error;
  bool   _emailSent   = false;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<bool> _showTermsAgreement() async {
    bool accepted = false;
    await showModalBottomSheet(
      context: context, isScrollControlled: true, isDismissible: false, enableDrag: false,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        bool checked = false;
        return Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 20),
          const Icon(Icons.description_outlined, color: AppColors.primary, size: 40),
          const SizedBox(height: 12),
          const Text('Before You Continue', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Please review and accept our Terms & Conditions to create your Tripline account.',
            textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.gray)),
          const SizedBox(height: 16),
          TextButton(onPressed: () => Navigator.pushNamed(ctx, '/terms'),
            child: const Text('Read full Terms & Conditions', style: TextStyle(fontFamily: 'Nunito', color: AppColors.primary))),
          Row(children: [
            Checkbox(value: checked, activeColor: AppColors.primary,
              onChanged: (v) => setSheetState(() => checked = v ?? false)),
            const Expanded(child: Text('I have read and agree to the Terms & Conditions',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 12))),
          ]),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
            onPressed: checked ? () { accepted = true; Navigator.pop(ctx); } : null,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            child: const Text('I Agree & Continue', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)))),
        ]));
      }),
    );
    return accepted;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    if (!await _showTermsAgreement()) return;
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      await SupabaseService.signUp(
        _emailCtrl.text.trim(), _passwordCtrl.text, _nameCtrl.text.trim());
      // Supabase sends confirmation email — show success message
      setState(() => _emailSent = true);
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.contains('already registered')) msg = 'This email is already registered.';
      if (msg.contains('weak')) msg = 'Password must be at least 8 characters with an uppercase letter and a number.';
      setState(() { _error = msg; });
    } catch (e) {
      setState(() { _error = 'Connection error. Check your internet.'; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_emailSent) {
      return Scaffold(body: Stack(fit: StackFit.expand, children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.darkGradient,
            ),
          ),
        ),
        Center(child: Padding(padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(color: AppColors.gold.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2)),
              child: const Icon(Icons.mark_email_read_outlined, color: AppColors.gold, size: 40)),
            const SizedBox(height: 24),
            const Text('Check Your Email!', style: TextStyle(
              fontSize: 28, fontWeight: FontWeight.bold,
              fontFamily: 'PlayfairDisplay', color: Colors.white)),
            const SizedBox(height: 12),
            Text('We sent a confirmation link to\n${_emailCtrl.text.trim()}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.white70, fontFamily: 'Nunito', height: 1.5)),
            const SizedBox(height: 8),
            const Text('Click the link in the email to activate your account,\nthen come back and sign in.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.white54, fontFamily: 'Nunito', height: 1.5)),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Go to Sign In', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: AppColors.deepNavy)))),
          ]))),
      ]));
    }

    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.darkGradient,
            ),
          ),
        ),
        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(key: _formKey, child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Align(alignment: Alignment.centerLeft,
              child: GestureDetector(onTap: () => Navigator.pop(context),
                child: Container(width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24)),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)))),
            const SizedBox(height: 24),
            const Text('Create Account', style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold,
              fontFamily: 'PlayfairDisplay', color: Colors.white,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)])),
            const SizedBox(height: 8),
            const Text('Join Tripline and start exploring the world!',
              style: TextStyle(fontSize: 14, fontFamily: 'Nunito', color: Colors.white70)),
            const SizedBox(height: 32),
            TextFormField(controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              decoration: _fieldDeco('Full Name', Icons.person_outline)),
            const SizedBox(height: 14),
            TextFormField(controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
              decoration: _fieldDeco('Email Address', Icons.email_outlined)),
            const SizedBox(height: 14),
            TextFormField(controller: _passwordCtrl, obscureText: _obscure1,
              textInputAction: TextInputAction.next,
              style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
              onChanged: (_) => setState(() {}),
              validator: strongPasswordValidator,
              decoration: _fieldDeco('Password', Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(_obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white54, size: 20),
                  onPressed: () => setState(() => _obscure1 = !_obscure1)))),
            if (_passwordCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              _strengthBar(_passwordCtrl.text),
            ],
            const SizedBox(height: 14),
            TextFormField(controller: _confirmCtrl, obscureText: _obscure2,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _loading ? null : _signup(),
              style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Please confirm your password';
                if (v != _passwordCtrl.text) return 'Passwords do not match';
                return null;
              },
              decoration: _fieldDeco('Confirm Password', Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(_obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white54, size: 20),
                  onPressed: () => setState(() => _obscure2 = !_obscure2)))),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(
                    color: AppColors.error, fontSize: 13, fontFamily: 'Nunito'))),
                ])),
            ],
            const SizedBox(height: 28),
            SizedBox(height: 54, child: ElevatedButton(
              onPressed: _loading ? null : _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold, foregroundColor: AppColors.deepNavy,
                disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4),
              child: _loading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: AppColors.deepNavy, strokeWidth: 2.5))
                : const Text('Create Account', style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Nunito')))),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account? ', style: TextStyle(
                color: Colors.white60, fontFamily: 'Nunito', fontSize: 14)),
              GestureDetector(onTap: () => Navigator.pop(context),
                child: const Text('Sign In', style: TextStyle(
                  color: AppColors.gold, fontFamily: 'Nunito',
                  fontSize: 14, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 24),
          ])))),
      ]));
  }

  Widget _strengthBar(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$&*~%^]').hasMatch(password)) score++;
    const colors = [Colors.red, Colors.orange, Colors.yellow, Colors.lightGreen, Colors.green];
    return Row(children: List.generate(4, (i) => Expanded(
      child: Container(height: 4, margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: i < score ? colors[score] : Colors.white24,
          borderRadius: BorderRadius.circular(2))))));
  }

  InputDecoration _fieldDeco(String label, IconData icon, {Widget? suffix}) =>
    InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontFamily: 'Nunito', fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.25))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.gold, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2)),
      errorStyle: const TextStyle(color: AppColors.error, fontFamily: 'Nunito', fontSize: 12));
}
