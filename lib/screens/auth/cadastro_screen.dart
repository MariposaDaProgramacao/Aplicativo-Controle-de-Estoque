import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../main.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.register(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Conta criada com sucesso! Faça login.'),
          backgroundColor: BoxStockColors.sucesso,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.pop(context);
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
      appBar: AppBar(
        title: const Text(
          'Criar Conta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: BoxStockColors.papelaoMedio,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: BoxStockColors.papelaoClaro,
              boxShadow: [
                BoxShadow(
                  color: BoxStockColors.papelaoEscuro.withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ===== LOGO =====
                  _buildLogo(),
                  const SizedBox(height: 32),

                  // ===== CAMPOS =====
                  _buildEmailField(),
                  const SizedBox(height: 16),
                  _buildPasswordField(),
                  const SizedBox(height: 16),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 24),

                  // ===== BOTÃO CADASTRAR =====
                  _buildRegisterButton(),
                  const SizedBox(height: 16),

                  // ===== LINK LOGIN =====
                  _buildLoginLink(),
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
            // Sombra
            Container(
              width: 80,
              height: 80,
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
              width: 70,
              height: 70,
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
                    top: 8,
                    left: 12,
                    right: 12,
                    child: Container(
                      height: 5,
                      decoration: BoxDecoration(
                        color: BoxStockColors.fundoSecundario.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const Center(
                    child: Icon(
                      Icons.person_add,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  // Fita adesiva inferior
                  Positioned(
                    bottom: 8,
                    left: 15,
                    right: 15,
                    child: Container(
                      height: 3,
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
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: BoxStockColors.textoPrincipal,
          ),
        ),

        // Subtítulo
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: BoxStockColors.fundoSecundario,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: BoxStockColors.papelaoClaro.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text(
            'Crie sua conta gratuita',
            style: TextStyle(
              fontSize: 12,
              color: BoxStockColors.textoPrincipal.withOpacity(0.7),
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
          hintText: 'exemplo@email.com',
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w400,
          ),
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
          hintText: 'Mínimo 6 caracteres',
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.4),
            fontWeight: FontWeight.w400,
          ),
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

  Widget _buildConfirmPasswordField() {
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
        controller: _confirmPasswordController,
        obscureText: _obscureConfirmPassword,
        style: TextStyle(
          color: BoxStockColors.textoPrincipal,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: 'Confirmar Senha',
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
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: BoxStockColors.papelaoMedio,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
          hintText: 'Digite a senha novamente',
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.4),
            fontWeight: FontWeight.w400,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Confirme sua senha';
          }
          if (value != _passwordController.text) {
            return 'As senhas não coincidem';
          }
          return null;
        },
      ),
    );
  }

  // ==================== BOTÃO CADASTRAR ====================

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
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
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.person_add, size: 20, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Cadastrar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ==================== LINK LOGIN ====================

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Já tem uma conta? ',
          style: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            foregroundColor: BoxStockColors.papelaoMedio,
          ),
          child: const Text(
            'Faça login',
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