import 'dart:ui';
import 'package:flutter/material.dart';
import '../controllers/marvel_controller.dart';
import '../models/marvel_character.dart';
import 'character_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final MarvelController _controller = MarvelController();
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  final List<String> alignmentFilters = [
    'Todos',
    'Herói',
    'Vilão',
    'Anti-Herói',
    'Neutro',
  ];
  final List<String> powerFilters = [
    'Todos',
    'Sem Poderes',
    'Tecnologia',
    'Magia',
    'Mutante',
    'Aprimorado',
    'Cósmico',
    'Divino',
    'Simbionte',
    'Radiação',
  ];
  final List<String> skillFilters = [
    'Todos',
    'Artes Marciais',
    'Tiro com Arco',
    'Espionagem',
    'Combate',
    'Tática',
    'Gênio',
    'Engenharia',
    'Piloto',
  ];

  static const Color marvelRed = Color(0xFFE23636);

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
    _controller.loadCharacters();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _controller.setSearchQuery('');
      }
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.filter_list, color: marvelRed),
              SizedBox(width: 8),
              Text('Filtros',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- Alinhamento ----------
                    const Text('Alinhamento',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildChipWrap(
                      options: alignmentFilters,
                      selected: _controller.selectedAlignment,
                      onSelect: (val) {
                        _controller.setAlignmentFilter(val);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---------- Poder ----------
                    const Text('Poder',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildChipWrap(
                      options: powerFilters,
                      selected: _controller.selectedPower,
                      onSelect: (val) {
                        _controller.setPowerFilter(val);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---------- Habilidade ----------
                    const Text('Habilidade',
                        style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildChipWrap(
                      options: skillFilters,
                      selected: _controller.selectedSkill,
                      onSelect: (val) {
                        _controller.setSkillFilter(val);
                        setDialogState(() {});
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                _controller.setAlignmentFilter('Todos');
                _controller.setPowerFilter('Todos');
                _controller.setSkillFilter('Todos');
                Navigator.of(context).pop();
              },
              child: const Text('Limpar Filtros',
                  style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar',
                  style: TextStyle(
                      color: marvelRed, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChipWrap({
    required List<String> options,
    required String selected,
    required Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: options.map((option) {
        final isSelected = selected == option;
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          selectedColor: marvelRed,
          backgroundColor: Colors.black,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (sel) {
            if (sel) onSelect(option);
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Buscar personagem...',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                ),
                onChanged: (value) => _controller.setSearchQuery(value),
              )
            : const Text('MCU Collector',
                style: TextStyle(
                    color: marvelRed, fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search,
                color: marvelRed),
            tooltip: _isSearching ? 'Fechar busca' : 'Buscar',
            onPressed: _toggleSearch,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: marvelRed),
            tooltip: 'Filtros',
            onPressed: _showFilterDialog,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
      // Badge flutuante no canto inferior direito com o contador
      floatingActionButton: _controller.isLoading
          ? null
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: marvelRed,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: marvelRed.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                '${_controller.collectedCount} / ${_controller.totalCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: marvelRed));
    }

    final filtered = _controller.filteredCharacters;

    if (filtered.isEmpty) {
      return const Center(
          child: Text('Nenhum personagem encontrado.',
              style: TextStyle(color: Colors.white)));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1200) {
          crossAxisCount = 6;
        } else if (constraints.maxWidth > 800) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 600) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: const EdgeInsets.only(
              left: 12, right: 12, top: 12, bottom: 80),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final MarvelCharacter character = filtered[index];
            return _CharacterGridItem(
              character: character,
              marvelRed: marvelRed,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CharacterDetailView(
                      character: character,
                      onToggleCollected: () =>
                          _controller.toggleCollected(character.id),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _CharacterGridItem extends StatelessWidget {
  const _CharacterGridItem({
    required this.character,
    required this.marvelRed,
    required this.onTap,
  });

  final MarvelCharacter character;
  final Color marvelRed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagem com efeito borrado se não estiver coletado
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
                      _buildFallbackAvatar(),
                ),
              )
            else
              _buildFallbackAvatar(),

            // Sobreposição escura quando NÃO coletado
            if (!character.isCollected)
              Container(
                color: Colors.black.withValues(alpha: 0.4),
              ),

            // Borda vermelha quando coletado
            if (character.isCollected)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: marvelRed, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

            // Ícone de check
            if (character.isCollected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: marvelRed,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child:
                      const Icon(Icons.check, color: Colors.white, size: 16),
                ),
              ),

            // Tarja com o nome, universo e info extra
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
                    top: 24.0, bottom: 8.0, left: 6.0, right: 6.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      character.universe,
                      style: TextStyle(
                          color: Colors.grey.shade400, fontSize: 9),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (character.powerType != null ||
                        character.skillType != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          if (character.powerType != null)
                            character.powerType,
                          if (character.skillType != null)
                            character.skillType,
                        ].join(' • '),
                        style: TextStyle(
                            color: marvelRed.withValues(alpha: 0.8),
                            fontSize: 9,
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 1,
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
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          character.name[0].toUpperCase(),
          style: TextStyle(
            color: marvelRed,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}