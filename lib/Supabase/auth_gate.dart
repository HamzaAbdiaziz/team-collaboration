import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/login_screen.dart';
import '../screens/profile_page.dart'; // Import Profile Page

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      // Listen to auth state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,

      // Build appropriate page based on auth state
      builder: (context, snapshot) {
        // Show loading indicator while waiting
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user has an active session
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const ProfilePage(); // Redirect to Profile Page
        } else {
          return const LoginScreen(); // Stay on Login Screen
        }
      },
    );
  }
}
