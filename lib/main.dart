// ============================================================
// 📁 main.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está entrando em um "SHOPPING CENTER".
//              Esse arquivo é a "PORTA DE ENTRADA" do BoxStock!
//              É aqui que tudo começa: o app é iniciado, as cores
//              são definidas e o usuário é levado para a tela certa.
// 
// 🏠 Ele é como a "RECEPÇÃO" do sistema:
//    - Inicializa o Firebase (liga o sistema)
//    - Define as cores (decora a recepção)
//    - Verifica se o usuário está logado (quem está na recepção?)
//    - Mostra a tela certa (Login ou Home)
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir o app
import 'package:flutter/material.dart';
// Linha 2: Importa o Firebase Core para inicializar o Firebase
import 'package:firebase_core/firebase_core.dart';
// Linha 3: Importa o Firebase Auth para autenticação
import 'package:firebase_auth/firebase_auth.dart';
// Linha 4: Importa a tela de Login
import 'screens/auth/login_screen.dart';
// Linha 5: Importa a tela principal (Home)
import 'screens/main/home_screen.dart';
// Linha 6: Importa o serviço de autenticação
import 'services/auth_service.dart';
// Linha 7: Importa as opções do Firebase (gerado automaticamente)
import 'firebase_options.dart';

// ============================================================
// 🎨 PALETA DE CORES DO BOXSTOCK — A "DECORAÇÃO" DO SISTEMA
// ============================================================
// Linha 11: Define a classe BoxStockColors
// 
// 🔍 Analogia: É como a "PALETA DE TINTAS" que usamos para
//              pintar todas as telas do BoxStock.
// 
// Todos os valores são "static" (podem ser usados em qualquer lugar)
// e "const" (não mudam nunca).
class BoxStockColors {
  // ============================================================
  // 🏠 FUNDOS — As "CORES DE PAREDE"
  // ============================================================
  
  // Linha 15: Cor de fundo principal (creme claro)
  // Usada na maioria das telas como cor de fundo.
  static const Color fundoPrincipal = Color(0xFFFFF1D6);
  
  // Linha 16: Cor de fundo secundária (bege dourado)
  // Usada em cards, cabeçalhos e elementos de destaque.
  static const Color fundoSecundario = Color(0xFFFFE0A3);
  
  // ============================================================
  // 📦 PAPELÃO — As "CORES DA CAIXA"
  // ============================================================
  
  // Linha 19: Papelão claro (caramelo)
  // Usado para elementos suaves e detalhes.
  static const Color papelaoClaro = Color(0xFFE9A64A);
  
  // Linha 20: Papelão médio (laranja queimado)
  // Usado em botões principais e AppBar.
  static const Color papelaoMedio = Color(0xFFC97825);
  
  // Linha 21: Papelão escuro (marrom)
  // Usado em textos e ícones importantes.
  static const Color papelaoEscuro = Color(0xFF70451F);
  
  // ============================================================
  // 📝 CAMPOS E TEXTO — As "CORES DE ESCRITA"
  // ============================================================
  
  // Linha 24: Cor de fundo dos campos de texto (creme)
  static const Color campos = Color(0xFFFFF8EA);
  
  // Linha 25: Cor principal dos textos (marrom quase preto)
  static const Color textoPrincipal = Color(0xFF3B2A1F);
  
  // ============================================================
  // 🎯 AÇÕES E STATUS — As "CORES DOS SEMÁFOROS"
  // ============================================================
  
  // Linha 28: Verde = sucesso (ex: "Entrada", "Disponível")
  static const Color sucesso = Color(0xFF4CAF50);
  
  // Linha 29: Azul = informação (ex: "Total Produtos")
  static const Color informacao = Color(0xFF3F6FA8);
  
  // Linha 30: Laranja = ação principal (ex: "Salvar", "Compartilhar")
  static const Color acaoPrincipal = Color(0xFFF28C18);
  
  // Linha 31: Vermelho = alerta (ex: "Erro", "Sem Estoque")
  static const Color alerta = Color(0xFFE45745);
  
  // Linha 32: Roxo = recursos secundários (ex: "Categorias")
  static const Color recursoSecundario = Color(0xFF8064A2);
}

// ============================================================
// 🚀 MAIN — A "PORTA DE ENTRADA" DO APP
// ============================================================
// Linha 38: A função main() é onde tudo começa.
// 
// 🔍 Analogia: É como "ABRIR A PORTA" do BoxStock.
// 
// async = pode esperar (inicialização do Firebase)
void main() async {
  // Linha 39: Garante que os bindings do Flutter estão inicializados
  // 🔍 Analogia: É como "LIGAR A LUZ" antes de entrar.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Linha 41-43: Inicializa o Firebase com as opções da plataforma
  // 🔍 Analogia: É como "CONECTAR O SISTEMA" à nuvem.
  // 
  // DefaultFirebaseOptions.currentPlatform = usa as chaves certas
  // para a plataforma atual (Android, iOS, Web, etc.)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Linha 45: Inicia o aplicativo BoxStock
  // 🔍 Analogia: É como "ABRIR AS PORTAS" do shopping.
  runApp(const BoxStockApp());
}

// ============================================================
// 🏠 BOXSTOCKAPP — O "SHOPPING CENTER"
// ============================================================
// Linha 48: Define a classe BoxStockApp
// 
// 🔍 Analogia: É o "SHOPPING CENTER" inteiro.
// 
// StatelessWidget = não muda (é fixo)
class BoxStockApp extends StatelessWidget {
  const BoxStockApp({super.key});

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI O SHOPPING CENTER"
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Linha 58: Cria uma instância do AuthService
    // 🔍 Analogia: É o "SEGURANÇA" que controla quem entra.
    final authService = AuthService();

    // Linha 60: Retorna o MaterialApp (a estrutura principal)
    return MaterialApp(
      // Linha 61: O nome do aplicativo
      title: 'BoxStock',
      
      // Linha 62: Remove a faixa "DEBUG" no canto superior direito
      debugShowCheckedModeBanner: false,
      
      // ============================================================
      // 🎨 TEMA — A "DECORAÇÃO" DO SHOPPING
      // ============================================================
      // Linha 65: Define o tema do app (cores, fontes, estilos)
      theme: ThemeData(
        // ============================================================
        // 🎨 CORES PRIMÁRIAS — As "CORES PRINCIPAIS" do shopping
        // ============================================================
        primaryColor: BoxStockColors.papelaoMedio, // Cor principal (marrom)
        colorScheme: ColorScheme(
          brightness: Brightness.light, // Tema claro
          primary: BoxStockColors.papelaoMedio, // Cor principal
          onPrimary: Colors.white, // Cor do texto sobre a cor principal
          secondary: BoxStockColors.papelaoClaro, // Cor secundária
          onSecondary: BoxStockColors.textoPrincipal, // Texto sobre a secundária
          error: BoxStockColors.alerta, // Cor de erro (vermelho)
          onError: Colors.white, // Texto sobre o erro
          surface: BoxStockColors.campos, // Cor de superfície (campos)
          onSurface: BoxStockColors.textoPrincipal, // Texto sobre a superfície
        ),
        scaffoldBackgroundColor: BoxStockColors.fundoPrincipal, // Fundo da tela

        // ============================================================
        // 📱 APPBAR — A "BARRA SUPERIOR" do shopping
        // ============================================================
        appBarTheme: AppBarTheme(
          backgroundColor: BoxStockColors.papelaoMedio, // Cor da barra
          foregroundColor: Colors.white, // Cor do texto e ícones
          elevation: 0, // Sem sombra
          centerTitle: true, // Título centralizado
          titleTextStyle: const TextStyle( // Estilo do título
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white), // Cor dos ícones
        ),

        // ============================================================
        // 🔘 BOTÕES — Os "BOTÕES" do shopping
        // ============================================================
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: BoxStockColors.papelaoMedio, // Cor do botão
            foregroundColor: Colors.white, // Cor do texto
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Bordas arredondadas
            ),
            elevation: 4, // Sombra
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),

        // ============================================================
        // 📝 CAMPOS DE TEXTO — Os "FORMULÁRIOS" do shopping
        // ============================================================
        inputDecorationTheme: InputDecorationTheme(
          filled: true, // Preenche o fundo
          fillColor: BoxStockColors.campos, // Cor de fundo (creme)
          border: OutlineInputBorder( // Borda padrão
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: BoxStockColors.papelaoClaro.withOpacity(0.5),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder( // Borda quando habilitado
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: BoxStockColors.papelaoClaro.withOpacity(0.5),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder( // Borda quando em foco
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: BoxStockColors.papelaoMedio, // Fica mais forte
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder( // Borda quando tem erro
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: BoxStockColors.alerta, // Vermelho
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder( // Borda com erro em foco
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: BoxStockColors.alerta,
              width: 2.5,
            ),
          ),
          contentPadding: const EdgeInsets.all(16), // Espaço interno
          labelStyle: TextStyle(color: BoxStockColors.textoPrincipal), // Estilo do rótulo
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.5), // Texto de exemplo
          ),
        ),

        // ============================================================
        // 📝 TEXTOS — Os "LETREIROS" do shopping
        // ============================================================
        textTheme: const TextTheme(
          displayLarge: TextStyle( // Texto grande
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: BoxStockColors.textoPrincipal),
          bodyMedium: TextStyle(color: BoxStockColors.textoPrincipal),
        ),

        // ============================================================
        // 📱 BOTTOM NAVIGATION BAR — O "MENU INFERIOR"
        // ============================================================
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: BoxStockColors.fundoSecundario, // Fundo
          selectedItemColor: BoxStockColors.papelaoEscuro, // Cor quando selecionado
          unselectedItemColor: BoxStockColors.papelaoEscuro.withOpacity(0.5), // Cor quando não selecionado
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold), // Negrito quando selecionado
          elevation: 8, // Sombra
          type: BottomNavigationBarType.fixed, // Fixo
        ),

        useMaterial3: true, // Usa Material Design 3
        fontFamily: 'Roboto', // Fonte padrão
      ),
      
      // ============================================================
      // 🏠 HOME — A "TELA INICIAL" do shopping
      // ============================================================
      // Linha 181: O FutureBuilder verifica o login automático
      // 
      // 🔍 Analogia: O "SEGURANÇA" verifica se você já tem um crachá
      //              (login automático) ou se precisa se cadastrar.
      home: FutureBuilder<User?>(
        future: authService.loginAutomatico(), // Tenta fazer login automático
        builder: (context, snapshot) {
          // ============================================================
          // ⏳ ENQUANTO CARREGA — "Aguarde, estamos verificando..."
          // ============================================================
          // Linha 184-190: Enquanto o login automático está sendo verificado
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Mostra uma tela de carregamento
            return const Scaffold(
              backgroundColor: BoxStockColors.fundoPrincipal,
              body: Center(
                child: CircularProgressIndicator(
                  color: BoxStockColors.papelaoMedio,
                ),
              ),
            );
          }

          // ============================================================
          // ✅ LOGIN AUTOMÁTICO BEM-SUCEDIDO — "Você já tem crachá!"
          // ============================================================
          // Linha 193-194: Se o login automático foi bem-sucedido
          if (snapshot.data != null) {
            // Vai direto para a tela principal (Home)
            return const HomeScreen();
          }

          // ============================================================
          // ❌ SEM LOGIN AUTOMÁTICO — "Você precisa de um crachá!"
          // ============================================================
          // Linha 197: Se não tem login automático, usa o StreamBuilder
          // 
          // 🔍 Analogia: O "SEGURANÇA" pergunta: "Você tem crachá?"
          //              Se não, mostra a tela de login.
          return StreamBuilder<User?>(
            stream: authService.authStateChanges, // Escuta mudanças de autenticação
            builder: (context, snapshot) {
              // ============================================================
              // ⏳ ENQUANTO CARREGA — "Aguarde..."
              // ============================================================
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  backgroundColor: BoxStockColors.fundoPrincipal,
                  body: Center(
                    child: CircularProgressIndicator(
                      color: BoxStockColors.papelaoMedio,
                    ),
                  ),
                );
              }

              // ============================================================
              // ✅ USUÁRIO LOGADO — "Você tem crachá! Pode entrar."
              // ============================================================
              if (snapshot.hasData) {
                return const HomeScreen(); // Vai para a tela principal
              }

              // ============================================================
              // ❌ USUÁRIO NÃO LOGADO — "Você não tem crachá! Cadastre-se."
              // ============================================================
              return const LoginScreen(); // Vai para a tela de login
            },
          );
        },
      ),
    );
  }
}