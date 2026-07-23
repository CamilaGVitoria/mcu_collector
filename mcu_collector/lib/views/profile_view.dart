import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/profile_service.dart';
import '../theme/app_colors.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _nameController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  final _profileService = ProfileService();

  bool _isLoading = false;
  bool _isEditingPassword = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    setState(() => _isLoading = true);
    final profile = await _profileService.getProfile();

    if (profile != null) {
      _nameController.text = profile['display_name'] ?? '';
      _avatarUrlController.text = profile['avatar_url'] ?? '';
    }
    setState(() => _isLoading = false);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.orange.shade800 : AppColors.marvelRed,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_isEditingPassword) {
      final currentPass = _currentPasswordController.text.trim();
      final newPass = _newPasswordController.text.trim();
      final confirmPass = _confirmNewPasswordController.text.trim();

      if (currentPass.isNotEmpty ||
          newPass.isNotEmpty ||
          confirmPass.isNotEmpty) {
        if (currentPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
          _showSnackBar(
            'Preencha todos os campos para alterar a senha.',
            isError: true,
          );
          return;
        }

        if (newPass != confirmPass) {
          _showSnackBar('As novas senhas não coincidem.', isError: true);
          return;
        }

        setState(() => _isLoading = true);

        try {
          final userEmail = Supabase.instance.client.auth.currentUser?.email;
          if (userEmail != null) {
            await Supabase.instance.client.auth.signInWithPassword(
              email: userEmail,
              password: currentPass,
            );
          }

          await _profileService.updatePassword(newPass);
        } on AuthException catch (_) {
          setState(() => _isLoading = false);
          _showSnackBar('A senha atual está incorreta.', isError: true);
          return;
        } catch (e) {
          setState(() => _isLoading = false);
          _showSnackBar('Erro ao atualizar a senha.', isError: true);
          return;
        }
      }
    }

    setState(() => _isLoading = true);

    try {
      await _profileService.updateProfile(
        name: _nameController.text.trim(),
        avatarUrl: _avatarUrlController.text.trim(),
      );

      if (mounted) {
        _showSnackBar('Perfil atualizado com sucesso!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Erro ao atualizar o perfil. Tente novamente.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _avatarUrlController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Meu Perfil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: AppColors.marvelRed),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.webp'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black87, BlendMode.darken),
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.marvelRed, width: 2),
              ),
              padding: const EdgeInsets.all(32.0),
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.marvelRed,
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade900,
                          backgroundImage: _avatarUrlController.text.isNotEmpty
                              ? NetworkImage(_avatarUrlController.text)
                              : null,
                          child: _avatarUrlController.text.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: AppColors.marvelRed,
                                )
                              : null,
                        ),
                        const SizedBox(height: 32),

                        _buildTextField(
                          controller: _nameController,
                          label: 'Nome de Agente (Apelido)',
                          icon: Icons.badge,
                        ),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _avatarUrlController,
                          label: 'Link da Foto de Perfil (URL)',
                          icon: Icons.link,
                          onChanged: (val) => setState(() {}),
                        ),
                        const SizedBox(height: 16),

                        Theme(
                          data: Theme.of(
                            context,
                          ).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: const Text(
                              'Alterar Senha',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: const Icon(
                              Icons.lock,
                              color: AppColors.marvelRed,
                            ),
                            iconColor: AppColors.marvelRed,
                            collapsedIconColor: Colors.white70,
                            tilePadding: EdgeInsets.zero,
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _isEditingPassword = expanded;
                                if (!expanded) {
                                  _currentPasswordController.clear();
                                  _newPasswordController.clear();
                                  _confirmNewPasswordController.clear();
                                }
                              });
                            },
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 16.0,
                                ),
                                child: Column(
                                  children: [
                                    _buildTextField(
                                      controller: _currentPasswordController,
                                      label: 'Senha Atual',
                                      icon: Icons.vpn_key_outlined,
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _newPasswordController,
                                      label: 'Nova Senha',
                                      icon: Icons.lock_reset,
                                      obscureText: true,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextField(
                                      controller: _confirmNewPasswordController,
                                      label: 'Confirmar Nova Senha',
                                      icon: Icons.check_circle_outline,
                                      obscureText: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.marvelRed,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: _saveProfile,
                            child: const Text(
                              'SALVAR ALTERAÇÕES',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.marvelRed),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade800),
          borderRadius: BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.marvelRed, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.5),
      ),
    );
  }
}
