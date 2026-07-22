import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/marvel_character.dart';
import '../theme/app_colors.dart';

/// Widget reutilizável que exibe a imagem de um personagem com efeitos visuais.
///
/// Aplica blur e overlay escura quando o personagem não está coletado,
/// borda vermelha e ícone de check quando coletado, e tarja de informações.
class CharacterImageCard extends StatelessWidget {
  const CharacterImageCard({
    super.key,
    required this.character,
    this.onToggleCollected,
    this.checkIconSize = 16.0,
    this.checkPadding = 4.0,
    this.nameFontSize = 12.0,
    this.universeFontSize = 9.0,
    this.tagFontSize = 9.0,
    this.nameMaxLines = 1,
    this.universeMaxLines = 1,
    this.tagMaxLines = 1,
    this.fallbackFontSize = 48.0,
    this.tarjaTopPadding = 24.0,
    this.tarjaBottomPadding = 8.0,
    this.tarjaHorizontalPadding = 6.0,
  });

  final MarvelCharacter character;
  final VoidCallback? onToggleCollected;
  final double checkIconSize;
  final double checkPadding;
  final double nameFontSize;
  final double universeFontSize;
  final double tagFontSize;
  final int nameMaxLines;
  final int universeMaxLines;
  final int tagMaxLines;
  final double fallbackFontSize;
  final double tarjaTopPadding;
  final double tarjaBottomPadding;
  final double tarjaHorizontalPadding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagem com blur quando não coletado
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
                        color: AppColors.marvelRed,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackAvatar(),
              ),
            )
          else
            _buildFallbackAvatar(),

          // Overlay escura quando não coletado
          if (!character.isCollected)
            Container(color: Colors.black.withValues(alpha: 0.4)),

          // Borda vermelha quando coletado
          if (character.isCollected)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.marvelRed, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

          // Ícone de check ou add
          Positioned(
            top: 8,
            right: 8,
            child: Material(
              color: character.isCollected 
                  ? AppColors.marvelRed 
                  : Colors.grey.withValues(alpha: 0.8),
              shape: const CircleBorder(),
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.5),
              child: InkWell(
                onTap: onToggleCollected,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(checkPadding),
                  child: Icon(
                    character.isCollected ? Icons.check : Icons.add, 
                    color: Colors.white, 
                    size: checkIconSize,
                  ),
                ),
              ),
            ),
          ),

          // Tarja com nome, universo e tags
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
              padding: EdgeInsets.only(
                top: tarjaTopPadding,
                bottom: tarjaBottomPadding,
                left: tarjaHorizontalPadding,
                right: tarjaHorizontalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    character.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: nameFontSize,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: nameMaxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    character.universe,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: universeFontSize,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: universeMaxLines,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (character.powerType != null ||
                      character.skillType != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (character.powerType != null) character.powerType,
                        if (character.skillType != null) character.skillType,
                      ].join(' • '),
                      style: TextStyle(
                        color: AppColors.marvelRed.withValues(alpha: 0.8),
                        fontSize: tagFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: tagMaxLines,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey.shade900, Colors.grey.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
          style: TextStyle(
            color: AppColors.marvelRed,
            fontSize: fallbackFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
