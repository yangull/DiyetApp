import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'signup_screen.dart';

/// Toggles between login and signup. Two screens don't need named routes.
class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({super.key});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  var _showSignUp = false;

  @override
  Widget build(BuildContext context) {
    return _showSignUp
        ? SignUpScreen(
            onSwitchToLogin: () => setState(() => _showSignUp = false),
          )
        : LoginScreen(
            onSwitchToSignUp: () => setState(() => _showSignUp = true),
          );
  }
}
