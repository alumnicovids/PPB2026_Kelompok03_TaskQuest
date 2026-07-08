import '../entities/character.dart';

abstract class CharacterRepository {
  Future<Character?> getCharacter(String userId);
  Future<void> saveCharacter(Character character);
  Future<List<Character>> getAllCharacters();
  Future<String> uploadCharacterAvatar(String localPath, String fileName);
}
