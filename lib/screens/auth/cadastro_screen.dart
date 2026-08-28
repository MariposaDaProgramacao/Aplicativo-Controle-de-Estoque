// ============================================================
// 📁 cadastro_screen.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está em uma "RECEPÇÃO"
//              onde as pessoas fazem seu cadastro para entrar
//              no sistema. Essa tela é o FORMULÁRIO DE CADASTRO
//              onde o usuário cria sua conta.
// 
// 🏠 Ele é como a "PORTARIA" do prédio:
//    - O usuário preenche o formulário (e-mail e senha)
//    - O sistema verifica se os dados são válidos
//    - Se tudo estiver certo, cria uma conta no Firebase
//    - O usuário pode então fazer login e entrar no sistema
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o pacote do Flutter para construir telas
// Isso permite usar widgets como Scaffold, Text, Column, etc.
import 'package:flutter/material.dart';

// Linha 2: Importa o serviço de autenticação que criamos
// Isso permite chamar funções como register(), login(), etc.
import '../../services/auth_service.dart';

// Linha 3: Importa o arquivo principal que tem as cores do sistema
// Isso permite usar BoxStockColors.sucesso, BoxStockColors.alerta, etc.
import '../../main.dart';

// ============================================================
// 🏠 CLASSE CADASTROSCREEN — A "TELA DE CADASTRO"
// ============================================================
// Linha 7: Define a classe CadastroScreen que é uma "tela com estado"
// StatefulWidget significa que a tela pode mudar (ex: mostrar carregando)
class CadastroScreen extends StatefulWidget {
  // Linha 8: Construtor da classe, com uma chave opcional
  const CadastroScreen({super.key});

  // Linha 10-12: Cria o estado da tela
  // O Flutter chama isso para criar a "memória" da tela
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

// ============================================================
// 🧠 _CADASTROSCREENSTATE — A "MEMÓRIA" DA TELA
// ============================================================
// Linha 18: Classe que guarda o estado da tela (o que o usuário digitou, etc.)
class _CadastroScreenState extends State<CadastroScreen> {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" da tela
  // ============================================================
  
  // Linha 21: Chave do formulário. Serve para validar todos os campos juntos.
  // Exemplo: Quando o usuário clica em "Cadastrar", verificamos se tudo está certo.
  final _formKey = GlobalKey<FormState>();
  
  // Linha 23: Controlador do campo de e-mail.
  // Guarda o que o usuário digita no campo "E-mail".
  final _emailController = TextEditingController();
  
  // Linha 24: Controlador do campo de senha.
  // Guarda o que o usuário digita no campo "Senha".
  final _passwordController = TextEditingController();
  
  // Linha 25: Controlador do campo de confirmação de senha.
  // Guarda o que o usuário digita no campo "Confirmar Senha".
  final _confirmPasswordController = TextEditingController();
  
  // Linha 27: Instância do serviço de autenticação.
  // É o "ajudante" que vai criar a conta no Firebase.
  final _authService = AuthService();
  
  // Linha 29: Variável que controla se está carregando.
  // Quando true, mostra uma roda de carregamento.
  bool _isLoading = false;
  
  // Linha 31: Controla se a senha está visível ou escondida.
  // true = senha escondida (mostra ●●●●●●)
  // false = senha visível (mostra o texto)
  bool _obscurePassword = true;
  
  // Linha 32: Controla se a confirmação de senha está visível ou escondida.
  bool _obscureConfirmPassword = true;

  // ============================================================
  // 🧹 DISPOSE — "LIMPA A MESA" QUANDO SAI
  // ============================================================
  // Linhas 35-40: Quando a tela é fechada, limpamos os controladores
  // Isso libera memória do celular.
  @override
  void dispose() {
    _emailController.dispose(); // Libera a memória do e-mail
    _passwordController.dispose(); // Libera a memória da senha
    _confirmPasswordController.dispose(); // Libera a memória da confirmação
    super.dispose(); // Chama o dispose da classe pai
  }

  // ============================================================
  // 📝 _REGISTER — A "FUNÇÃO QUE CRIA A CONTA"
  // ============================================================
  // Linha 43: Função que vai criar a conta do usuário.
  // É chamada quando o usuário clica em "Cadastrar".
  // Future = pode demorar (porque vai na internet)
  // async = pode esperar (porque vai no Firebase)
  Future<void> _register() async {
    // Linha 44: Verifica se o formulário está todo preenchido corretamente.
    // Se algum campo estiver errado, mostra o erro e para aqui.
    if (!_formKey.currentState!.validate()) return;

    // Linha 47: Muda o estado para "carregando".
    // Isso mostra a roda de carregamento no botão.
    setState(() => _isLoading = true);

    // Linha 50: Tenta criar a conta no Firebase.
    // O try tenta fazer algo que pode dar erro.
    try {
      // Linha 51-54: Chama o serviço de autenticação para registrar o usuário.
      // Pega o e-mail e a senha que o usuário digitou.
      // .trim() remove espaços em branco no início e no fim.
      await _authService.register(
        _emailController.text.trim(), // Pega o e-mail do controlador
        _passwordController.text.trim(), // Pega a senha do controlador
      );
      
      // Linha 56: Verifica se a tela ainda está montada.
      // Isso evita erros se o usuário fechou a tela enquanto carregava.
      if (!mounted) return;

      // Linha 59-65: Mostra uma mensagem de sucesso (SnackBar).
      // É aquele "toast" que aparece na parte de baixo da tela.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Conta criada com sucesso! Faça login.'),
          backgroundColor: BoxStockColors.sucesso, // Cor verde = sucesso
          duration: Duration(seconds: 3), // Fica 3 segundos na tela
        ),
      );
      
      // Linha 67: Volta para a tela anterior (tela de login).
      // O usuário já criou a conta, agora pode fazer login.
      Navigator.pop(context);
    } catch (e) {
      // Linha 69: Se deu erro, entra aqui.
      // Exemplo: e-mail já cadastrado, senha muito fraca, etc.
      // Mostra um diálogo com a mensagem de erro.
      _showErrorDialog(e.toString());
    } finally {
      // Linha 72-74: Isso acontece SEMPRE, mesmo se der erro.
      // Desativa o "carregando" e volta o botão ao normal.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // ❌ _SHOWERRORDIALOG — "MOSTRA O ERRO"
  // ============================================================
  // Linha 78: Função que mostra um diálogo de erro.
  // Recebe uma mensagem e exibe numa janelinha.
  void _showErrorDialog(String message) {
    // Linha 79: Mostra um diálogo (pop-up) com a mensagem de erro.
    showDialog(
      context: context, // O contexto da tela
      builder: (_) => AlertDialog( // Constrói o diálogo
        title: Row( // Linha 83: Título com ícone
          children: const [
            Icon(Icons.error_outline, color: BoxStockColors.alerta), // Ícone vermelho
            SizedBox(width: 8), // Espaço entre o ícone e o texto
            Text('Erro'), // Texto do título
          ],
        ),
        content: Text(message), // Linha 90: A mensagem de erro que veio
        shape: RoundedRectangleBorder( // Linha 91: Borda arredondada
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [ // Linha 94: Botão para fechar
          TextButton(
            onPressed: () => Navigator.pop(context), // Fecha o diálogo
            style: TextButton.styleFrom(
              foregroundColor: BoxStockColors.papelaoMedio,
            ),
            child: const Text('OK'), // Texto do botão
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI A TELA"
  // ============================================================
  // Linha 106: A função que constrói toda a tela.
  // É chamada sempre que a tela precisa ser redesenhada.
  @override
  Widget build(BuildContext context) {
    // Linha 107: Retorna um Scaffold (a estrutura básica da tela)
    return Scaffold(
      // Linha 108: Define a cor de fundo da tela.
      backgroundColor: BoxStockColors.fundoPrincipal,

      // ============================================================
      // 📱 APPBAR — A "BARRA SUPERIOR"
      // ============================================================
      // Linhas 113-130: A barra que fica no topo da tela.
      appBar: AppBar(
        title: const Text( // Linha 114: Título da barra
          'Criar Conta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: BoxStockColors.papelaoMedio, // Cor marrom/laranja
        foregroundColor: Colors.white, // Cor do texto e ícones
        elevation: 0, // Sem sombra
        centerTitle: true, // Título centralizado
        
        // Linhas 122-129: A "fita adesiva" decorativa abaixo da barra
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

      // ============================================================
      // 📄 BODY — O "CORPO" DA TELA
      // ============================================================
      // Linhas 133-164: O conteúdo principal da tela.
      body: SafeArea( // Evita que o conteúdo fique atrás da barra de status
        child: Center( // Centraliza o conteúdo
          child: SingleChildScrollView( // Permite rolar a tela se precisar
            padding: const EdgeInsets.all(24.0), // Espaço nas bordas
            child: Form( // O formulário que valida os campos
              key: _formKey, // A chave que valida tudo
              child: Column( // Organiza os widgets em coluna
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 🖼️ LOGO
                  // Linha 144: Constrói a logo
                  _buildLogo(),
                  const SizedBox(height: 16), // Espaço entre a logo e o próximo elemento

                  // 📝 NOME DO APP
                  // Linha 148: Constrói o nome "BoxStock"
                  _buildAppName(),
                  const SizedBox(height: 32), // Espaço entre o nome e os campos

                  // 📧 CAMPO E-MAIL
                  // Linha 152: Constrói o campo de e-mail
                  _buildEmailField(),
                  const SizedBox(height: 16), // Espaço entre os campos

                  // 🔒 CAMPO SENHA
                  // Linha 156: Constrói o campo de senha
                  _buildPasswordField(),
                  const SizedBox(height: 16), // Espaço entre os campos

                  // 🔒 CAMPO CONFIRMAR SENHA
                  // Linha 160: Constrói o campo de confirmação
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 24), // Espaço antes do botão

                  // 🔘 BOTÃO CADASTRAR
                  // Linha 164: Constrói o botão de cadastrar
                  _buildRegisterButton(),
                  const SizedBox(height: 16), // Espaço antes do link

                  // 🔗 LINK LOGIN
                  // Linha 168: Constrói o link para a tela de login
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🖼️ _BUILDLOGO — "CONSTRÓI A LOGO"
  // ============================================================
  // Linha 174: Função que constrói a logo do BoxStock
  Widget _buildLogo() {
    // Linha 175: Retorna uma imagem que está na pasta assets
    return Image.asset(
      'assets/images/Logo.png', // Caminho da imagem
      width: 100, // Largura da imagem
      height: 100, // Altura da imagem
      fit: BoxFit.contain, // Ajusta a imagem sem cortar
    );
  }

  // ============================================================
  // 📝 _BUILDAPPNAME — "CONSTRÓI O NOME DO APP"
  // ============================================================
  // Linha 184: Função que constrói o nome "BoxStock" e o subtítulo
  Widget _buildAppName() {
    // Linha 185: Retorna uma coluna com o nome e o subtítulo
    return Column(
      children: [
        Text( // Linha 187: O nome do app
          'BoxStock',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: BoxStockColors.textoPrincipal,
            letterSpacing: 0.5, // Espaço entre as letras
          ),
        ),
        const SizedBox(height: 4), // Espaço entre o nome e o subtítulo
        Container( // Linha 196: O subtítulo com fundo
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: BoxStockColors.fundoSecundario,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: BoxStockColors.papelaoClaro.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Text( // Linha 206: O texto do subtítulo
            'Crie sua conta gratuita',
            style: TextStyle(
              fontSize: 13,
              color: BoxStockColors.textoPrincipal.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 📧 _BUILDEMAILFIELD — "CONSTRÓI O CAMPO DE E-MAIL"
  // ============================================================
  // Linha 216: Função que constrói o campo de e-mail
  Widget _buildEmailField() {
    // Linha 217: Retorna um container com o campo de texto
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
      child: TextFormField( // Linha 232: O campo de texto com validação
        controller: _emailController, // O controlador que guarda o texto
        keyboardType: TextInputType.emailAddress, // Teclado com @
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: const InputDecoration( // Linha 236: Decoração do campo
          labelText: 'E-mail', // O texto que fica em cima
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon( // Ícone na esquerda
            Icons.email_outlined,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none, // Sem borda (já tem no container)
          contentPadding: EdgeInsets.all(16), // Espaço interno
          hintText: 'exemplo@email.com', // Texto de exemplo
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w400,
          ),
        ),
        validator: (value) { // Linha 257: Função que valida o e-mail
          if (value == null || value.isEmpty) {
            return 'Digite seu e-mail'; // Se estiver vazio
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Digite um e-mail válido'; // Se não tiver @ ou .com
          }
          return null; // Se estiver tudo certo, retorna null (sem erro)
        },
      ),
    );
  }

  // ============================================================
  // 🔒 _BUILDPASSWORDFIELD — "CONSTRÓI O CAMPO DE SENHA"
  // ============================================================
  // Linha 271: Função que constrói o campo de senha
  Widget _buildPasswordField() {
    // Linha 272: Retorna um container com o campo de texto
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
      child: TextFormField( // Linha 287: Campo de texto com validação
        controller: _passwordController, // O controlador que guarda a senha
        obscureText: _obscurePassword, // Esconde a senha (mostra ●)
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: InputDecoration( // Linha 291: Decoração do campo
          labelText: 'Senha',
          labelStyle: const TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon( // Ícone de cadeado
            Icons.lock_outline,
            color: BoxStockColors.papelaoMedio,
          ),
          suffixIcon: IconButton( // Linha 300: Botão para mostrar/esconder a senha
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: BoxStockColors.papelaoMedio,
            ),
            onPressed: () { // Linha 305: Quando clica no botão
              setState(() { // Muda o estado da tela
                _obscurePassword = !_obscurePassword; // Inverte o valor
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: 'Mínimo 6 caracteres',
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.4),
            fontWeight: FontWeight.w400,
          ),
        ),
        validator: (value) { // Linha 320: Valida a senha
          if (value == null || value.isEmpty) {
            return 'Digite sua senha'; // Se estiver vazio
          }
          if (value.length < 6) {
            return 'A senha deve ter no mínimo 6 caracteres'; // Se for muito curta
          }
          return null; // Se estiver tudo certo
        },
      ),
    );
  }

  // ============================================================
  // 🔒 _BUILDCONFIRMPASSWORDFIELD — "CONSTRÓI O CAMPO DE CONFIRMAÇÃO"
  // ============================================================
  // Linha 334: Função que constrói o campo de confirmação de senha
  Widget _buildConfirmPasswordField() {
    // Linha 335: Retorna um container com o campo de texto
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
      child: TextFormField( // Linha 350: Campo de texto com validação
        controller: _confirmPasswordController, // Controlador da confirmação
        obscureText: _obscureConfirmPassword, // Esconde a senha
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: InputDecoration( // Linha 354: Decoração do campo
          labelText: 'Confirmar Senha',
          labelStyle: const TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: BoxStockColors.papelaoMedio,
          ),
          suffixIcon: IconButton( // Linha 363: Botão para mostrar/esconder
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
              color: BoxStockColors.papelaoMedio,
            ),
            onPressed: () { // Linha 368: Quando clica no botão
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          hintText: 'Digite a senha novamente',
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.4),
            fontWeight: FontWeight.w400,
          ),
        ),
        validator: (value) { // Linha 383: Valida a confirmação
          if (value == null || value.isEmpty) {
            return 'Confirme sua senha'; // Se estiver vazio
          }
          if (value != _passwordController.text) {
            return 'As senhas não coincidem'; // Se as senhas são diferentes
          }
          return null; // Se estiver tudo certo
        },
      ),
    );
  }

  // ============================================================
  // 🔘 _BUILDREGISTERBUTTON — "CONSTRÓI O BOTÃO CADASTRAR"
  // ============================================================
  // Linha 397: Função que constrói o botão "Cadastrar"
  Widget _buildRegisterButton() {
    // Linha 398: Retorna um botão que ocupa toda a largura
    return SizedBox(
      width: double.infinity, // Ocupa toda a largura
      height: 50, // Altura do botão
      child: ElevatedButton( // Linha 401: Botão elevado (com sombra)
        onPressed: _isLoading ? null : _register, // Se estiver carregando, desativa
        style: ElevatedButton.styleFrom( // Linha 403: Estilo do botão
          backgroundColor: BoxStockColors.papelaoMedio,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4, // Sombra
          shadowColor: BoxStockColors.papelaoMedio.withOpacity(0.3),
        ),
        child: _isLoading // Linha 413: Se estiver carregando
            ? const SizedBox( // Mostra uma roda de carregamento
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text( // Senão, mostra o texto "Cadastrar"
                'Cadastrar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }

  // ============================================================
  // 🔗 _BUILDLOGINLINK — "CONSTRÓI O LINK PARA LOGIN"
  // ============================================================
  // Linha 432: Função que constrói o link "Já tem uma conta? Faça login"
  Widget _buildLoginLink() {
    // Linha 433: Retorna uma linha com texto e botão
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centraliza
      children: [
        Text( // Linha 436: Texto "Já tem uma conta?"
          'Já tem uma conta? ',
          style: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        TextButton( // Linha 442: Botão "Faça login"
          onPressed: () => Navigator.pop(context), // Volta para a tela anterior
          style: TextButton.styleFrom(
            foregroundColor: BoxStockColors.papelaoMedio,
            padding: EdgeInsets.zero, // Remove o padding
            minimumSize: const Size(0, 0), // Tamanho mínimo zero
            tapTargetSize: MaterialTapTargetSize.shrinkWrap, // Tamanho pequeno
          ),
          child: const Text( // Linha 451: Texto do botão
            'Faça login',
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
}