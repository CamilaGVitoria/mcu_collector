import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/marvel_character.dart';

/// Página de detalhes de um personagem do MCU.
///
/// Exibe imagem no mesmo formato da home, classificação, descrição,
/// poderes, habilidades e um botão para coletar/remover.
class CharacterDetailView extends StatelessWidget {
  const CharacterDetailView({
    super.key,
    required this.character,
    required this.onToggleCollected,
  });

  final MarvelCharacter character;
  final VoidCallback onToggleCollected;

  static const Color marvelRed = Color(0xFFE23636);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- Imagem no formato da Home ----------
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 400, maxWidth: 300),
                child: AspectRatio(
                  aspectRatio: 0.75, // Mesma proporção da home
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Imagem com blur se não estiver coletado
                        if (character.imageUrl != null)
                          ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: character.isCollected ? 0.0 : 8.0,
                              sigmaY: character.isCollected ? 0.0 : 8.0,
                            ),
                            child: Image.network(
                              character.imageUrl!,
                              fit: BoxFit.cover,
                              headers: const {
                                'User-Agent':
                                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  color: Colors.grey[900],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: marvelRed,
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildFallbackHero(),
                            ),
                          )
                        else
                          _buildFallbackHero(),

                        // Overlay escura se não coletado
                        if (!character.isCollected)
                          Container(
                            color: Colors.black.withValues(alpha: 0.4),
                          ),

                        // Borda vermelha se coletado
                        if (character.isCollected)
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: marvelRed, width: 3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),

                        // Ícone Check se coletado
                        if (character.isCollected)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: marvelRed,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                  )
                                ],
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 24),
                            ),
                          ),

                        // Tarja de informações
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.9),
                                  Colors.transparent,
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            padding: const EdgeInsets.only(
                                top: 32.0, bottom: 12.0, left: 12.0, right: 12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  character.name,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  character.universe,
                                  style: TextStyle(
                                      color: Colors.grey.shade400, fontSize: 14),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (character.powerType != null ||
                                    character.skillType != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    [
                                      if (character.powerType != null)
                                        character.powerType,
                                      if (character.skillType != null)
                                        character.skillType,
                                    ].join(' • '),
                                    style: TextStyle(
                                        color: marvelRed.withValues(alpha: 0.8),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ---------- Conteúdo Abaixo da Imagem ----------

            // Badges de Alinhamento
            if (character.alignment != null) ...[
              Center(
                child: _buildBadge(
                  icon: _alignmentIcon(character.alignment!),
                  label: character.alignment!,
                  color: _alignmentColor(character.alignment!),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Descrição (Logo abaixo do alinhamento)
            if (character.description != null) ...[
              const Text(
                'Sobre',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                character.description!,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Seção de Poderes
            if (character.powerType != null) ...[
              _buildInfoSection(
                icon: Icons.bolt,
                title: 'Poder',
                content: character.powerType!,
              ),
              const SizedBox(height: 12),
            ],

            // Seção de Habilidades
            if (character.skillType != null) ...[
              _buildInfoSection(
                icon: Icons.fitness_center,
                title: 'Habilidade',
                content: character.skillType!,
              ),
              const SizedBox(height: 24),
            ],

            // Botão de Coletar
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  onToggleCollected();
                  Navigator.of(context).pop(true);
                },
                icon: Icon(
                  character.isCollected
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  color: character.isCollected
                      ? Colors.white70
                      : Colors.white,
                ),
                label: Text(
                  character.isCollected
                      ? 'Remover da Coleção'
                      : 'Adicionar à Coleção',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: character.isCollected
                        ? Colors.white70
                        : Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: character.isCollected
                      ? Colors.grey.shade800
                      : marvelRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ---------- Widgets auxiliares ----------

  Widget _buildFallbackHero() {
    return Container(
      color: Colors.grey.shade900,
      child: Center(
        child: Text(
          character.name[0].toUpperCase(),
          style: const TextStyle(
            color: marvelRed,
            fontSize: 120,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: marvelRed, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Helpers de alinhamento ----------

  IconData _alignmentIcon(String alignment) {
    switch (alignment) {
      case 'Herói':
        return Icons.shield;
      case 'Vilão':
        return Icons.dangerous;
      case 'Anti-Herói':
        return Icons.balance;
      case 'Neutro':
        return Icons.visibility;
      default:
        return Icons.help_outline;
    }
  }

  Color _alignmentColor(String alignment) {
    switch (alignment) {
      case 'Herói':
        return Colors.blue.shade300;
      case 'Vilão':
        return Colors.red.shade400;
      case 'Anti-Herói':
        return Colors.amber.shade400;
      case 'Neutro':
        return Colors.teal.shade300;
      default:
        return Colors.grey;
    }
  }
}
