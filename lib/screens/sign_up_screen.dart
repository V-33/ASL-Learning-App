import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  bool hasMinLength = false;
  bool hasUpper = false;
  bool hasLower = false;
  bool hasDigit = false;
  bool hasSpecial = false;

  void checkPassword(String password) {
    setState(() {
      hasMinLength = password.length >= 8;
      hasUpper = password.contains(RegExp(r'[A-Z]'));
      hasLower = password.contains(RegExp(r'[a-z]'));
      hasDigit = password.contains(RegExp(r'[0-9]'));
      hasSpecial = password.contains(RegExp(r'[!@#\$&*~]'));
    });
  }

  Widget rule(String text, bool passed) {
    return Row(
      children: [
        Icon(
          passed ? Icons.check_circle : Icons.cancel,
          color: passed ? Colors.green : Colors.grey,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStrongPassword = hasMinLength &&
        hasUpper &&
        hasLower &&
        hasDigit &&
        hasSpecial;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: checkPassword,
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text("Password must contain:"),

            const SizedBox(height: 8),
            rule("At least 8 characters", hasMinLength),
            rule("One uppercase letter", hasUpper),
            rule("One lowercase letter", hasLower),
            rule("One number", hasDigit),
            rule("One special character", hasSpecial),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: isStrongPassword
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Account created (mock)"),
                        ),
                      );
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text("Create Account"),
            ),
          ],
        ),
      ),
    );
  }
}
