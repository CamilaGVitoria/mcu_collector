import 'dart:convert';

/// Modelo que representa um personagem do universo Marvel.
///
/// Contém informações básicas do personagem e um flag [isCollected]
/// para indicar se o usuário já o adicionou à sua coleção.
class MarvelCharacter {
  final String id;
  final String name;
  final String universe;
  final String? imageUrl;
  final String? alignment;
  final String? powerType;
  final String? skillType;
  final String? description;
  final bool isCollected;

  MarvelCharacter({
    required this.id,
    required this.name,
    required this.universe,
    this.imageUrl,
    this.alignment,
    this.powerType,
    this.skillType,
    this.description,
    this.isCollected = false,
  });

  /// Cria uma instância de [MarvelCharacter] a partir de um [Map] JSON.
  factory MarvelCharacter.fromJson(Map<String, dynamic> json) {
    return MarvelCharacter(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      universe: json['universe']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString(),
      alignment: json['alignment']?.toString(),
      powerType: json['powerType']?.toString(),
      skillType: json['skillType']?.toString(),
      description: json['description']?.toString(),
      isCollected: json['isCollected'] as bool? ?? false,
    );
  }

  /// Converte a instância para um [Map] compatível com JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'universe': universe,
      'imageUrl': imageUrl,
      'alignment': alignment,
      'powerType': powerType,
      'skillType': skillType,
      'description': description,
      'isCollected': isCollected,
    };
  }

  /// Cria uma cópia do personagem com os campos alterados.
  MarvelCharacter copyWith({
    String? id,
    String? name,
    String? universe,
    String? imageUrl,
    String? alignment,
    String? powerType,
    String? skillType,
    String? description,
    bool? isCollected,
  }) {
    return MarvelCharacter(
      id: id ?? this.id,
      name: name ?? this.name,
      universe: universe ?? this.universe,
      imageUrl: imageUrl ?? this.imageUrl,
      alignment: alignment ?? this.alignment,
      powerType: powerType ?? this.powerType,
      skillType: skillType ?? this.skillType,
      description: description ?? this.description,
      isCollected: isCollected ?? this.isCollected,
    );
  }

  /// Serializa uma lista de [MarvelCharacter] para uma String JSON.
  static String encodeList(List<MarvelCharacter> characters) {
    return jsonEncode(characters.map((c) => c.toJson()).toList());
  }

  /// Deserializa uma String JSON para uma lista de [MarvelCharacter].
  static List<MarvelCharacter> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
    return jsonList
        .map((json) => MarvelCharacter.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  String toString() =>
      'MarvelCharacter(id: $id, name: $name, universe: $universe, alignment: $alignment, powerType: $powerType, skillType: $skillType, isCollected: $isCollected)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarvelCharacter &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
