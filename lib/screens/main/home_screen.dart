// ============================================================
// 📁 home_screen.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está em um "SHOPPING CENTER"
//              e precisa ir para diferentes lojas. Essa tela
//              é o "CORREDOR PRINCIPAL" que te leva para cada
//              uma das lojas (telas) do sistema.
// 
// 🏠 Ele é como o "MENU PRINCIPAL" do app:
//    - Tem um menu inferior com 6 botões (abas)
//    - Cada botão leva a uma tela diferente
//    - Dashboard → a "vitrine" do app
//    - Produtos → a "loja de produtos"
//    - Entrada → o "depósito de entrada"
//    - Saída → o "depósito de saída"
//    - Compras → a "lista de compras"
//    - Histórico → o "arquivo de registros"
//    - Tem um botão "+" para cadastrar novos produtos
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir a tela
import 'package:flutter/material.dart';
// Linha 2: Importa o Firebase Auth para fazer logout
import 'package:firebase_auth/firebase_auth.dart';
// Linha 3: Importa o serviço de autenticação
import '../../services/auth_service.dart';
// Linha 4: Importa as cores do sistema (BoxStockColors)
import '../../main.dart';
// Linhas 5-11: Importa todas as telas que o app usa
import 'dashboard_screen.dart';          // A tela inicial (vitrine)
import 'listagem_produtos_screen.dart';  // A lista de produtos (loja)
import 'entrada_screen.dart';            // A tela de entrada (depósito de entrada)
import 'saida_screen.dart';              // A tela de saída (depósito de saída)
import 'historico_screen.dart';          // A tela de histórico (arquivo)
import 'lista_compras_screen.dart';      // A tela de compras (lista de compras)
import 'cadastro_produto_screen.dart';   // A tela de cadastro (formulário)
import '../auth/login_screen.dart';      // A tela de login (entrada do app)

// ============================================================
// 🏠 CLASSE HOMESCREEN — A "TELA PRINCIPAL"
// ============================================================
// Linha 14: Define a classe HomeScreen
// StatefulWidget = a tela pode mudar (ex: trocar de aba)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  // Linha 18-20: Cria o estado da tela
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ============================================================
// 🧠 _HOMESCREENSTATE — A "MEMÓRIA" DA TELA PRINCIPAL
// ============================================================
// Linha 24: Classe que guarda o estado da tela principal
class _HomeScreenState extends State<HomeScreen> {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" da tela
  // ============================================================
  
  // Linha 27: Instância do AuthService (o "porteiro" que cuida do login)
  // Analogia: É o "SEGURANÇA" que controla quem entra e sai.
  final AuthService _authService = AuthService();
  
  // Linha 28: O índice da aba selecionada (0 = Dashboard, 1 = Produtos, etc.)
  // Analogia: É o "NÚMERO DA LOJA" que você está visitando.
  // Quando você clica em uma aba, esse número muda.
  int _selectedIndex = 0;

  // ============================================================
  // 📋 LISTA DE TELAS — As "LOJAS" do shopping
  // ============================================================
  // Linha 30-38: A lista de telas que aparecem no app.
  // Analogia: É o "MAPA DO SHOPPING" com todas as lojas.
  // Ordem: Dashboard (0), Produtos (1), Entrada (2), Saída (3), Compras (4), Histórico (5)
  final List<Widget> _telas = [
    const DashboardScreen(),        // Loja 0: A vitrine (Dashboard)
    const ListagemProdutosScreen(), // Loja 1: A loja de produtos (Listagem)
    const EntradaScreen(),          // Loja 2: O depósito de entrada (Entrada)
    const SaidaScreen(),            // Loja 3: O depósito de saída (Saída)
    const ListaComprasScreen(),     // Loja 4: A lista de compras (Compras)
    const HistoricoScreen(),        // Loja 5: O arquivo de registros (Histórico)
  ];

  // ============================================================
  // 📝 LISTA DE TÍTULOS — Os "NOMES" das lojas
  // ============================================================
  // Linha 40-48: Os títulos que aparecem na barra superior.
  // Analogia: É a "PLACA" na frente de cada loja.
  // Cada título corresponde a uma tela na mesma posição.
  final List<String> _titulos = [
    'BoxStock',      // Título da loja 0 (Dashboard)
    'Produtos',      // Título da loja 1 (Produtos)
    'Entrada',       // Título da loja 2 (Entrada)
    'Saída',         // Título da loja 3 (Saída)
    'Compras',       // Título da loja 4 (Compras)
    'Histórico',     // Título da loja 5 (Histórico)
  ];

  // ============================================================
  // 🎯 LISTA DE ÍCONES — Os "SÍMBOLOS" das lojas
  // ============================================================
  // Linha 50-58: Os ícones que aparecem no menu inferior.
  // Analogia: É o "SÍMBOLO" na porta de cada loja.
  final List<IconData> _icones = [
    Icons.dashboard,            // Ícone do Dashboard (um painel)
    Icons.inventory_2,          // Ícone de Produtos (uma caixa)
    Icons.add_box,              // Ícone de Entrada (caixa com +)
    Icons.remove_shopping_cart, // Ícone de Saída (carrinho com -)
    Icons.shopping_cart,        // Ícone de Compras (carrinho)
    Icons.history,              // Ícone de Histórico (um relógio)
  ];

  // ============================================================
  // 🎯 LISTA DE ÍCONES SELECIONADOS — Ícones "vazados"
  // ============================================================
  // Linha 60-68: Os ícones que aparecem quando a aba NÃO está selecionada.
  // Analogia: É o "SÍMBOLO APAGADO" da loja quando você não está nela.
  // A diferença é que esses ícones são "vazados" (outlined).
  final List<IconData> _iconesSelecionados = [
    Icons.dashboard_outlined,       // Ícone vazado do Dashboard
    Icons.inventory_2_outlined,     // Ícone vazado de Produtos
    Icons.add_box_outlined,         // Ícone vazado de Entrada
    Icons.remove_shopping_cart_outlined, // Ícone vazado de Saída
    Icons.shopping_cart_outlined,   // Ícone vazado de Compras
    Icons.history_outlined,         // Ícone vazado de Histórico
  ];

  // ============================================================
  // 🚪 _LOGOUT — "SAIR DO APP"
  // ============================================================
  // Linha 71: Função que faz o logout do usuário.
  // Analogia: É como "SAIR DO SHOPPING" — você vai embora.
  // 
  // O que ela faz:
  // 1. Chama o AuthService para deslogar
  // 2. Mostra uma mensagem "Até logo!"
  // 3. Volta para a tela de login
  Future<void> _logout() async {
    // Linha 72: Chama o serviço de autenticação para deslogar
    // Analogia: O "SEGURANÇA" registra que você saiu.
    await _authService.logout();
    
    // Linha 73: Verifica se a tela ainda está montada
    // Se o usuário fechou a tela, não faz nada.
    if (!mounted) return;

    // Linha 76-81: Mostra uma mensagem de despedida (SnackBar)
    // Analogia: É como um "AVISO" que aparece dizendo "Até logo!"
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('👏 Até logo!'), // O texto da mensagem
        backgroundColor: BoxStockColors.sucesso, // Cor verde
        duration: Duration(seconds: 2), // Fica 2 segundos na tela
      ),
    );

    // Linha 83-85: Vai para a tela de login
    // Analogia: É como "SAIR DO SHOPPING" e voltar para a porta de entrada.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  // ============================================================
  // ➕ _ABRIRCADASTROPRODUTO — "ABRIR O FORMULÁRIO DE CADASTRO"
  // ============================================================
  // Linha 90: Função que abre a tela de cadastro de produtos.
  // Analogia: É como "ABRIR O FORMULÁRIO" para cadastrar um novo produto.
  // 
  // O que ela faz:
  // 1. Abre a tela de cadastro
  // 2. Quando voltar, recarrega a tela atual
  void _abrirCadastroProduto() {
    // Linha 91: Navega para a tela de cadastro
    // Analogia: O usuário vai para o "GUICHÊ" onde pode cadastrar um produto.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroProdutoScreen(), // Vai para o cadastro
      ),
    ).then((_) { // Linha 96: Quando voltar do cadastro...
      setState(() {}); // Recarrega a tela (atualiza a lista)
    });
  }

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI A TELA PRINCIPAL"
  // ============================================================
  // Linha 103: A função que constrói toda a tela.
  @override
  Widget build(BuildContext context) {
    // Linha 104: Retorna um Scaffold (a estrutura básica da tela)
    return Scaffold(
      // Linha 105: Define a cor de fundo da tela.
      backgroundColor: BoxStockColors.fundoPrincipal,

      // ============================================================
      // 📱 APPBAR — A "BARRA SUPERIOR"
      // ============================================================
      // Linha 108: A barra que fica no topo da tela.
      // Analogia: É a "FACHADA" da loja, com o nome e a logo.
      appBar: AppBar(
        // Linha 109: O título da barra (logo + nome da tela)
        // Analogia: É a "PLACA" na frente da loja.
        title: Row(
          children: [
            // Linha 111: A logo do BoxStock (a imagem)
            // Analogia: É o "SÍMBOLO" da marca.
            Image.asset(
              'assets/images/Logo.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10), // Espaço entre a logo e o título
            Text( // Linha 120: O título da tela atual
              _titulos[_selectedIndex], // Pega o título da aba selecionada
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: BoxStockColors.papelaoMedio, // Cor marrom/laranja
        foregroundColor: Colors.white, // Cor do texto e ícones
        elevation: 0, // Sem sombra
        centerTitle: true, // Centraliza o título
        actions: [ // Linha 133: Botões na barra superior
          IconButton( // Botão de logout
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout, // Quando clica, faz logout
            tooltip: 'Sair', // Dica que aparece ao segurar
          ),
        ],
        // Linha 141-155: A "fita adesiva" decorativa abaixo da barra
        // Analogia: É como uma "FITA ADESIVA" que enfeita a loja.
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient( // Degradê de cores
                colors: [
                  BoxStockColors.papelaoClaro,
                  BoxStockColors.papelaoMedio,
                  BoxStockColors.papelaoClaro,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
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
      // Linha 160: O conteúdo principal (a loja que está sendo visitada)
      // Analogia: É a "LOJA" que você está visitando no shopping.
      // A tela que aparece é a que corresponde à aba selecionada.
      body: _telas[_selectedIndex],

      // ============================================================
      // 📱 BOTTOMNAVIGATIONBAR — O "MENU INFERIOR"
      // ============================================================
      // Linha 163: O menu inferior com 6 botões.
      // Analogia: É o "CORREDOR" do shopping com as lojas.
      bottomNavigationBar: Container(
        // Linha 164-169: A sombra do menu (efeito de profundidade)
        // Analogia: É como uma "SOMBRA" que dá profundidade ao corredor.
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: BoxStockColors.papelaoEscuro.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4), // Sombra para cima
            ),
          ],
        ),
        child: BottomNavigationBar( // Linha 172: O menu inferior
          type: BottomNavigationBarType.fixed, // Fixo (não rola)
          currentIndex: _selectedIndex, // A aba selecionada
          onTap: (index) { // Linha 175: Quando clica em uma aba
            setState(() {
              _selectedIndex = index; // Muda a aba selecionada
            });
          },
          selectedItemColor: BoxStockColors.papelaoEscuro, // Cor quando selecionado
          unselectedItemColor: BoxStockColors.papelaoEscuro.withOpacity(0.4), // Cor quando não selecionado
          backgroundColor: BoxStockColors.fundoSecundario, // Cor de fundo
          elevation: 0, // Sem sombra (já temos no container)
          selectedLabelStyle: const TextStyle( // Estilo do texto selecionado
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle( // Estilo do texto não selecionado
            fontWeight: FontWeight.normal,
            fontSize: 11,
            color: BoxStockColors.papelaoEscuro.withOpacity(0.4),
          ),
          items: List.generate(_titulos.length, (index) { // Linha 193: Cria os itens
            // Para cada título, cria um item no menu
            return BottomNavigationBarItem(
              icon: Icon( // O ícone
                _selectedIndex == index // Se está selecionado
                    ? _icones[index] // Usa o ícone cheio
                    : _iconesSelecionados[index], // Usa o ícone vazado
                size: 26,
              ),
              label: _titulos[index], // O texto do item
            );
          }),
        ),
      ),

      // ============================================================
      // ➕ FLOATINGACTIONBUTTON — O "BOTÃO MÁGICO"
      // ============================================================
      // Linha 208: O botão flutuante que fica sobre a tela.
      // Analogia: É como um "BOTÃO DE EMERGÊNCIA" que está sempre disponível
      //           para cadastrar um novo produto.
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastroProduto, // Quando clica, abre o cadastro
        backgroundColor: BoxStockColors.acaoPrincipal, // Cor laranja
        foregroundColor: Colors.white, // Cor do ícone
        elevation: 8, // Sombra alta
        shape: RoundedRectangleBorder( // Borda arredondada
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: BoxStockColors.papelaoMedio,
            width: 2,
          ),
        ),
        child: const Icon(Icons.add, size: 32, color: Colors.white), // O símbolo "+"
      ),
      // Linha 222: Posição do botão (canto inferior direito)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}