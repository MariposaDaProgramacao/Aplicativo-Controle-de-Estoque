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
  bool _lembrarMe = false;

  @override
  void initState() {
    super.initState();
    _verificarLembrarMe();
  }

  Future<void> _verificarLembrarMe() async {
    final lembrar = await _authService.deveLembrar();
    setState(() {
      _lembrarMe = lembrar;
    });
  }

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
        lembrarMe: _lembrarMe,
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
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ===== ESPAÇO EXTRA PARA DESCER A LOGO =====
                const SizedBox(height: 40),

                // ===== LOGO PURA (SEM CÍRCULO) =====
                _buildLogo(),
                const SizedBox(height: 16),

                // ===== NOME DO APP =====
                _buildAppName(),
                const SizedBox(height: 40),

                // ===== FORMULÁRIO =====
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 12),
                      _buildOptionsRow(),
                      const SizedBox(height: 24),
                      _buildLoginButton(),
                      const SizedBox(height: 16),
                      _buildRegisterLink(),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // ===== BENEFÍCIOS =====
                _buildBenefits(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== LOGO PURA (SEM CÍRCULO) ====================

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/Logo.png',
      width: 120,
      height: 120,
      fit: BoxFit.contain,
    );
  }

  // ==================== NOME DO APP ====================

  Widget _buildAppName() {
    return Column(
      children: [
        Text(
          'BoxStock',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: BoxStockColors.textoPrincipal,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Organização que cabe no seu bolso',
          style: TextStyle(
            fontSize: 14,
            color: BoxStockColors.textoPrincipal.withOpacity(0.6),
            letterSpacing: 0.3,
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 1.5,
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
          contentPadding: EdgeInsets.all(16),
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
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 1.5,
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
          contentPadding: const EdgeInsets.all(16),
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

  // ==================== OPÇÕES ====================

  Widget _buildOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _lembrarMe,
                onChanged: (value) {
                  setState(() {
                    _lembrarMe = value ?? false;
                  });
                },
                activeColor: BoxStockColors.papelaoMedio,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Lembrar-me',
              style: TextStyle(
                fontSize: 14,
                color: BoxStockColors.textoPrincipal.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== BOTÃO ENTRAR ====================

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: BoxStockColors.papelaoMedio,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: BoxStockColors.papelaoMedio.withOpacity(0.3),
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
                  fontSize: 16,
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
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Cadastre-se →',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: BoxStockColors.papelaoMedio,
            ),
          ),
        ),
      ],
    );
  }

  // ==================== BENEFÍCIOS ====================

  Widget _buildBenefits() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: BoxStockColors.fundoSecundario.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBenefitItem(
            icon: Icons.shield_outlined,
            label: 'Seguro',
            subtitle: 'Seus dados protegidos',
          ),
          _buildBenefitItem(
            icon: Icons.speed_outlined,
            label: 'Prático',
            subtitle: 'Gestão rápida',
          ),
          _buildBenefitItem(
            icon: Icons.auto_awesome_outlined,
            label: 'Completo',
            subtitle: 'Tudo que precisa',
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String label,
    required String subtitle,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BoxStockColors.papelaoMedio.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 22,
            color: BoxStockColors.papelaoMedio,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: BoxStockColors.textoPrincipal,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: BoxStockColors.textoPrincipal.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}