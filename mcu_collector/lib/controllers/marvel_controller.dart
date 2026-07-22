import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/marvel_character.dart';
import '../services/storage_service.dart';

/// Controller responsável por gerenciar o estado da lista de personagens.
///
/// Utiliza [ChangeNotifier] para notificar a View sobre mudanças de estado,
/// fazendo a ponte entre a camada de apresentação e o [StorageService].
class MarvelController extends ChangeNotifier {
  final StorageService _storageService = StorageService();

  List<MarvelCharacter> _characters = [];
  List<MarvelCharacter>? _filteredCache;
  bool _isFilterDirty = true;
  bool _isLoading = false;
  String? _errorMessage;

  // ---------- Getters ----------

  List<MarvelCharacter> get characters => List.unmodifiable(_characters);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get collectedCount => _characters.where((c) => c.isCollected).length;
  int get totalCount => _characters.length;

  // ---------- Filtros & Busca ----------

  final Set<String> _selectedAlignments = {};
  final Set<String> _selectedPowers = {};
  final Set<String> _selectedSkills = {};
  String _searchQuery = '';
  bool _showOnlyCollected = false;

  Set<String> get selectedAlignments => Set.unmodifiable(_selectedAlignments);
  Set<String> get selectedPowers => Set.unmodifiable(_selectedPowers);
  Set<String> get selectedSkills => Set.unmodifiable(_selectedSkills);
  String get searchQuery => _searchQuery;
  bool get showOnlyCollected => _showOnlyCollected;

  void toggleShowOnlyCollected(bool value) {
    _showOnlyCollected = value;
    _invalidateFilterCache();
    notifyListeners();
  }

  /// Retorna a lista de personagens aplicando todos os filtros ativos.
  List<MarvelCharacter> get filteredCharacters {
    if (!_isFilterDirty && _filteredCache != null) {
      return _filteredCache!;
    }

    _filteredCache = _characters.where((char) {
      final matchAlignment =
          _selectedAlignments.isEmpty ||
          _selectedAlignments.contains(char.alignment);

      final matchPower =
          _selectedPowers.isEmpty ||
          _selectedPowers.any(
            (p) => char.powerType != null && char.powerType!.contains(p),
          );

      final matchSkill =
          _selectedSkills.isEmpty ||
          _selectedSkills.any(
            (s) => char.skillType != null && char.skillType!.contains(s),
          );

      final matchSearch =
          _searchQuery.isEmpty ||
          char.name.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchCollected = !_showOnlyCollected || char.isCollected;

      return matchAlignment &&
          matchPower &&
          matchSkill &&
          matchSearch &&
          matchCollected;
    }).toList();

    _isFilterDirty = false;
    return _filteredCache!;
  }

  void _invalidateFilterCache() {
    _isFilterDirty = true;
    _filteredCache = null;
  }

  void toggleAlignmentFilter(String alignment) {
    if (_selectedAlignments.contains(alignment)) {
      _selectedAlignments.remove(alignment);
    } else {
      _selectedAlignments.add(alignment);
    }
    _invalidateFilterCache();
    notifyListeners();
  }

  void togglePowerFilter(String power) {
    if (_selectedPowers.contains(power)) {
      _selectedPowers.remove(power);
    } else {
      _selectedPowers.add(power);
    }
    _invalidateFilterCache();
    notifyListeners();
  }

  void toggleSkillFilter(String skill) {
    if (_selectedSkills.contains(skill)) {
      _selectedSkills.remove(skill);
    } else {
      _selectedSkills.add(skill);
    }
    _invalidateFilterCache();
    notifyListeners();
  }

  void clearFilters() {
    _selectedAlignments.clear();
    _selectedPowers.clear();
    _selectedSkills.clear();
    _invalidateFilterCache();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _invalidateFilterCache();
    notifyListeners();
  }

  // ---------- Carregamento ----------

  Future<void> loadCharacters() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final freshCharacters = await _fetchCharactersFromSupabase();

    if (freshCharacters.isEmpty && _characters.isEmpty) {
      _errorMessage =
          'Não foi possível carregar os personagens. Verifique sua conexão.';
    } else if (freshCharacters.isEmpty && _characters.isNotEmpty) {
      // Mantém a lista anterior e apenas sinaliza o erro
      _errorMessage = 'Falha ao atualizar. Exibindo dados anteriores.';
    } else {
      final collectedIds = await _storageService.loadCollectedIds();

      _characters = freshCharacters.map((character) {
        if (collectedIds.contains(character.id)) {
          return character.copyWith(isCollected: true);
        }
        return character;
      }).toList();
    }

    _isLoading = false;
    _invalidateFilterCache();
    notifyListeners();
  }

  Future<List<MarvelCharacter>> _fetchCharactersFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('characters')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => MarvelCharacter.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar do Supabase: $e');
      return [];
    }
  }

  // ---------- Coleção ----------

  Future<void> toggleCollected(String id) async {
    final int index = _characters.indexWhere((c) => c.id == id);
    if (index == -1) return;

    final character = _characters[index];
    _characters[index] = character.copyWith(
      isCollected: !character.isCollected,
    );
    _invalidateFilterCache();
    notifyListeners();

    try {
      await _storageService.toggleCharacter(
        _characters[index].id,
        _characters[index].isCollected,
      );
    } catch (e) {
      // Rollback: restaura o estado anterior
      _characters[index] = character;
      _invalidateFilterCache();
      notifyListeners();
      debugPrint('Erro ao salvar coleção: $e');
    }
  }
}
