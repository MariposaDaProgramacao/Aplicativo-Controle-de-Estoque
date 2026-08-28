// ============================================================
// 📁 login_screen.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está na "PORTARIA" de um prédio.
//              O usuário precisa mostrar sua IDENTIDADE (e-mail e senha)
//              para entrar. Essa tela é a "PORTARIA" onde o usuário
//              faz o login para entrar no sistema.
// 
// 🏠 Ele é como a "ENTRADA PRINCIPAL" do app:
//    - O usuário digita e-mail e senha
//    - O sistema verifica se os dados estão certos
//    - Se estiver certo, o usuário entra no sistema
//    - Se não, mostra uma mensagem de erro
//    - Tem "Lembrar-me" para não digitar toda vez
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir telas (botões, textos, etc.)
import 'package:flutter/material.dart';
// Linha 2: Importa o Firebase Auth para autenticação
import 'package:firebase_auth/firebase_auth.dart';
// Linha 3: Importa o serviço de autenticação que criamos
import '../../services/auth_service.dart';
// Linha 4: Importa as cores do sistema (BoxStockColors)
import '../../main.dart';
// Linha 5: Importa a tela de cadastro (para navegar até ela)
import 'cadastro_screen.dart';
// Linha 6: Importa a tela principal (Home) para onde vai depois do login
import '../main/home_screen.dart';

// ============================================================
// 🏠 CLASSE LOGINSCREEN — A "TELA DE LOGIN"
// ============================================================
// Linha 9: Define a classe LoginScreen
// StatefulWidget = a tela pode mudar (ex: mostrar carregando)
class LoginScreen extends StatefulWidget {
  // Linha 10: Construtor com chave opcional
  const LoginScreen({super.key});

  // Linha 12-14: Cria o estado da tela (a "memória" da tela)
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ============================================================
// 🧠 _LOGINSCREENSTATE — A "MEMÓRIA" DA TELA DE LOGIN
// ============================================================
// Linha 18: Classe que guarda o estado da tela
class _LoginScreenState extends State<LoginScreen> {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" da tela
  // ============================================================
  
  // Linha 21: Chave do formulário. Valida todos os campos juntos.
  // Exemplo: Quando clica em "Entrar", verifica se e-mail e senha estão certos.
  final _formKey = GlobalKey<FormState>();
  
  // Linha 23: Controlador do e-mail. Guarda o que o usuário digita.
  final _emailController = TextEditingController();
  
  // Linha 24: Controlador da senha. Guarda o que o usuário digita.
  final _passwordController = TextEditingController();
  
  // Linha 26: Instância do serviço de autenticação.
  // É o "ajudante" que vai fazer o login no Firebase.
  final _authService = AuthService();
  
  // Linha 27: Controla se está carregando.
  // true = mostra roda de carregamento no botão.
  bool _isLoading = false;
  
  // Linha 28: Controla se a senha está visível.
  // true = senha escondida (mostra ●●●)
  // false = senha visível (mostra o texto)
  bool _obscurePassword = true;
  
  // Linha 29: Controla se o "Lembrar-me" está marcado.
  // true = salva as credenciais para o próximo login.
  bool _lembrarMe = false;

  // ============================================================
  // 🚀 INITSTATE — "O QUE ACONTECE QUANDO A TELA ABRE"
  // ============================================================
  // Linhas 32-35: Função chamada quando a tela é aberta.
  // É como a "RECEPCIONISTA" que já prepara as coisas antes
  // do usuário chegar.
  @override
  void initState() {
    super.initState(); // Chama o initState da classe pai
    _verificarLembrarMe(); // Verifica se o usuário marcou "Lembrar-me" antes
  }

  // ============================================================
  // 🔍 _VERIFICARLEMBRARME — "VERIFICA SE O USUÁRIO QUER SER LEMBRADO"
  // ============================================================
  // Linhas 37-42: Função que verifica se o usuário já marcou "Lembrar-me"
  // antes. Se sim, já deixa o checkbox marcado.
  Future<void> _verificarLembrarMe() async {
    final lembrar = await _authService.deveLembrar(); // Pergunta ao AuthService
    setState(() { // Muda o estado da tela
      _lembrarMe = lembrar; // Marca o checkbox se o usuário quiser ser lembrado
    });
  }

  // ============================================================
  // 🧹 DISPOSE — "LIMPA A MESA" QUANDO SAI
  // ============================================================
  // Linhas 44-48: Quando a tela é fechada, limpamos os controladores.
  // Isso libera memória do celular.
  @override
  void dispose() {
    _emailController.dispose(); // Libera a memória do e-mail
    _passwordController.dispose(); // Libera a memória da senha
    super.dispose(); // Chama o dispose da classe pai
  }

  // ============================================================
  // 🔑 _LOGIN — "A FUNÇÃO QUE FAZ O LOGIN"
  // ============================================================
  // Linha 51: Função que faz o login. É chamada quando o usuário
  // clica no botão "Entrar".
  // Future = pode demorar (vai na internet)
  // async = pode esperar
  Future<void> _login() async {
    // Linha 52: Valida o formulário. Se algo estiver errado, para aqui.
    if (!_formKey.currentState!.validate()) return;

    // Linha 54: Mostra o "carregando..." (roda de carregamento)
    setState(() => _isLoading = true);

    // Linha 57: Tenta fazer o login no Firebase.
    // O try tenta fazer algo que pode dar erro.
    try {
      // Linha 58-62: Chama o serviço de autenticação para fazer login.
      // Pega o e-mail e a senha que o usuário digitou.
      // .trim() remove espaços em branco.
      // lembrarMe: _lembrarMe = se o checkbox está marcado, salva as credenciais.
      await _authService.login(
        _emailController.text.trim(), // Pega o e-mail digitado
        _passwordController.text.trim(), // Pega a senha digitada
        lembrarMe: _lembrarMe, // Passa se deve lembrar ou não
      );
      
      // Linha 64: Verifica se a tela ainda está aberta.
      // Se o usuário fechou a tela enquanto carregava, não faz nada.
      if (!mounted) return;
      
      // Linha 65-68: Vai para a tela principal (HomeScreen).
      // pushReplacement = substitui a tela atual pela Home (não dá para voltar)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      // Linha 70: Se deu erro (ex: senha errada), mostra o erro.
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
        content: Text(message), // Linha 90: A mensagem de erro
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
  // ℹ️ _MOSTRARSOBRE — "MOSTRA AS INFORMAÇÕES DO PROJETO"
  // ============================================================
  // Linha 103: Função que mostra o diálogo "Sobre o BoxStock".
  // É chamada quando o usuário clica no botão "Sobre o BoxStock".
  void _mostrarSobre() {
    // Linha 104: Mostra um diálogo (pop-up) com as informações.
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Column( // Linha 108: Título com logo e nome
          children: [
            // Logo pequena
            Image.asset( // Linha 111: Carrega a logo
              'assets/images/Logo.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8), // Espaço entre a logo e o texto
            const Text( // Linha 119: Nome do app no título
              '📦 BoxStock',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: BoxStockColors.textoPrincipal,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView( // Linha 128: Permite rolar se tiver muito texto
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
            mainAxisSize: MainAxisSize.min, // Ocupa só o espaço necessário
            children: [
              const Divider(color: BoxStockColors.papelaoClaro), // Linha separadora
              const SizedBox(height: 8), // Espaço
              
              // Tecnologias
              const Text( // Linha 140: Título "Tecnologias utilizadas"
                '🛠️ Tecnologias utilizadas:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BoxStockColors.textoPrincipal,
                ),
              ),
              const SizedBox(height: 8),
              // Linhas 148-152: Cada tecnologia com seu ícone e descrição
              _buildTechItem('🎯 Flutter', 'Framework para desenvolvimento mobile'),
              _buildTechItem('📱 Dart', 'Linguagem de programação'),
              _buildTechItem('🔥 Firebase', 'Backend em nuvem'),
              _buildTechItem('🔐 Firebase Auth', 'Autenticação de usuários'),
              _buildTechItem('📊 Cloud Firestore', 'Banco de dados em tempo real'),
              
              const SizedBox(height: 12),
              const Divider(color: BoxStockColors.papelaoClaro), // Linha separadora
              const SizedBox(height: 8),
              
              // Sobre o desenvolvedor
              const Text( // Linha 164: Título "Desenvolvido por"
                '👩‍💻 Desenvolvido por:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: BoxStockColors.textoPrincipal,
                ),
              ),
              const SizedBox(height: 4),
              Text( // Linha 172: Nome do desenvolvedor
                'Shanaya Nataly',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: BoxStockColors.textoPrincipal,
                ),
              ),
              const SizedBox(height: 4),
              Text( // Linha 181: Curso
                '📚 Curso Técnico em Desenvolvimento de Sistemas',
                style: TextStyle(
                  fontSize: 12,
                  color: BoxStockColors.textoPrincipal.withOpacity(0.6),
                ),
              ),
              
              const SizedBox(height: 12),
              const Divider(color: BoxStockColors.papelaoClaro), // Linha separadora
              const SizedBox(height: 8),
              
              // Versão
              Row( // Linha 195: Informação da versão
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.4),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Versão 1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: BoxStockColors.textoPrincipal.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        shape: RoundedRectangleBorder( // Borda arredondada
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [ // Linha 217: Botão para fechar
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: BoxStockColors.papelaoMedio,
            ),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🛠️ _BUILDTECHITEM — "CONSTRÓI UM ITEM DE TECNOLOGIA"
  // ============================================================
  // Linha 228: Função que constrói cada item da lista de tecnologias.
  // Recebe o título (ex: "Flutter") e a descrição (ex: "Framework...").
  Widget _buildTechItem(String titulo, String descricao) {
    // Linha 229: Retorna um Padding com espaçamento.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row( // Linha 232: Uma linha com o título e a descrição
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text( // Linha 236: O título (ex: "🎯 Flutter")
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: BoxStockColors.textoPrincipal,
            ),
          ),
          const SizedBox(width: 8), // Espaço entre o título e a descrição
          Expanded( // Linha 245: A descrição ocupa o resto do espaço
            child: Text(
              '— $descricao',
              style: TextStyle(
                fontSize: 12,
                color: BoxStockColors.textoPrincipal.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI A TELA DE LOGIN"
  // ============================================================
  // Linha 258: A função que constrói toda a tela de login.
  @override
  Widget build(BuildContext context) {
    // Linha 259: Retorna um Scaffold (a estrutura básica da tela)
    return Scaffold(
      // Linha 260: Define a cor de fundo da tela.
      backgroundColor: BoxStockColors.fundoPrincipal,
      
      // Linha 261: SafeArea = não deixa o conteúdo ficar atrás da barra de status
      body: SafeArea(
        child: Center( // Linha 263: Centraliza o conteúdo
          child: SingleChildScrollView( // Linha 264: Permite rolar a tela
            padding: const EdgeInsets.symmetric(horizontal: 32.0), // Espaço nas laterais
            child: Column( // Linha 266: Organiza os widgets em coluna
              mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente
              children: [
                // ============================================================
                // 🖼️ LOGO
                // ============================================================
                // Linha 272: Constrói a logo
                _buildLogo(),
                const SizedBox(height: 16), // Espaço

                // ============================================================
                // 📝 NOME DO APP
                // ============================================================
                // Linha 276: Constrói o nome "BoxStock"
                _buildAppName(),
                const SizedBox(height: 40), // Espaço

                // ============================================================
                // 📄 FORMULÁRIO
                // ============================================================
                // Linha 280: O formulário que valida os campos
                Form(
                  key: _formKey, // A chave que valida tudo
                  child: Column( // Linha 282: Os campos em coluna
                    children: [
                      // Linha 284: Campo de e-mail
                      _buildEmailField(),
                      const SizedBox(height: 16), // Espaço
                      
                      // Linha 287: Campo de senha
                      _buildPasswordField(),
                      const SizedBox(height: 12), // Espaço
                      
                      // Linha 290: Opções (Lembrar-me)
                      _buildOptionsRow(),
                      const SizedBox(height: 24), // Espaço
                      
                      // Linha 293: Botão "Entrar"
                      _buildLoginButton(),
                      const SizedBox(height: 16), // Espaço
                      
                      // Linha 296: Link para cadastro
                      _buildRegisterLink(),
                    ],
                  ),
                ),

                const SizedBox(height: 32), // Espaço

                // ============================================================
                // 🎯 BENEFÍCIOS
                // ============================================================
                // Linha 302: Os 3 benefícios (Seguro, Prático, Completo)
                _buildBenefits(),

                const SizedBox(height: 16), // Espaço

                // ============================================================
                // ℹ️ BOTÃO SOBRE
                // ============================================================
                // Linha 308: Botão "Sobre o BoxStock"
                _buildSobreButton(),

                const SizedBox(height: 20), // Espaço extra no final
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🖼️ _BUILDLOGO — "CONSTRÓI A LOGO"
  // ============================================================
  // Linha 318: Função que constrói a logo.
  Widget _buildLogo() {
    // Linha 319: Retorna a imagem da logo.
    return Image.asset(
      'assets/images/Logo.png',
      width: 120,
      height: 120,
      fit: BoxFit.contain,
    );
  }

  // ============================================================
  // 📝 _BUILDAPPNAME — "CONSTRÓI O NOME DO APP"
  // ============================================================
  // Linha 328: Função que constrói o nome do app e o slogan.
  Widget _buildAppName() {
    // Linha 329: Retorna uma coluna com o nome e o slogan.
    return Column(
      children: [
        Text( // Linha 331: O nome "BoxStock"
          'BoxStock',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: BoxStockColors.textoPrincipal,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4), // Espaço
        Text( // Linha 341: O slogan
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

  // ============================================================
  // 📧 _BUILDEMAILFIELD — "CONSTRÓI O CAMPO DE E-MAIL"
  // ============================================================
  // Linha 352: Função que constrói o campo de e-mail.
  Widget _buildEmailField() {
    // Linha 353: Retorna um container com o campo de texto.
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
      child: TextFormField( // Linha 368: Campo de texto com validação
        controller: _emailController, // O controlador que guarda o e-mail
        keyboardType: TextInputType.emailAddress, // Teclado com @
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: const InputDecoration( // Linha 372: Decoração do campo
          labelText: 'E-mail',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon( // Ícone de e-mail
            Icons.email_outlined,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none, // Sem borda (já tem no container)
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) { // Linha 388: Valida o e-mail
          if (value == null || value.isEmpty) {
            return 'Digite seu e-mail'; // Se estiver vazio
          }
          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
            return 'Digite um e-mail válido'; // Se não tiver @ ou .com
          }
          return null; // Se estiver tudo certo
        },
      ),
    );
  }

  // ============================================================
  // 🔒 _BUILDPASSWORDFIELD — "CONSTRÓI O CAMPO DE SENHA"
  // ============================================================
  // Linha 402: Função que constrói o campo de senha.
  Widget _buildPasswordField() {
    // Linha 403: Retorna um container com o campo de texto.
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
      child: TextFormField( // Linha 418: Campo de texto com validação
        controller: _passwordController, // O controlador da senha
        obscureText: _obscurePassword, // Esconde a senha
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: InputDecoration( // Linha 422: Decoração do campo
          labelText: 'Senha',
          labelStyle: const TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: const Icon( // Ícone de cadeado
            Icons.lock_outline,
            color: BoxStockColors.papelaoMedio,
          ),
          suffixIcon: IconButton( // Linha 431: Botão para mostrar/esconder
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: BoxStockColors.papelaoMedio,
            ),
            onPressed: () { // Linha 436: Quando clica no botão
              setState(() {
                _obscurePassword = !_obscurePassword; // Inverte o valor
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (value) { // Linha 445: Valida a senha
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
  // ✅ _BUILDOPTIONSROW — "CONSTRÓI A LINHA DE OPÇÕES"
  // ============================================================
  // Linha 459: Função que constrói a linha com o checkbox "Lembrar-me".
  Widget _buildOptionsRow() {
    // Linha 460: Retorna uma linha com o checkbox.
    return Row(
      mainAxisAlignment: MainAxisAlignment.start, // Alinha à esquerda
      children: [
        Row( // Linha 463: O checkbox e o texto
          children: [
            SizedBox( // Linha 465: O checkbox
              width: 20,
              height: 20,
              child: Checkbox(
                value: _lembrarMe, // Se está marcado ou não
                onChanged: (value) { // Linha 469: Quando clica no checkbox
                  setState(() {
                    _lembrarMe = value ?? false; // Atualiza o valor
                  });
                },
                activeColor: BoxStockColors.papelaoMedio, // Cor quando marcado
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8), // Espaço entre o checkbox e o texto
            Text( // Linha 480: O texto "Lembrar-me"
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

  // ============================================================
  // 🔘 _BUILDLOGINBUTTON — "CONSTRÓI O BOTÃO ENTRAR"
  // ============================================================
  // Linha 493: Função que constrói o botão "Entrar".
  Widget _buildLoginButton() {
    // Linha 494: Retorna um botão que ocupa toda a largura.
    return SizedBox(
      width: double.infinity, // Ocupa toda a largura
      height: 50, // Altura do botão
      child: ElevatedButton( // Linha 497: Botão elevado (com sombra)
        onPressed: _isLoading ? null : _login, // Se carregando, desativa
        style: ElevatedButton.styleFrom( // Linha 499: Estilo do botão
          backgroundColor: BoxStockColors.papelaoMedio,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4, // Sombra
          shadowColor: BoxStockColors.papelaoMedio.withOpacity(0.3),
        ),
        child: _isLoading // Linha 509: Se estiver carregando
            ? const SizedBox( // Mostra a roda de carregamento
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text( // Senão, mostra "Entrar"
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

  // ============================================================
  // 🔗 _BUILDREGISTERLINK — "CONSTRÓI O LINK PARA CADASTRO"
  // ============================================================
  // Linha 528: Função que constrói o link "Não tem uma conta? Cadastre-se".
  Widget _buildRegisterLink() {
    // Linha 529: Retorna uma linha com texto e botão.
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Centraliza
      children: [
        Text( // Linha 532: Texto "Não tem uma conta?"
          'Não tem uma conta? ',
          style: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
        TextButton( // Linha 538: Botão "Cadastre-se →"
          onPressed: () { // Linha 539: Quando clica, vai para a tela de cadastro
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
          child: const Text( // Linha 552: Texto do botão
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

  // ============================================================
  // 🎯 _BUILDBENEFITS — "CONSTRÓI OS BENEFÍCIOS"
  // ============================================================
  // Linha 563: Função que constrói os 3 benefícios.
  Widget _buildBenefits() {
    // Linha 564: Retorna um container com os benefícios.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: BoxStockColors.fundoSecundario.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row( // Linha 571: Organiza os benefícios em linha
        mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribui igualmente
        children: [
          // Linha 574: Benefício "Seguro"
          _buildBenefitItem(
            icon: Icons.shield_outlined,
            label: 'Seguro',
            subtitle: 'Seus dados protegidos',
          ),
          // Linha 579: Benefício "Prático"
          _buildBenefitItem(
            icon: Icons.speed_outlined,
            label: 'Prático',
            subtitle: 'Gestão rápida',
          ),
          // Linha 584: Benefício "Completo"
          _buildBenefitItem(
            icon: Icons.auto_awesome_outlined,
            label: 'Completo',
            subtitle: 'Tudo que precisa',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🎯 _BUILDBENEFITITEM — "CONSTRÓI UM BENEFÍCIO"
  // ============================================================
  // Linha 593: Função que constrói cada benefício individual.
  Widget _buildBenefitItem({
    required IconData icon, // O ícone (ex: Icons.shield_outlined)
    required String label, // O título (ex: "Seguro")
    required String subtitle, // O subtítulo (ex: "Seus dados protegidos")
  }) {
    // Linha 598: Retorna uma coluna com ícone, título e subtítulo.
    return Column(
      children: [
        Container( // Linha 600: O círculo com o ícone
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: BoxStockColors.papelaoMedio.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon( // Linha 607: O ícone
            icon,
            size: 22,
            color: BoxStockColors.papelaoMedio,
          ),
        ),
        const SizedBox(height: 4), // Espaço
        Text( // Linha 614: O título
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: BoxStockColors.textoPrincipal,
          ),
        ),
        Text( // Linha 622: O subtítulo
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: BoxStockColors.textoPrincipal.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ℹ️ _BUILDSOBREBUTTON — "CONSTRÓI O BOTÃO SOBRE"
  // ============================================================
  // Linha 633: Função que constrói o botão "Sobre o BoxStock".
  Widget _buildSobreButton() {
    // Linha 634: Retorna um botão centralizado.
    return Center(
      child: TextButton.icon( // Linha 635: Botão com ícone e texto
        onPressed: _mostrarSobre, // Quando clica, mostra o diálogo "Sobre"
        icon: Icon( // Linha 637: O ícone de informação
          Icons.info_outline,
          size: 18,
          color: BoxStockColors.papelaoMedio.withOpacity(0.6),
        ),
        label: Text( // Linha 643: O texto "Sobre o BoxStock"
          'Sobre o BoxStock',
          style: TextStyle(
            fontSize: 13,
            color: BoxStockColors.papelaoMedio.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        style: TextButton.styleFrom( // Linha 651: Estilo do botão
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: BoxStockColors.papelaoMedio.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
      ),
    );
  }
}