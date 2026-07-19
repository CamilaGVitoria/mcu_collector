import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/marvel_character.dart';
import '../services/storage_service.dart';

/// Controller responsável por gerenciar o estado da lista de personagens.
///
/// Utiliza [ChangeNotifier] para notificar a View sobre mudanças de estado,
/// fazendo a ponte entre a camada de apresentação e o [StorageService].
class MarvelController extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<MarvelCharacter> _characters = [];
  bool _isLoading = false;

  // ---------- Getters ----------

  /// Lista atual de personagens.
  List<MarvelCharacter> get characters => List.unmodifiable(_characters);

  /// Indica se o controller está carregando dados.
  bool get isLoading => _isLoading;

  /// Quantidade total de personagens coletados.
  int get collectedCount => _characters.where((c) => c.isCollected).length;

  /// Quantidade total de personagens na lista.
  int get totalCount => _characters.length;

  // ---------- Filtros & Busca ----------
  String _selectedAlignment = 'Todos';
  String _selectedPower = 'Todos';
  String _selectedSkill = 'Todos';
  String _searchQuery = '';

  String get selectedAlignment => _selectedAlignment;
  String get selectedPower => _selectedPower;
  String get selectedSkill => _selectedSkill;
  String get searchQuery => _searchQuery;

  /// Retorna a lista de personagens aplicando filtros e busca.
  List<MarvelCharacter> get filteredCharacters {
    return _characters.where((char) {
      // Filtro de alinhamento
      final matchAlignment =
          _selectedAlignment == 'Todos' || char.alignment == _selectedAlignment;

      // Filtro de poder (verifica se o powerType contém o termo selecionado)
      final matchPower = _selectedPower == 'Todos' ||
          (char.powerType != null && char.powerType!.contains(_selectedPower));

      // Filtro de habilidade (verifica se o skillType contém o termo selecionado)
      final matchSkill = _selectedSkill == 'Todos' ||
          (char.skillType != null && char.skillType!.contains(_selectedSkill));

      // Busca por nome
      final matchSearch = _searchQuery.isEmpty ||
          char.name.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchAlignment && matchPower && matchSkill && matchSearch;
    }).toList();
  }

  void setAlignmentFilter(String alignment) {
    _selectedAlignment = alignment;
    notifyListeners();
  }

  void setPowerFilter(String power) {
    _selectedPower = power;
    notifyListeners();
  }

  void setSkillFilter(String skill) {
    _selectedSkill = skill;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ---------- Métodos públicos ----------

  /// Carrega os personagens sempre do JSON e preserva apenas o status
  /// de coleta (isCollected) salvo no SharedPreferences.
  ///
  /// Isso garante que qualquer atualização nos dados do JSON (novos campos,
  /// valores corrigidos) seja refletida imediatamente no app.
  Future<void> loadCharacters() async {
    _isLoading = true;
    notifyListeners();

    // 1. Carrega a base completa e atualizada do JSON local
    final freshCharacters = await _loadDefaultCharacters();

    // 2. Carrega os dados salvos para recuperar o status de coleta
    final savedCharacters = await _storageService.loadCharacters();

    // 3. Mescla: aplica isCollected dos dados salvos nos dados frescos
    if (savedCharacters.isNotEmpty) {
      final savedMap = {for (var c in savedCharacters) c.id: c.isCollected};
      for (var character in freshCharacters) {
        if (savedMap.containsKey(character.id)) {
          character.isCollected = savedMap[character.id]!;
        }
      }
    }

    _characters = freshCharacters;

    // 4. Salva a versão atualizada (com novos campos + status preservado)
    await _storageService.saveCharacters(_characters);

    _isLoading = false;
    notifyListeners();
  }

  /// Alterna o estado de coleta de um personagem pelo [id].
  Future<void> toggleCollected(String id) async {
    final int index = _characters.indexWhere((c) => c.id == id);
    if (index == -1) return;

    _characters[index].isCollected = !_characters[index].isCollected;
    notifyListeners();

    await _storageService.saveCharacters(_characters);
  }

  /// Marca todos os personagens como coletados.
  Future<void> collectAll() async {
    for (final character in _characters) {
      character.isCollected = true;
    }
    notifyListeners();
    await _storageService.saveCharacters(_characters);
  }

  /// Desmarca todos os personagens.
  Future<void> uncollectAll() async {
    for (final character in _characters) {
      character.isCollected = false;
    }
    notifyListeners();
    await _storageService.saveCharacters(_characters);
  }

  // ---------- Dados padrão ----------

  /// Retorna a lista de personagens carregando o JSON local.
  Future<List<MarvelCharacter>> _loadDefaultCharacters() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/characters.json',
      );
      return MarvelCharacter.decodeList(jsonString);
    } catch (e) {
      debugPrint('Erro ao carregar os personagens padrão: $e');
      return [];
    }
  }
}
