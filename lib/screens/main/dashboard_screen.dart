// ============================================================
// 📁 dashboard_screen.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está no "PAINEL DE CONTROLE"
//              de um carro. Você vê o velocímetro (total de produtos),
//              o marcador de combustível (estoque baixo),
//              o aviso de problema (sem estoque)
//              e o hodômetro (categorias).
// 
// 🏠 Ele é como o "QUADRO DE COMANDOS" do seu estoque:
//    - Mostra um resumo rápido da situação
//    - Total de produtos cadastrados
//    - Produtos com estoque baixo
//    - Produtos sem estoque
//    - Total de categorias
//    - Últimos produtos cadastrados
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir a tela
import 'package:flutter/material.dart';
// Linha 2: Importa o Firebase Auth para pegar o usuário logado
import 'package:firebase_auth/firebase_auth.dart';
// Linha 3: Importa o Firestore para trabalhar com o banco de dados
import 'package:cloud_firestore/cloud_firestore.dart';
// Linha 4: Importa o serviço do Firestore
import '../../services/firestore_service.dart';
// Linha 5: Importa o modelo de Produto
import '../../models/produto_model.dart';
// Linha 6: Importa as cores do sistema
import '../../main.dart';
// Linha 7: Importa a tela de cadastro de produto
import 'cadastro_produto_screen.dart';

// ============================================================
// 🏠 CLASSE DASHBOARDSCREEN — A "TELA DO PAINEL"
// ============================================================
// Linha 10: Define a classe DashboardScreen
// StatefulWidget = a tela pode mudar (ex: quando carrega os dados)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// ============================================================
// 🧠 _DASHBOARDSCREENSTATE — A "MEMÓRIA" DA TELA
// ============================================================
// Linha 18: Classe que guarda o estado do Dashboard
class _DashboardScreenState extends State<DashboardScreen> {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" do painel
  // ============================================================
  
  // Linha 21: Instância do FirestoreService (o "entregador" que busca os dados)
  final FirestoreService _firestoreService = FirestoreService();
  
  // Linha 22: Mapa que guarda os dados do dashboard.
  // Analogia: É como uma "PLANILHA" que guarda todos os números.
  Map<String, dynamic> _dados = {};
  
  // Linha 23: Controla se está carregando.
  // true = mostra a roda de carregamento.
  bool _carregando = true;
  
  // Linha 24: Nome do usuário logado.
  // Analogia: É o "NOME" que aparece no painel do carro.
  String _userName = 'Usuário';
  
  // Linha 25: Lista dos últimos produtos cadastrados.
  // Analogia: É como o "HISTÓRICO" das últimas coisas que você fez.
  List<Produto> _ultimosProdutos = [];

  // ============================================================
  // 🚀 INITSTATE — "O QUE ACONTECE QUANDO A TELA ABRE"
  // ============================================================
  // Linhas 28-33: Função chamada quando a tela é aberta.
  // Analogia: É como "LIGAR O CARRO" — tudo começa a funcionar.
  @override
  void initState() {
    super.initState(); // Chama o initState da classe pai
    _carregarDados(); // Busca os números do dashboard
    _carregarNomeUsuario(); // Busca o nome do usuário
    _carregarUltimosProdutos(); // Busca os últimos produtos
  }

  // ============================================================
  // 📊 _CARREGARDADOS — "BUSCA OS NÚMEROS DO DASHBOARD"
  // ============================================================
  // Linha 36: Função que busca os dados do dashboard.
  // Analogia: É como "LER O PAINEL" do carro para ver os números.
  Future<void> _carregarDados() async {
    try { // Tenta fazer algo que pode dar erro
      // Linha 38: Chama o Firestore para pegar os dados do dashboard.
      final dados = await _firestoreService.obterDadosDashboard();
      // Linha 39-42: Atualiza a tela com os dados.
      setState(() {
        _dados = dados; // Guarda os dados
        _carregando = false; // Para de mostrar o carregamento
      });
    } catch (e) { // Se deu erro
      // Linha 44: Mesmo com erro, para de mostrar o carregamento.
      setState(() => _carregando = false);
    }
  }

  // ============================================================
  // 👤 _CARREGARNOMEUSUARIO — "BUSCA O NOME DO USUÁRIO"
  // ============================================================
  // Linha 48: Função que busca o nome do usuário logado.
  // Analogia: É como "VER QUEM ESTÁ DIRIGINDO" o carro.
  Future<void> _carregarNomeUsuario() async {
    // Linha 49: Pega o usuário atual do Firebase.
    final user = FirebaseAuth.instance.currentUser;
    // Linha 50: Se o usuário existe e tem e-mail...
    if (user != null && user.email != null) {
      // Linha 51-53: Pega a parte do e-mail antes do @.
      // Exemplo: "joao@email.com" → "joao"
      setState(() {
        _userName = user.email!.split('@')[0];
      });
    }
  }

  // ============================================================
  // 📦 _CARREGARULTIMOSPRODUTOS — "BUSCA OS ÚLTIMOS PRODUTOS"
  // ============================================================
  // Linha 57: Função que busca os últimos 5 produtos.
  // Analogia: É como "OLHAR O HISTÓRICO" das últimas compras.
  Future<void> _carregarUltimosProdutos() async {
    try { // Tenta fazer algo que pode dar erro
      // Linha 59: Busca a lista de produtos do Firestore.
      // .first = pega a primeira lista (em tempo real)
      final produtos = await _firestoreService.listarProdutos().first;
      // Linha 60-62: Pega os 5 primeiros produtos e atualiza a tela.
      setState(() {
        _ultimosProdutos = produtos.take(5).toList();
      });
    } catch (e) {
      // Linha 64: Se deu erro, ignora (não faz nada).
    }
  }

  // ============================================================
  // ➕ _ABRIRCADASTRO — "ABRE A TELA DE CADASTRO"
  // ============================================================
  // Linha 68: Função que abre a tela de cadastro de produtos.
  // Analogia: É como "APERTAR O BOTÃO" para adicionar um novo item.
  void _abrirCadastro() {
    // Linha 69: Navega para a tela de cadastro.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroProdutoScreen(), // Vai para o cadastro
      ),
    ).then((_) { // Quando voltar do cadastro...
      // Linha 74-75: Recarrega os dados.
      _carregarDados();
      _carregarUltimosProdutos();
    });
  }

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI A TELA DO DASHBOARD"
  // ============================================================
  // Linha 80: A função que constrói toda a tela.
  @override
  Widget build(BuildContext context) {
    // Linha 81: Retorna um Scaffold (a estrutura básica da tela)
    return Scaffold(
      // Linha 82: Define a cor de fundo.
      backgroundColor: BoxStockColors.fundoPrincipal,
      
      // Linha 83: SafeArea = não deixa o conteúdo ficar atrás da barra de status
      body: SafeArea(
        child: SingleChildScrollView( // Linha 85: Permite rolar a tela
          padding: const EdgeInsets.all(20), // Espaço nas bordas
          child: Column( // Linha 87: Organiza os widgets em coluna
            crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
            children: [
              // ============================================================
              // 🏠 CABEÇALHO
              // ============================================================
              // Linha 92: Constrói o cabeçalho com a logo e saudação
              _buildCabecalho(),
              const SizedBox(height: 24), // Espaço

              // ============================================================
              // 📊 CARDS DE RESUMO
              // ============================================================
              // Linha 96: Se estiver carregando...
              _carregando
                  ? const Center( // Mostra a roda de carregamento
                      child: CircularProgressIndicator(
                        color: BoxStockColors.papelaoMedio,
                      ),
                    )
                  : _buildCardsResumo(), // Senão, mostra os cards
              const SizedBox(height: 24), // Espaço

              // ============================================================
              // 📦 ÚLTIMOS PRODUTOS
              // ============================================================
              // Linha 107: Constrói a lista dos últimos produtos
              _buildProdutosRecentes(),
              const SizedBox(height: 80), // Espaço extra para o botão flutuante
            ],
          ),
        ),
      ),
      
      // ============================================================
      // ➕ BOTÃO FLUTUANTE — O "BOTÃO MÁGICO"
      // ============================================================
      // Linha 113: O botão que flutua sobre a tela.
      // Analogia: É como um "BOTÃO DE EMERGÊNCIA" que está sempre disponível.
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastro, // Quando clica, abre o cadastro
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
        child: const Icon(Icons.add, size: 32, color: Colors.white), // O "+"
      ),
      // Linha 128: Posição do botão (canto inferior direito)
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ============================================================
  // 🏠 _BUILDCABECALHO — "CONSTRÓI O CABEÇALHO"
  // ============================================================
  // Linha 134: Função que constrói o cabeçalho.
  // Analogia: É como o "PAINEL" do carro onde mostra a saudação.
  Widget _buildCabecalho() {
    // Linha 135: Retorna um container com o cabeçalho.
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient( // Fundo com gradiente (cores que mudam)
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BoxStockColors.papelaoClaro.withOpacity(0.15),
            BoxStockColors.papelaoClaro.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20), // Bordas arredondadas
        boxShadow: [ // Sombra
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
        border: Border.all( // Borda
          color: BoxStockColors.papelaoClaro.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row( // Linha 158: Organiza em linha
        children: [
          // 🔥 LOGO
          // Linha 161: A logo do BoxStock
          Image.asset(
            'assets/images/Logo.png',
            width: 48,
            height: 48,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 16), // Espaço
          
          // Linha 170: Informações do usuário
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text( // Linha 175: "Olá, [nome]! 👋"
                  'Olá, $_userName! 👋',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 2),
                Text( // Linha 185: "Bem-vindo ao seu controle de estoque."
                  'Bem-vindo ao seu controle de estoque.',
                  style: TextStyle(
                    fontSize: 14,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // ============================================================
          // 🟢 STATUS ONLINE — O "SEMÁFORO VERDE"
          // ============================================================
          // Linha 195: O indicador de "Online"
          // Analogia: É a "LUZINHA VERDE" que mostra que o sistema está funcionando.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: BoxStockColors.sucesso.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: BoxStockColors.sucesso.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container( // A "bolinha verde"
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: BoxStockColors.sucesso,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text( // O texto "Online"
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: BoxStockColors.sucesso,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📊 _BUILDCARDSRESUMO — "CONSTRÓI OS CARDS DE RESUMO"
  // ============================================================
  // Linha 231: Função que constrói os 4 cards.
  // Analogia: É como os "INSTRUMENTOS" do painel do carro.
  Widget _buildCardsResumo() {
    // Linha 232: Retorna uma grade com 2 colunas.
    return GridView.count(
      shrinkWrap: true, // Ocupa só o espaço necessário
      physics: const NeverScrollableScrollPhysics(), // Não permite rolar dentro da grade
      crossAxisCount: 2, // 2 colunas
      crossAxisSpacing: 16, // Espaço entre colunas
      mainAxisSpacing: 16, // Espaço entre linhas
      childAspectRatio: 1.0, // Largura = altura
      children: [
        // Linha 244: Card "Total Produtos"
        _buildCard(
          titulo: 'Total Produtos',
          valor: _dados['totalProdutos']?.toString() ?? '0',
          icone: Icons.inventory_2,
          cor: BoxStockColors.informacao,
        ),
        // Linha 251: Card "Estoque Baixo"
        _buildCard(
          titulo: 'Estoque Baixo',
          valor: _dados['produtosEstoqueBaixo']?.toString() ?? '0',
          icone: Icons.warning_amber_rounded,
          cor: BoxStockColors.acaoPrincipal,
        ),
        // Linha 258: Card "Sem Estoque"
        _buildCard(
          titulo: 'Sem Estoque',
          valor: _dados['produtosSemEstoque']?.toString() ?? '0',
          icone: Icons.error_outline,
          cor: BoxStockColors.alerta,
        ),
        // Linha 265: Card "Categorias"
        _buildCard(
          titulo: 'Categorias',
          valor: _dados['totalCategorias']?.toString() ?? '0',
          icone: Icons.category,
          cor: BoxStockColors.recursoSecundario,
        ),
      ],
    );
  }

  // ============================================================
  // 🃏 _BUILDCARD — "CONSTRÓI UM CARD INDIVIDUAL"
  // ============================================================
  // Linha 274: Função que constrói cada card.
  // Analogia: É como um "INSTRUMENTO" do painel (velocímetro, etc.)
  Widget _buildCard({
    required String titulo, // O título (ex: "Total Produtos")
    required String valor, // O valor (ex: "15")
    required IconData icone, // O ícone (ex: Icons.inventory_2)
    required Color cor, // A cor do card
  }) {
    // Linha 280: Retorna um container com o card.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [ // Sombra
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: BoxStockColors.papelaoClaro.withOpacity(0.3),
            offset: const Offset(-2, -2),
            blurRadius: 8,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Column( // Organiza em coluna
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Linha 302: O círculo com o ícone
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.1), // Cor com transparência
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: cor.withOpacity(0.2),
                width: 1.5,
              ),
            ),
            child: Icon( // O ícone
              icone,
              color: cor,
              size: 32,
            ),
          ),
          const SizedBox(height: 12), // Espaço
          
          // Linha 317: O número grande
          Text(
            valor,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: BoxStockColors.textoPrincipal,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4), // Espaço
          
          // Linha 326: O título
          Text(
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: BoxStockColors.textoPrincipal.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📦 _BUILDPRODUTOSRECENTES — "CONSTRÓI A LISTA DE ÚLTIMOS PRODUTOS"
  // ============================================================
  // Linha 339: Função que constrói a lista dos últimos produtos.
  // Analogia: É como o "HISTÓRICO" do seu navegador.
  Widget _buildProdutosRecentes() {
    // Linha 340: Retorna um container com a lista.
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // 📝 TÍTULO
          // ============================================================
          Row( // Linha 360: Título com ícone
            children: [
              const Icon(
                Icons.inventory_2,
                color: BoxStockColors.papelaoMedio,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Últimos Produtos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: BoxStockColors.textoPrincipal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Espaço

          // ============================================================
          // 📋 LISTA
          // ============================================================
          // Linha 378: Se estiver carregando...
          _carregando
              ? const Center( // Mostra a roda de carregamento
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(
                      color: BoxStockColors.papelaoMedio,
                    ),
                  ),
                )
              : _ultimosProdutos.isEmpty // Se não tiver produtos...
                  ? Container( // Mostra uma mensagem de "vazio"
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon( // Ícone de estoque vazio
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: BoxStockColors.papelaoClaro.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text( // Mensagem
                            'Nenhum produto cadastrado ainda',
                            style: TextStyle(
                              fontSize: 16,
                              color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column( // Senão, mostra a lista de produtos
                      children: _ultimosProdutos.map((produto) {
                        return _buildProdutoItem(produto);
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  // ============================================================
  // 🏷️ _BUILDPRODUTOITEM — "CONSTRÓI UM ITEM DA LISTA"
  // ============================================================
  // Linha 414: Função que constrói cada item da lista de produtos.
  // Analogia: É como cada "ITEM" no histórico do navegador.
  Widget _buildProdutoItem(Produto produto) {
    // Linha 415: Retorna um container com o produto.
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row( // Linha 430: Organiza em linha
        children: [
          // ============================================================
          // 🖼️ ÍCONE DO PRODUTO
          // ============================================================
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BoxStockColors.fundoSecundario,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: BoxStockColors.papelaoClaro.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.inventory_2,
              size: 20,
              color: BoxStockColors.papelaoMedio,
            ),
          ),
          const SizedBox(width: 12), // Espaço

          // ============================================================
          // 📝 INFORMAÇÕES DO PRODUTO
          // ============================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text( // O nome do produto
                  produto.nome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: BoxStockColors.textoPrincipal,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text( // O código e a quantidade
                  'Cód: ${produto.codigo} | Qtd: ${produto.quantidade.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // ============================================================
          // 🏷️ STATUS (DISPONÍVEL, BAIXO, SEM ESTOQUE)
          // ============================================================
          _buildStatusChip(produto),
        ],
      ),
    );
  }

  // ============================================================
  // 🏷️ _BUILDSTATUSCHIP — "CONSTRÓI O STATUS DO PRODUTO"
  // ============================================================
  // Linha 474: Função que constrói o status do produto.
  // Analogia: É como uma "ETIQUETA" que diz se o produto está
  //           verde (disponível), amarelo (baixo) ou vermelho (sem estoque).
  Widget _buildStatusChip(Produto produto) {
    // Linha 475-482: Define o texto e a cor baseado na quantidade
    String label;
    Color color;

    if (produto.quantidade <= 0) { // Se não tem estoque
      label = 'SEM ESTOQUE';
      color = BoxStockColors.alerta; // Vermelho
    } else if (produto.quantidade <= produto.estoqueMinimo) { // Se está baixo
      label = 'BAIXO';
      color = BoxStockColors.acaoPrincipal; // Laranja
    } else { // Se está disponível
      label = 'DISPONÍVEL';
      color = BoxStockColors.sucesso; // Verde
    }

    // Linha 484: Retorna o container com o status
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), // Cor com transparência
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row( // Linha 493: Organiza em linha
        mainAxisSize: MainAxisSize.min,
        children: [
          Container( // A "bolinha" colorida
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6), // Espaço
          Text( // O texto do status
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}