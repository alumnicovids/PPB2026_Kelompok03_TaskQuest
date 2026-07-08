import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/character.dart';
import '../../domain/repositories/character_repository.dart';
import '../datasources/remote/supabase_remote_datasource.dart';
import '../models/character_model.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final SupabaseRemoteDatasource _supabaseRemoteDatasource;
  final SharedPreferences _sharedPreferences;

  static const String _characterCacheKeyPrefix = 'cached_character_';

  CharacterRepositoryImpl(
    this._supabaseRemoteDatasource,
    this._sharedPreferences,
  );

  @override
  Future<Character?> getCharacter(String userId) async {
    try {
      final remoteData = await _supabaseRemoteDatasource.getCharacterByUserId(
        userId,
      );
      if (remoteData != null) {
        final character = CharacterModel.fromMap(remoteData);
        // Cache locally
        await _sharedPreferences.setString(
          '$_characterCacheKeyPrefix$userId',
          jsonEncode(character.toMap()),
        );
        return character;
      }
    } catch (_) {
      // Offline or network error: try local cache
    }

    // Fallback to local SharedPreferences cache
    final localJson = _sharedPreferences.getString(
      '$_characterCacheKeyPrefix$userId',
    );
    if (localJson != null) {
      try {
        final Map<String, dynamic> decoded =
            jsonDecode(localJson) as Map<String, dynamic>;
        return CharacterModel.fromMap(decoded);
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  @override
  Future<void> saveCharacter(Character character) async {
    final model = CharacterModel.fromEntity(character);
    // Cache locally first
    await _sharedPreferences.setString(
      '$_characterCacheKeyPrefix${character.userId}',
      jsonEncode(model.toMap()),
    );

    // Sync to remote
    try {
      await _supabaseRemoteDatasource.upsertCharacter(model.toMap());
    } catch (_) {
      // Offline-first: save locally, sync later or ignore remote fail
    }
  }

  @override
  Future<List<Character>> getAllCharacters() async {
    final rawList = await _supabaseRemoteDatasource.getAllCharacters();
    return rawList.map((map) => CharacterModel.fromMap(map)).toList();
  }
}
