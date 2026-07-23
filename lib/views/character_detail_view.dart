import 'package:flutter/material.dart';

import '../models/marvel_character.dart';
import '../theme/app_colors.dart';
import '../widgets/character_image_card.dart';

/// Página de detalhes de um personagem do MCU.
class CharacterDetailView extends StatelessWidget {
  const CharacterDetailView({
    super.key,
    required this.character,
    required this.onToggleCollected,
  });

  final MarvelCharacter character;
  final VoidCallback onToggleCollected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
            // Imagem reutilizando o widget compartilhado
            Center(
              child: ConstrainedBox(
                constraints:
                    const BoxConstraints(maxHeight: 400, maxWidth: 300),
                child: AspectRatio(
                  aspectRatio: 0.75,
                  child: CharacterImageCard(
                    character: character,
                    checkIconSize: 24.0,
                    checkPadding: 6.0,
                    nameFontSize: 18.0,
                    universeFontSize: 14.0,
                    tagFontSize: 12.0,
                    nameMaxLines: 2,
                    universeMaxLines: 2,
                    tagMaxLines: 2,
                    fallbackFontSize: 120.0,
                    tarjaTopPadding: 32.0,
                    tarjaBottomPadding: 12.0,
                    tarjaHorizontalPadding: 12.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Badge de Alinhamento
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

            // Descrição
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

            // Poder
            if (character.powerType != null) ...[
              _buildInfoSection(
                icon: Icons.bolt,
                title: 'Poder',
                content: character.powerType!,
              ),
              const SizedBox(height: 12),
            ],

            // Habilidade
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
                  color:
                      character.isCollected ? Colors.white70 : Colors.white,
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
                      : AppColors.marvelRed,
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
          Icon(icon, color: AppColors.marvelRed, size: 24),
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
      case 'Anti-Vilão':
        return Icons.psychology;
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
      case 'Anti-Vilão':
        return Colors.purple.shade300;
      case 'Neutro':
        return Colors.teal.shade300;
      default:
        return Colors.grey;
    }
  }
}
