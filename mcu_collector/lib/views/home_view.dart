import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:mcu_collector/views/auth_view.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    'Herói',
    'Vilão',
    'Anti-Herói',
    'Anti-Vilão',
    'Neutro',
  ];
  final List<String> powerFilters = [
    'Sem Poderes',
    'Modificado Genéticamente',
    'Mutante',
    'Místico',
    'Sobrenatural',
    'Cósmico',
    'Divindade',
  ];
  final List<String> skillFilters = [
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.filter_list, color: marvelRed),
              SizedBox(width: 8),
              Text(
                'Filtros',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                    const Text(
                      'Alinhamento',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildChipWrap(
                      options: alignmentFilters,
                      selectedOptions: _controller.selectedAlignments,
                      onSelect: (val) {
                        _controller.toggleAlignmentFilter(val);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---------- Poder ----------
                    const Text(
                      'Poder',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildChipWrap(
                      options: powerFilters,
                      selectedOptions: _controller.selectedPowers,
                      onSelect: (val) {
                        _controller.togglePowerFilter(val);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    // ---------- Habilidade ----------
                    const Text(
                      'Habilidade',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildChipWrap(
                      options: skillFilters,
                      selectedOptions: _controller.selectedSkills,
                      onSelect: (val) {
                        _controller.toggleSkillFilter(val);
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
                _controller.clearFilters();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Limpar Filtros',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Fechar',
                style: TextStyle(color: marvelRed, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildChipWrap({
    required List<String> options,
    required Set<String> selectedOptions,
    required Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: options.map((option) {
        final isSelected = selectedOptions.contains(option);
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          selectedColor: marvelRed,
          backgroundColor: Colors.black,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          onSelected: (sel) {
            onSelect(option);
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
            : const Text(
                'MCU Collector',
                style: TextStyle(color: marvelRed, fontWeight: FontWeight.bold),
              ),
        centerTitle: false,
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: marvelRed,
            ),
            tooltip: _isSearching ? 'Fechar busca' : 'Buscar',
            onPressed: _toggleSearch,
          ),
          const SizedBox(width: 4), // Filtro e Contador foram removidos daqui
        ],
      ),
      drawer: _buildDrawer(context),

      // O Body agora é uma coluna contendo a barra de ações e o GridView
      body: Column(
        children: [
          _buildActionBar(),
          Expanded(child: _buildBody()),
        ],
      ),

      // O floatingActionButton foi removido inteiramente!
    );
  }

  // NOVA BARRA DE FERRAMENTAS
  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: const Border(
          bottom: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          children: [
            // 1. Contador
            Text(
              '${_controller.collectedCount} / ${_controller.totalCount}',
              style: const TextStyle(
                color: marvelRed,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 16),
            Container(height: 24, width: 1, color: Colors.white24),
            const SizedBox(width: 16),

            // 2. Toggle "Na Coleção"
            const Text(
              'Na Coleção',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Switch(
              value: _controller.showOnlyCollected,
              onChanged: _controller.toggleShowOnlyCollected,
              activeThumbColor: marvelRed,
              activeTrackColor: marvelRed.withValues(alpha: 0.4),
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade800,
            ),
            const SizedBox(width: 16),
            Container(height: 24, width: 1, color: Colors.white24),
            const SizedBox(width: 16),

            // 3. Filtros de Alinhamento
            ...alignmentFilters.map((option) {
              final isSelected = _controller.selectedAlignments.contains(option);
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  selectedColor: marvelRed,
                  backgroundColor: Colors.black,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    _controller.toggleAlignmentFilter(option);
                  },
                ),
              );
            }),
            const SizedBox(width: 8),

            // 4. Botão de Filtro (Filtros Avançados)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.filter_list, color: marvelRed),
              tooltip: 'Filtros Avançados',
              onPressed: _showFilterDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    // Busca o usuário atual logado no Supabase
    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email ?? 'Agente desconhecido';

    return Drawer(
      backgroundColor: const Color(0xFF121212), // Fundo escuro
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: marvelRed, // Vermelho Marvel no cabeçalho
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: marvelRed, size: 40),
            ),
            accountName: const Text(
              'Agente S.H.I.E.L.D.', // Um placeholder temático
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              userEmail,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ListTile(
            title: const Text(
              'Meu Perfil',
              style: TextStyle(color: Colors.white),
            ),
            leading: const Icon(
              Icons.account_circle_rounded,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context); // Fecha o drawer
              // Aqui você pode adicionar o Navigator.push para a tela de perfil no futuro
            },
          ),
          const Divider(color: Colors.white24), // Linha divisória suave
          ListTile(
            title: Text(
              'Sair',
              style: TextStyle(color: marvelRed, fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.logout, color: marvelRed),
            onTap: () async {
              // Lógica real de deslogar do Supabase
              await Supabase.instance.client.auth.signOut();

              if (context.mounted) {
                // Redireciona de volta para a AuthView e limpa o histórico de navegação
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const AuthView()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: marvelRed));
    }

    final filtered = _controller.filteredCharacters;

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'Nenhum personagem encontrado.',
          style: TextStyle(color: Colors.white),
        ),
      );
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
          padding: const EdgeInsets.all(
            12,
          ), // Padding ajustado sem o botão flutuante
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
              Container(color: Colors.black.withValues(alpha: 0.4)),

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
                      ),
                    ],
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
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
                  top: 24.0,
                  bottom: 8.0,
                  left: 6.0,
                  right: 6.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      character.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      character.universe,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
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
                          color: marvelRed.withValues(alpha: 0.8),
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
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
          colors: [Colors.grey.shade900, Colors.grey.shade800],
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
