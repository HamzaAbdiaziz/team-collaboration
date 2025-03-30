import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<AuthResponse> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user != null) {
      final userResponse =
          await _supabase.from('users').select().eq('email', email).single();

      await saveUser(userResponse);
    }
    return response;
  }

  Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
    Map<String, dynamic> extraData,
  ) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      final userId = response.user?.id;
      if (userId != null) {
        await _supabase.from("users").insert({
          'id': userId,
          'email': email,
          ...extraData,
        });
        await saveUser(extraData);
      }
    }
    return response;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await removeUser();
  }

  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    return session?.user.email;
  }

  Future<Map<String, dynamic>?> getLoggedInUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString("UserData");
    if (userDataString != null) {
      return jsonDecode(userDataString);
    }
    return null;
  }

  Future<String> updateUserEmail(String email) async {
    final response = await _supabase.auth.updateUser(
      UserAttributes(email: email),
    );
    return response.user != null
        ? 'Email updated successfully!'
        : 'Failed to update email';
  }

  Future<String> updateUserPassword(String password) async {
    final response = await _supabase.auth.updateUser(
      UserAttributes(password: password),
    );
    return response.user != null
        ? 'Password updated successfully!'
        : 'Failed to update password';
  }

  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("UserData", jsonEncode(userData));
  }

  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("UserData");
  }
}
