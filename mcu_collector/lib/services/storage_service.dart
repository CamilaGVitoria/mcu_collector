import 'package:shared_preferences/shared_preferences.dart';

import '../models/marvel_character.dart';

/// Serviço responsável pela persistência local dos dados de personagens.
///
/// Implementado como **Singleton** para garantir uma única instância
/// compartilhada em todo o aplicativo, evitando múltiplas conexões
/// ao SharedPreferences.
class StorageService {
  // ---------- Singleton ----------
  StorageService._internal();

  static final StorageService _instance = StorageService._internal();

  /// Retorna a instância única de [StorageService].
  factory StorageService() => _instance;

  // ---------- Constantes ----------
  static const String _storageKey = 'mcu_collected_characters';

  // ---------- Métodos públicos ----------

  /// Salva a lista de personagens no armazenamento local.
  ///
  /// A lista é serializada como JSON antes de ser armazenada.
  Future<bool> saveCharacters(List<MarvelCharacter> characters) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = MarvelCharacter.encodeList(characters);
    return prefs.setString(_storageKey, encodedData);
  }

  /// Recupera a lista de personagens do armazenamento local.
  ///
  /// Retorna uma lista vazia caso não existam dados salvos.
  Future<List<MarvelCharacter>> loadCharacters() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    return MarvelCharacter.decodeList(jsonString);
  }

  /// Remove todos os personagens do armazenamento local.
  Future<bool> clearCharacters() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(_storageKey);
  }
}
