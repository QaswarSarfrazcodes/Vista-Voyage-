// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

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

  static const _amber = Color(0xFFF5A623);
  static const _red   = Color(0xFFE53935);
  static const _blue  = Color(0xFF3B82F6);

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passwordCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await SupabaseService.signUp(
        _emailCtrl.text.trim(), _passwordCtrl.text, _nameCtrl.text.trim());
      // Supabase sends confirmation email — show success message
      setState(() => _emailSent = true);
    } on AuthException catch (e) {
      String msg = e.message;
      if (msg.contains('already registered')) msg = 'This email is already registered.';
      if (msg.contains('weak')) msg = 'Password must be at least 6 characters.';
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
              colors: [Color(0xFF0F2044), Color(0xFF1E3A5F)],
            ),
          ),
        ),
        Center(child: Padding(padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(color: _amber.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: _amber, width: 2)),
              child: const Icon(Icons.mark_email_read_outlined, color: _amber, size: 40)),
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
                  backgroundColor: _blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                child: const Text('Go to Sign In', style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: Colors.white)))),
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
              colors: [Color(0xFF0F2044), Color(0xFF1E3A5F)],
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
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24)),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18)))),
            const SizedBox(height: 24),
            const Text('Create Account', style: TextStyle(
              fontSize: 32, fontWeight: FontWeight.bold,
              fontFamily: 'PlayfairDisplay', color: Colors.white,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)])),
            const SizedBox(height: 8),
            const Text('Join VistaVoyage and start exploring the world!',
              style: TextStyle(fontSize: 14, fontFamily: 'Nunito', color: Colors.white70)),
            const SizedBox(height: 32),
            TextFormField(controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              decoration: _fieldDeco('Full Name', Icons.person_outline)),
            const SizedBox(height: 14),
            TextFormField(controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@')) return 'Enter a valid email';
                return null;
              },
              decoration: _fieldDeco('Email Address', Icons.email_outlined)),
            const SizedBox(height: 14),
            TextFormField(controller: _passwordCtrl, obscureText: _obscure1,
              style: const TextStyle(color: Colors.white, fontFamily: 'Nunito'),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
              decoration: _fieldDeco('Password', Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(_obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white54, size: 20),
                  onPressed: () => setState(() => _obscure1 = !_obscure1)))),
            const SizedBox(height: 14),
            TextFormField(controller: _confirmCtrl, obscureText: _obscure2,
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
                decoration: BoxDecoration(color: _red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _red.withOpacity(0.4))),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: _red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_error!, style: const TextStyle(
                    color: _red, fontSize: 13, fontFamily: 'Nunito'))),
                ])),
            ],
            const SizedBox(height: 28),
            SizedBox(height: 54, child: ElevatedButton(
              onPressed: _loading ? null : _signup,
              style: ElevatedButton.styleFrom(
                backgroundColor: _amber, foregroundColor: Colors.black87,
                disabledBackgroundColor: _amber.withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4),
              child: _loading
                ? const SizedBox(width: 22, height: 22,
                    child: CircularProgressIndicator(color: Colors.black54, strokeWidth: 2.5))
                : const Text('Create Account', style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, fontFamily: 'Nunito')))),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text('Already have an account? ', style: TextStyle(
                color: Colors.white60, fontFamily: 'Nunito', fontSize: 14)),
              GestureDetector(onTap: () => Navigator.pop(context),
                child: const Text('Sign In', style: TextStyle(
                  color: Color(0xFF3B82F6), fontFamily: 'Nunito',
                  fontSize: 14, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 24),
          ])))),
      ]));
  }

  InputDecoration _fieldDeco(String label, IconData icon, {Widget? suffix}) =>
    InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white60, fontFamily: 'Nunito', fontSize: 14),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.25))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE53935))),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE53935), width: 2)),
      errorStyle: const TextStyle(color: Color(0xFFE53935), fontFamily: 'Nunito', fontSize: 12));
}
