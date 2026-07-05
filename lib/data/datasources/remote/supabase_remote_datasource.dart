import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseRemoteDatasource {
  final SupabaseClient _supabaseClient;

  SupabaseRemoteDatasource(this._supabaseClient);

  // === Users CRUD ===
  Future<Map<String, dynamic>?> getUserById(String id) async {
    return await _supabaseClient
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    return await _supabaseClient
        .from('users')
        .select()
        .eq('username', username)
        .maybeSingle();
  }

  Future<void> insertUser(Map<String, dynamic> userData) async {
    await _supabaseClient.from('users').insert(userData);
  }

  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    await _supabaseClient.from('users').update(userData).eq('id', id);
  }

  // === Tasks CRUD ===
  Future<List<Map<String, dynamic>>> getTasks(String userId) async {
    final response = await _supabaseClient
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> upsertTask(Map<String, dynamic> taskData) async {
    await _supabaseClient.from('tasks').upsert(taskData);
  }

  Future<void> deleteTask(String taskId) async {
    await _supabaseClient.from('tasks').delete().eq('id', taskId);
  }

  // === Characters CRUD ===
  Future<Map<String, dynamic>?> getCharacterByUserId(String userId) async {
    return await _supabaseClient
        .from('characters')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }

  Future<void> upsertCharacter(Map<String, dynamic> characterData) async {
    await _supabaseClient.from('characters').upsert(characterData);
  }

  // === XP Logs CRUD ===
  Future<List<Map<String, dynamic>>> getXpLogs(String userId) async {
    final response = await _supabaseClient
        .from('xp_logs')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> insertXpLog(Map<String, dynamic> xpLogData) async {
    await _supabaseClient.from('xp_logs').insert(xpLogData);
  }
}
