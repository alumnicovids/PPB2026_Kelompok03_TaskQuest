import 'dart:io';
import 'dart:convert';
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

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final response = await _supabaseClient
        .from('users')
        .select()
        .order('username');
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getUsersByRole(String role) async {
    final response = await _supabaseClient
        .from('users')
        .select()
        .eq('role', role)
        .order('username');
    return List<Map<String, dynamic>>.from(response);
  }

  // === Tasks CRUD ===
  Future<List<Map<String, dynamic>>> getTasks(String userId) async {
    print('RemoteDatasource.getTasks called for userId: $userId');
    final response = await _supabaseClient
        .from('tasks')
        .select('*, users(username)')
        .order('created_at', ascending: false);
    final List<Map<String, dynamic>> allTasks = List<Map<String, dynamic>>.from(
      response,
    );
    print('RemoteDatasource.getTasks total remote tasks: ${allTasks.length}');

    final filtered = allTasks.where((task) {
      if (task['user_id'] == userId) return true;
      final assignmentsData = task['assignments'];
      if (assignmentsData != null) {
        List<dynamic>? list;
        if (assignmentsData is List) {
          list = assignmentsData;
        } else if (assignmentsData is String) {
          try {
            list = jsonDecode(assignmentsData) as List<dynamic>;
          } catch (_) {}
        }
        if (list != null) {
          return list.any(
            (a) =>
                a is Map &&
                a['student_id']?.toString().toLowerCase() ==
                    userId.toLowerCase(),
          );
        }
      }
      return false;
    }).toList();
    print('RemoteDatasource.getTasks total filtered tasks: ${filtered.length}');
    return filtered;
  }

  Future<void> upsertTask(Map<String, dynamic> taskData) async {
    await _supabaseClient.from('tasks').upsert(taskData);
  }

  Future<void> deleteTask(String taskId) async {
    await _supabaseClient.from('tasks').delete().eq('id', taskId);
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final response = await _supabaseClient
        .from('tasks')
        .select('*, users(username)')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<List<Map<String, dynamic>>> getSubmittedTasks() async {
    final response = await _supabaseClient
        .from('tasks')
        .select('*, users(username)')
        .eq('status', 'submitted')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateTaskStatus(
    String taskId,
    String status,
    String? completedAt,
  ) async {
    final data = {'status': status, 'completed_at': completedAt};
    await _supabaseClient.from('tasks').update(data).eq('id', taskId);
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

  Future<List<Map<String, dynamic>>> getAllCharacters() async {
    final response = await _supabaseClient.from('characters').select();
    return List<Map<String, dynamic>>.from(response);
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

  // === Storage Upload ===
  Future<String> uploadTaskProof(String localPath, String fileName) async {
    final file = File(localPath);
    await _supabaseClient.storage
        .from('task-proofs')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
    return _supabaseClient.storage.from('task-proofs').getPublicUrl(fileName);
  }

  Future<String> uploadCharacterAvatar(
    String localPath,
    String fileName,
  ) async {
    final file = File(localPath);
    await _supabaseClient.storage
        .from('Character-avatars')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));
    return _supabaseClient.storage
        .from('Character-avatars')
        .getPublicUrl(fileName);
  }

  // === Study Locations CRUD ===
  Future<List<Map<String, dynamic>>> getLocations(String userId) async {
    final response = await _supabaseClient
        .from('study_locations')
        .select()
        .eq('user_id', userId);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> upsertLocation(Map<String, dynamic> locationData) async {
    await _supabaseClient.from('study_locations').upsert(locationData);
  }

  Future<void> deleteRemoteLocation(String id) async {
    await _supabaseClient.from('study_locations').delete().eq('id', id);
  }
}
