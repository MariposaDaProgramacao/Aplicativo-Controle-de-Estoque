import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../main.dart';
import 'cadastro_screen.dart';
import '../main/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: BoxStockColors.alerta),
            SizedBox(width: 8),
            Text('Erro'),
          ],
        ),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: BoxStockColors.papelaoMedio,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BoxStockColors.fundoPrincipal,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ===== LOGO / CAIXA 3D =====
                  _buildLogo(),
                  const SizedBox(height: 40),

                  // ===== CAMPOS =====
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 24),

                  // ===== BOTÃO ENTRAR =====
                  _buildLoginButton(),
                  const SizedBox(height: 16),

                  // ===== LINK CADASTRO =====
                  _buildRegisterLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LOGO ====================

  Widget _buildLogo() {
    return Column(
      children: [
        // Caixa 3D com ícone
        Stack(
          alignment: Alignment.center,
          children: [
            // Sombra da caixa
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: BoxStockColors.papelaoEscuro.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: BoxStockColors.papelaoEscuro.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
            ),
            // Caixa principal
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    BoxStockColors.papelaoClaro,
                    BoxStockColors.papelaoMedio,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: BoxStockColors.papelaoEscuro.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
                border: Border.all(
                  color: BoxStockColors.papelaoClaro.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Fita adesiva
                  Positioned(
                    top: 10,
                    left: 15,
                    right: 15,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: BoxStockColors.fundoSecundario.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: BoxStockColors.papelaoEscuro.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Ícone
                  const Center(
                    child: Icon(
                      Icons.inventory_2,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  // Fita adesiva inferior
                  Positioned(
                    bottom: 10,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: BoxStockColors.fundoSecundario.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Nome do App
        Text(
          '📦 BoxStock',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: BoxStockColors.textoPrincipal,
            letterSpacing: 1,
          ),
        ),

        // Slogan
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: BoxStockColors.fundoSecundario,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: BoxStockColors.papelaoClaro.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            '📦 Organização que cabe no seu bolso',
            style: TextStyle(
              fontSize: 13,
              color: BoxStockColors.textoPrincipal.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== CAMPOS ====================

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: BoxStockColors.papelaoClaro.withOpacity(0.2),
            offset: const Offset(-2, -2),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          color: BoxStockColors.textoPrincipal,
          fontSize: 16,
        ),
        decoration: const InputDecoration(
          labelText: 'E-mail',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.email_outlined,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Digite seu e-mail';
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Digite um e-mail válido';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: BoxStockColors.papelaoClaro.withOpacity(0.2),
            offset: const Offset(-2, -2),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(
          color: BoxStockColors.textoPrincipal,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: 'Senha',
          labelStyle: const TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: BoxStockColors.papelaoMedio,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: BoxStockColors.papelaoMedio,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Digite sua senha';
          }
          if (value.length < 6) {
            return 'A senha deve ter no mínimo 6 caracteres';
          }
          return null;
        },
      ),
    );
  }

  // ==================== BOTÃO ENTRAR ====================

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: BoxStockColors.papelaoMedio,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
          shadowColor: BoxStockColors.papelaoMedio.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Entrar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  // ==================== LINK CADASTRO ====================

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Não tem uma conta? ',
          style: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CadastroScreen(),
              ),
            );
          },
          style: TextButton.styleFrom(
            foregroundColor: BoxStockColors.papelaoMedio,
          ),
          child: const Text(
            'Cadastre-se',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}