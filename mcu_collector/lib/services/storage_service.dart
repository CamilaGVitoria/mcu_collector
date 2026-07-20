import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Serviço responsável pela persistência de dados no Supabase.
class StorageService {
  StorageService._internal();
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;

  final _supabase = Supabase.instance.client;

  /// Busca os IDs dos personagens que o usuário logado já coletou.
  Future<List<String>> loadCollectedIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _supabase
          .from('collected_characters')
          .select('character_id')
          .eq('user_id', user.id);

      return (response as List)
          .map((row) => row['character_id'] as String)
          .toList();
    } catch (e) {
      debugPrint('Erro ao carregar coleção: $e');
      return [];
    }
  }

  /// Adiciona ou remove um personagem da coleção na nuvem.
  Future<void> toggleCharacter(String characterId, bool isCollected) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      if (isCollected) {
        await _supabase.from('collected_characters').insert({
          'user_id': user.id,
          'character_id': characterId,
        });
      } else {
        await _supabase
            .from('collected_characters')
            .delete()
            .eq('user_id', user.id)
            .eq('character_id', characterId);
      }
    } catch (e) {
      debugPrint('Erro ao atualizar coleção: $e');
      rethrow;
    }
  }
}