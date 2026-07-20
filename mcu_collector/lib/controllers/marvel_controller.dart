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

  /// ---------- Filtros & Busca ----------
  final Set<String> _selectedAlignments = {};
  final Set<String> _selectedPowers = {};
  final Set<String> _selectedSkills = {};
  String _searchQuery = '';
  bool _showOnlyCollected = false; // NOVA VARIÁVEL DO TOGGLE

  Set<String> get selectedAlignments => _selectedAlignments;
  Set<String> get selectedPowers => _selectedPowers;
  Set<String> get selectedSkills => _selectedSkills;
  String get searchQuery => _searchQuery;
  bool get showOnlyCollected => _showOnlyCollected; // NOVO GETTER

  /// Alterna a visualização para mostrar apenas a coleção
  void toggleShowOnlyCollected(bool value) {
    _showOnlyCollected = value;
    notifyListeners();
  }

  /// Retorna a lista de personagens aplicando filtros, busca e o toggle de coleção.
  List<MarvelCharacter> get filteredCharacters {
    return _characters.where((char) {
      // Filtro de alinhamento
      final matchAlignment = _selectedAlignments.isEmpty ||
          _selectedAlignments.contains(char.alignment);

      // Filtro de poder
      final matchPower = _selectedPowers.isEmpty ||
          (_selectedPowers.any((power) => char.powerType != null && char.powerType!.contains(power)));

      // Filtro de habilidade
      final matchSkill = _selectedSkills.isEmpty ||
          (_selectedSkills.any((skill) => char.skillType != null && char.skillType!.contains(skill)));

      // Busca por nome
      final matchSearch =
          _searchQuery.isEmpty ||
          char.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // NOVO: Filtro do Toggle (Só Capturados)
      final matchCollected = !_showOnlyCollected || char.isCollected;

      return matchAlignment &&
          matchPower &&
          matchSkill &&
          matchSearch &&
          matchCollected;
    }).toList();
  }

  void toggleAlignmentFilter(String alignment) {
    if (_selectedAlignments.contains(alignment)) {
      _selectedAlignments.remove(alignment);
    } else {
      _selectedAlignments.add(alignment);
    }
    notifyListeners();
  }

  void togglePowerFilter(String power) {
    if (_selectedPowers.contains(power)) {
      _selectedPowers.remove(power);
    } else {
      _selectedPowers.add(power);
    }
    notifyListeners();
  }

  void toggleSkillFilter(String skill) {
    if (_selectedSkills.contains(skill)) {
      _selectedSkills.remove(skill);
    } else {
      _selectedSkills.add(skill);
    }
    notifyListeners();
  }

  void clearFilters() {
    _selectedAlignments.clear();
    _selectedPowers.clear();
    _selectedSkills.clear();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ---------- Métodos públicos ----------

  Future<void> loadCharacters() async {
    _isLoading = true;
    notifyListeners();

    // 1. Busca a base completa diretamente da tabela 'characters' no Supabase
    final freshCharacters = await _fetchCharactersFromSupabase();

    // 2. Busca apenas os IDs dos personagens coletados pelo usuário
    final collectedIds = await _storageService.loadCollectedIds();

    // 3. Mescla as informações
    for (var character in freshCharacters) {
      if (collectedIds.contains(character.id)) {
        character.isCollected = true;
      }
    }

    _characters = freshCharacters;
    _isLoading = false;
    notifyListeners();
  }

  /// Faz a requisição GET para a tabela de personagens no Supabase já em ordem alfabética
  Future<List<MarvelCharacter>> _fetchCharactersFromSupabase() async {
    try {
      final response = await Supabase.instance.client
          .from('characters')
          .select()
          .order('name', ascending: true); // <-- A mágica acontece nesta linha!

      return (response as List)
          .map((json) => MarvelCharacter.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Erro ao buscar do Supabase: $e');
      return [];
    }
  }

  Future<void> toggleCollected(String id) async {
    // 1. Encontra o personagem na lista atual
    final int index = _characters.indexWhere((c) => c.id == id);
    if (index == -1) return;

    // 2. Altera o status visualmente na hora
    final character = _characters[index];
    character.isCollected = !character.isCollected;
    notifyListeners();

    // 3. Salva a alteração no banco de dados do Supabase
    await _storageService.toggleCharacter(character.id, character.isCollected);
  }
}
