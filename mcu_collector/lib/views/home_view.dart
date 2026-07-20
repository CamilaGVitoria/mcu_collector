import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../controllers/marvel_controller.dart';
import '../models/marvel_character.dart';
import '../theme/app_colors.dart';
import '../widgets/character_image_card.dart';
import 'auth_view.dart';
import 'character_detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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

  @override
  void initState() {
    super.initState();
    // Carrega os personagens após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MarvelController>().loadCharacters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch(MarvelController controller) {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        controller.setSearchQuery('');
      }
    });
  }

  void _showFilterDialog(MarvelController controller) {
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
              Icon(Icons.filter_list, color: AppColors.marvelRed),
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
                      selectedOptions: controller.selectedAlignments,
                      onSelect: (val) {
                        controller.toggleAlignmentFilter(val);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

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
                      selectedOptions: controller.selectedPowers,
                      onSelect: (val) {
                        controller.togglePowerFilter(val);
                        setDialogState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

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
                      selectedOptions: controller.selectedSkills,
                      onSelect: (val) {
                        controller.toggleSkillFilter(val);
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
                controller.clearFilters();
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
                style: TextStyle(
                    color: AppColors.marvelRed, fontWeight: FontWeight.bold),
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
          selectedColor: AppColors.marvelRed,
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
    return Consumer<MarvelController>(
      builder: (context, controller, _) {
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
                    onChanged: (value) => controller.setSearchQuery(value),
                  )
                : const Text(
                    'MCU Collector',
                    style: TextStyle(
                        color: AppColors.marvelRed,
                        fontWeight: FontWeight.bold),
                  ),
            centerTitle: false,
            backgroundColor: Colors.black,
            actions: [
              IconButton(
                icon: Icon(
                  _isSearching ? Icons.close : Icons.search,
                  color: AppColors.marvelRed,
                ),
                tooltip: _isSearching ? 'Fechar busca' : 'Buscar',
                onPressed: () => _toggleSearch(controller),
              ),
              const SizedBox(width: 4),
            ],
          ),
          drawer: _buildDrawer(context),
          body: Column(
            children: [
              _buildActionBar(context, controller),
              Expanded(child: _buildBody(controller)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionBar(BuildContext context, MarvelController controller) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        border: const Border(
          bottom: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: isDesktop
          ? Row(
              children: [
                // Divisão 1: Contagem (Esquerda)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${controller.collectedCount} / ${controller.totalCount}',
                      style: const TextStyle(
                        color: AppColors.marvelRed,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                // Divisões 2 e 3: Na Coleção + Filtros de Alinhamento (Centro)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Na Coleção
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
                      value: controller.showOnlyCollected,
                      onChanged: controller.toggleShowOnlyCollected,
                      activeThumbColor: AppColors.marvelRed,
                      activeTrackColor: AppColors.marvelRed.withValues(alpha: 0.4),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade800,
                    ),
                    const SizedBox(width: 16),
                    Container(height: 24, width: 1, color: Colors.white24),
                    const SizedBox(width: 16),

                    // Filtros de Alinhamento
                    ...alignmentFilters.map((option) {
                      final isSelected =
                          controller.selectedAlignments.contains(option);
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: FilterChip(
                          label: Text(option),
                          selected: isSelected,
                          selectedColor: AppColors.marvelRed,
                          backgroundColor: Colors.black,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            controller.toggleAlignmentFilter(option);
                          },
                        ),
                      );
                    }),
                  ],
                ),

                // Divisão 4: Filtros Avançados (Direita)
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.filter_list, color: AppColors.marvelRed),
                      tooltip: 'Filtros Avançados',
                      onPressed: () => _showFilterDialog(controller),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Divisão 1: Contagem
                Text(
                  '${controller.collectedCount} / ${controller.totalCount}',
                  style: const TextStyle(
                    color: AppColors.marvelRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                // Divisão 2: Na Coleção
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                      value: controller.showOnlyCollected,
                      onChanged: controller.toggleShowOnlyCollected,
                      activeThumbColor: AppColors.marvelRed,
                      activeTrackColor: AppColors.marvelRed.withValues(alpha: 0.4),
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade800,
                    ),
                  ],
                ),

                // Divisão 3: Filtros Avançados
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.filter_list, color: AppColors.marvelRed),
                  tooltip: 'Filtros Avançados',
                  onPressed: () => _showFilterDialog(controller),
                ),
              ],
            ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final userEmail = user?.email ?? 'Agente desconhecido';

    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.marvelRed),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child:
                  Icon(Icons.person, color: AppColors.marvelRed, size: 40),
            ),
            accountName: const Text(
              'Agente S.H.I.E.L.D.',
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
              Navigator.pop(context);
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            title: const Text(
              'Sair',
              style: TextStyle(
                  color: AppColors.marvelRed, fontWeight: FontWeight.bold),
            ),
            leading:
                const Icon(Icons.logout, color: AppColors.marvelRed),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();

              if (context.mounted) {
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

  Widget _buildBody(MarvelController controller) {
    if (controller.isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.marvelRed));
    }

    if (controller.errorMessage != null && controller.totalCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, color: Colors.white38, size: 64),
              const SizedBox(height: 16),
              Text(
                controller.errorMessage!,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => controller.loadCharacters(),
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.marvelRed,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = controller.filteredCharacters;

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
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final MarvelCharacter character = filtered[index];
            return GestureDetector(
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CharacterDetailView(
                      character: character,
                      onToggleCollected: () =>
                          controller.toggleCollected(character.id),
                    ),
                  ),
                );
              },
              child: CharacterImageCard(character: character),
            );
          },
        );
      },
    );
  }
}
