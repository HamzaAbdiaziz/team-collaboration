import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserServices {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch all users
  Future<Map<String, dynamic>> allUsers() async {
    final response = await _supabase.from("users").select("*");
    if (response.isEmpty) {
      return {"data": null, "err": "No users found"};
    }
    return {"data": response, "err": null};
  }

  // Fetch user by ID
  Future<Map<String, dynamic>> getUserById(String id) async {
    final response =
        await _supabase.from("users").select("*").eq("id", id).single();
    return response.isNotEmpty
        ? {"data": response, "err": null}
        : {"data": null, "err": "User not found"};
  }

  // Update user
  Future<Map<String, dynamic>> updateUser(
    String id,
    Map<String, dynamic> newData,
  ) async {
    if (newData.containsKey("email")) {
      await _supabase.auth.updateUser(UserAttributes(email: newData["email"]));
    }

    final response =
        await _supabase
            .from("users")
            .update(newData)
            .eq("id", id)
            .select()
            .single();
    await saveUser(response);
    return {"data": response, "err": null};
  }

  // Delete user
  Future<Map<String, dynamic>> deleteUser(String id) async {
    await _supabase.auth.admin.deleteUser(id);
    final response = await _supabase.from("users").delete().eq("id", id);
    await removeUser();
    return {"data": response, "err": null};
  }

  // Save user settings locally
  Future<Map<String, dynamic>> saveSettingsToSession(
    Map<String, dynamic> newSettings,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storedSettings = prefs.getString("userSettings");
    final parsedSettings =
        storedSettings != null ? jsonDecode(storedSettings) : {};
    final updatedSettings = {...parsedSettings, ...newSettings};
    await prefs.setString("userSettings", jsonEncode(updatedSettings));
    return {"data": updatedSettings, "err": null};
  }

  // Save user data locally
  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("UserData", jsonEncode(userData));
  }

  // Remove user data locally
  Future<void> removeUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("UserData");
  }
}
