import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_view.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController =
      TextEditingController(); // Novo controller para confirmar senha

  bool _isLoading = false;
  bool _isLogin = true;

  static const Color marvelRed = Color(0xFFE23636);

  Future<void> _authenticate() async {
    // Validação extra para o Cadastro
    if (!_isLogin) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('As senhas não coincidem. Tente novamente.'),
            backgroundColor: marvelRed,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await Supabase.instance.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await Supabase.instance.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomeView()));
      }
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: marvelRed),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro inesperado ocorreu.'),
          backgroundColor: marvelRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Imagem de fundo configurada
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
              // Card centralizado com as cores da Marvel
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: marvelRed, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: marvelRed.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / Título
                  const Text(
                    'MARVEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      backgroundColor: marvelRed,
                    ),
                  ),
                  const Text(
                    'COLLECTOR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Campo E-mail
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.email, color: marvelRed),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: marvelRed, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Campo Senha
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Senha',
                      labelStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.lock, color: marvelRed),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade800),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: marvelRed, width: 2),
                      ),
                    ),
                  ),

                  // Campo Confirmar Senha (Aparece apenas no Cadastro)
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Confirmar Senha',
                        labelStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: marvelRed,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade800),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: marvelRed, width: 2),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Botão de Ação (Entrar / Cadastrar)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: marvelRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _isLoading ? null : _authenticate,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : Text(
                              _isLogin ? 'ENTRAR' : 'CADASTRAR',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Alternar entre Login e Cadastro
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        // Limpa os campos ao trocar de tela
                        _emailController.clear();
                        _passwordController.clear();
                        _confirmPasswordController.clear();
                      });
                    },
                    child: Text(
                      _isLogin ? 'Criar nova conta' : 'Já tenho uma conta',
                      style: const TextStyle(
                        color: Colors.white70,
                        decoration: TextDecoration.underline,
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
}
