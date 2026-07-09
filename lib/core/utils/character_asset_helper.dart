/// Helper to resolve local asset path for character images.
/// File naming convention: Stage{N}_{ClassName}.png
/// e.g. Stage1_Knight.png, Stage2_Asassin.png, Stage3_Mage.png
class CharacterAssetHelper {
  static const String _basePath = 'assets/images/characters';

  /// Maps classType string to the class name used in the asset filenames.
  static String _classNameInFile(String classType) {
    switch (classType.toLowerCase()) {
      case 'knight':
        return 'Knight';
      case 'assassin':
        return 'Asassin'; // intentional: matches the user's file naming
      case 'mage':
        return 'Mage';
      case 'archer':
        return 'Archer';
      default:
        return 'Knight';
    }
  }

  /// Returns the asset path for a given classType and appearanceStage.
  /// e.g. getAssetPath('assassin', 2) → 'assets/images/characters/Stage2_Asassin.png'
  static String getAssetPath(String classType, int appearanceStage) {
    final className = _classNameInFile(classType);
    return '$_basePath/Stage${appearanceStage}_$className.png';
  }
}
