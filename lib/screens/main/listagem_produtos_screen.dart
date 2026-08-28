// ============================================================
// 📁 listagem_produtos_screen.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está em uma "LOJA DE DEPARTAMENTOS"
//              e quer ver todos os produtos disponíveis.
//              Essa tela é o "CORREDOR DA LOJA" onde todos os
//              produtos estão organizados em prateleiras.
// 
// 🏠 Ele é como a "VITRINE" do seu estoque:
//    - Mostra todos os produtos cadastrados
//    - Permite buscar produtos pelo nome ou código
//    - Mostra o status de cada produto (Disponível, Baixo, Sem Estoque)
//    - Cada produto tem um botão "Ver Detalhes"
//    - Tem paginação (carrega 5 produtos por vez)
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir a tela
import 'package:flutter/material.dart';
// Linha 2: Importa o Firebase Auth para pegar o usuário logado
import 'package:firebase_auth/firebase_auth.dart';
// Linha 3: Importa o Firestore para buscar produtos
import 'package:cloud_firestore/cloud_firestore.dart';
// Linha 4: Importa o serviço do Firestore
import '../../services/firestore_service.dart';
// Linha 5: Importa o modelo de Produto
import '../../models/produto_model.dart';
// Linha 6: Importa o widget de campo de busca (a "lupa")
import '../../widgets/campo_busca.dart';
// Linha 7: Importa o widget de status do estoque (o "semáforo")
import '../../widgets/status_estoque.dart';
// Linha 8: Importa as cores do sistema
import '../../main.dart';
// Linhas 9-12: Importa outras telas para navegação
import 'cadastro_produto_screen.dart';  // Para cadastrar/editar
import 'entrada_screen.dart';          // Para registrar entrada
import 'saida_screen.dart';            // Para registrar saída
import 'detalhes_produto_screen.dart'; // Para ver detalhes

// ============================================================
// 🏠 CLASSE LISTAGEMPRODUTOSSCREEN — A "TELA DA VITRINE"
// ============================================================
// Linha 15: Define a classe ListagemProdutosScreen
// StatefulWidget = a tela pode mudar (busca, paginação, etc.)
class ListagemProdutosScreen extends StatefulWidget {
  const ListagemProdutosScreen({super.key});

  // Linha 19-21: Cria o estado da tela
  @override
  State<ListagemProdutosScreen> createState() => _ListagemProdutosScreenState();
}

// ============================================================
// 🧠 _LISTAGEMPRODUTOSSCREENSTATE — A "MEMÓRIA" DA TELA
// ============================================================
// Linha 25: Classe que guarda o estado da tela de listagem
class _ListagemProdutosScreenState extends State<ListagemProdutosScreen> {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" da tela
  // ============================================================
  
  // Linha 28: Instância do FirestoreService (o "entregador" dos dados)
  final FirestoreService _firestoreService = FirestoreService();
  
  // Linha 29: Controlador do campo de busca
  // Analogia: É o "CADERNO" onde o usuário escreve o que quer procurar.
  final TextEditingController _buscaController = TextEditingController();

  // Linha 31: Lista com TODOS os produtos do usuário
  // Analogia: É a "PRATELEIRA" cheia de produtos.
  List<Produto> _todosProdutos = [];
  
  // Linha 32: Lista com os produtos que aparecem na tela (filtrados)
  // Analogia: É a "VITRINE" que mostra apenas alguns produtos.
  List<Produto> _produtosFiltrados = [];
  
  // Linha 33: Controla se está carregando
  bool _carregando = false;
  
  // Linha 34: Se tem mais produtos para carregar (paginação)
  bool _temMaisProdutos = true;
  
  // Linha 35: O termo que o usuário digitou na busca
  // Analogia: É o que o usuário escreveu na "LUPA" para procurar.
  String _termoBusca = '';
  
  // Linha 36: O último documento carregado (para paginação)
  // Analogia: É como um "MARCADOR" que lembra onde você parou.
  DocumentSnapshot? _ultimoDocumento;
  
  // Linha 37: Quantos produtos carregar por vez (paginação)
  // Analogia: É como "5 PRODUTOS POR PRATELEIRA".
  static const int _limitePorPagina = 5;

  // ============================================================
  // 🚀 INITSTATE — "O QUE ACONTECE QUANDO A TELA ABRE"
  // ============================================================
  // Linhas 40-43: Função chamada quando a tela é aberta.
  // Analogia: É a "ATENDENTE" que já organiza os produtos na vitrine.
  @override
  void initState() {
    super.initState(); // Chama o initState da classe pai
    _carregarProdutosIniciais(); // Carrega os primeiros produtos
  }

  // ============================================================
  // 🧹 DISPOSE — "LIMPA A MESA" QUANDO SAI
  // ============================================================
  // Linhas 45-48: Quando a tela é fechada, limpamos o controlador.
  @override
  void dispose() {
    _buscaController.dispose(); // Libera a memória da busca
    super.dispose();
  }

  // ============================================================
  // 📥 _CARREGARPRODUTOSINICIAIS — "CARREGA OS PRIMEIROS PRODUTOS"
  // ============================================================
  // Linha 52: Função que carrega todos os produtos do usuário.
  // Analogia: É como "ABRIR O ESTOQUE" e pegar todos os produtos.
  Future<void> _carregarProdutosIniciais() async {
    // Linha 53-59: Mostra o carregamento e limpa as listas
    setState(() {
      _carregando = true;
      _todosProdutos = [];
      _produtosFiltrados = [];
      _temMaisProdutos = true;
      _ultimoDocumento = null;
    });

    try { // Tenta fazer algo que pode dar erro
      // Linha 62: Pega o usuário logado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // Se não tem usuário, para aqui

      // Linha 65-70: Busca todos os produtos do usuário no Firestore
      // Analogia: O "ENTREGADOR" vai até o estoque e traz todos os produtos.
      final snapshot = await FirebaseFirestore.instance
          .collection('produtos') // Vai na coleção "produtos"
          .where('usuarioId', isEqualTo: user.uid) // Só do usuário
          .orderBy('nome') // Ordena por nome (A-Z)
          .get(); // Executa a busca

      // Linha 73-79: Converte os resultados em uma lista de Produto
      // Analogia: O "ENTREGADOR" coloca os produtos na prateleira.
      final todos = snapshot.docs
          .where((doc) => doc.data() != null) // Ignora dados nulos
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Produto.fromMap(doc.id, data); // Converte para Produto
          })
          .toList();

      // Linha 81-86: Atualiza a tela com os produtos
      setState(() {
        _todosProdutos = todos; // Guarda todos os produtos
        _carregando = false; // Para de mostrar o carregamento
        _aplicarFiltro(); // Aplica o filtro (se houver)
      });
    } catch (e) { // Se deu erro
      setState(() {
        _carregando = false;
      });
      _showErrorDialog('Erro ao carregar produtos: $e');
    }
  }

  // ============================================================
  // 🔍 _APLICARFILTRO — "FILTRA OS PRODUTOS"
  // ============================================================
  // Linha 93: Função que filtra os produtos pelo termo de busca.
  // Analogia: É como "PENEIRAR" os produtos para mostrar só o que você quer.
  void _aplicarFiltro() {
    final termo = _termoBusca.toLowerCase().trim(); // Pega o termo de busca
    
    if (termo.isEmpty) { // Se não tem termo de busca
      // Linha 97-102: Mostra os 5 primeiros produtos
      setState(() {
        _produtosFiltrados = _todosProdutos.take(_limitePorPagina).toList();
        _temMaisProdutos = _todosProdutos.length > _limitePorPagina;
        _ultimoDocumento = null;
      });
    } else { // Se tem termo de busca
      // Linha 105-112: Filtra os produtos pelo termo
      // Analogia: A "PENEIRA" só deixa passar os produtos que têm
      //           o termo no nome ou no código.
      final filtrados = _todosProdutos.where((produto) {
        final nomeMatch = produto.nome.toLowerCase().contains(termo);
        final codigoMatch = produto.codigo.toLowerCase().contains(termo);
        return nomeMatch || codigoMatch; // Retorna se encontrar no nome ou no código
      }).toList();

      // Linha 114-119: Mostra os primeiros 5 produtos filtrados
      setState(() {
        _produtosFiltrados = filtrados.take(_limitePorPagina).toList();
        _temMaisProdutos = filtrados.length > _limitePorPagina;
        _ultimoDocumento = null;
      });
    }
  }

  // ============================================================
  // 🔍 _BUSCARPRODUTOS — "ATUALIZA A BUSCA"
  // ============================================================
  // Linha 124: Função que é chamada quando o usuário digita na busca.
  // Analogia: É como "DIZER" para a atendente o que você está procurando.
  void _buscarProdutos(String termo) {
    setState(() {
      _termoBusca = termo; // Guarda o termo digitado
    });
    _aplicarFiltro(); // Aplica o filtro com o novo termo
  }

  // ============================================================
  // 📥 _CARREGARMAISPRODUTOS — "CARREGA MAIS PRODUTOS"
  // ============================================================
  // Linha 132: Função que carrega mais 5 produtos.
  // Analogia: É como "PUXAR" mais produtos da prateleira.
  void _carregarMaisProdutos() {
    // Linha 133: Se já está carregando ou não tem mais, para aqui.
    if (_carregando || !_temMaisProdutos) return;

    // Linha 135-145: Pega todos os produtos filtrados (com base no termo de busca)
    final termo = _termoBusca.toLowerCase().trim();
    List<Produto> todosFiltrados;

    if (termo.isEmpty) { // Se não tem busca
      todosFiltrados = _todosProdutos; // Usa todos os produtos
    } else { // Se tem busca
      // Filtra os produtos que têm o termo no nome ou código
      todosFiltrados = _todosProdutos.where((produto) {
        final nomeMatch = produto.nome.toLowerCase().contains(termo);
        final codigoMatch = produto.codigo.toLowerCase().contains(termo);
        return nomeMatch || codigoMatch;
      }).toList();
    }

    // Linha 148: O índice onde começar a pegar os produtos
    final startIndex = _produtosFiltrados.length;
    // Linha 149: O índice onde terminar
    final endIndex = startIndex + _limitePorPagina;

    // Linha 151-154: Se já carregou todos os produtos
    if (startIndex >= todosFiltrados.length) {
      setState(() {
        _temMaisProdutos = false; // Não tem mais produtos
      });
      return;
    }

    // Linha 157-160: Pega os próximos produtos
    final novosProdutos = todosFiltrados.sublist(
      startIndex,
      endIndex > todosFiltrados.length ? todosFiltrados.length : endIndex,
    );

    // Linha 162-166: Adiciona os novos produtos à lista
    setState(() {
      _produtosFiltrados.addAll(novosProdutos);
      _temMaisProdutos = endIndex < todosFiltrados.length;
    });
  }

  // ============================================================
  // ❌ _SHOWERRORDIALOG — "MOSTRA O ERRO"
  // ============================================================
  // Linha 170: Função que mostra um diálogo de erro.
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

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI A TELA DE LISTAGEM"
  // ============================================================
  // Linha 194: A função que constrói toda a tela.
  @override
  Widget build(BuildContext context) {
    // Linha 195: Retorna um Scaffold (a estrutura básica da tela)
    return Scaffold(
      backgroundColor: BoxStockColors.fundoPrincipal, // Cor de fundo
      
      body: SafeArea( // Não deixa o conteúdo ficar atrás da barra de status
        child: Column( // Linha 200: Organiza em coluna
          children: [
            // ============================================================
            // 🔍 CAMPO DE BUSCA — A "LUPA"
            // ============================================================
            // Linha 204: Constrói o campo de busca
            Padding(
              padding: const EdgeInsets.all(16),
              child: CampoBusca(
                controller: _buscaController, // O controlador da busca
                onChanged: _buscarProdutos, // Quando digita, busca
                hintText: '🔍 Buscar produtos...', // Texto de exemplo
              ),
            ),
            
            // ============================================================
            // 📋 LISTA DE PRODUTOS — A "VITRINE"
            // ============================================================
            // Linha 213: A lista que ocupa o resto do espaço
            Expanded(
              child: _carregando && _todosProdutos.isEmpty // Se está carregando e vazio
                  ? const Center( // Mostra a roda de carregamento
                      child: CircularProgressIndicator(
                        color: BoxStockColors.papelaoMedio,
                      ),
                    )
                  : _produtosFiltrados.isEmpty // Se a lista filtrada está vazia
                      ? _buildEmptyState() // Mostra a mensagem "vazio"
                      : RefreshIndicator( // Permite "puxar para recarregar"
                          onRefresh: _carregarProdutosIniciais,
                          color: BoxStockColors.papelaoMedio,
                          child: ListView.builder( // Constrói a lista
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _produtosFiltrados.length + (_temMaisProdutos ? 1 : 0),
                            itemBuilder: (context, index) {
                              // Se for o último item e tem mais produtos...
                              if (index == _produtosFiltrados.length) {
                                return _buildLoadMoreButton(); // Mostra o botão "Carregar Mais"
                              }
                              final produto = _produtosFiltrados[index];
                              return _buildProdutoCard(produto); // Constrói o card do produto
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 📭 _BUILDEMPTYSTATE — "CONSTRÓI A TELA VAZIA"
  // ============================================================
  // Linha 244: Função que mostra a mensagem quando não tem produtos.
  // Analogia: É como "OLHAR A PRATELEIRA" e ver que está vazia.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Linha 249: O círculo com o ícone
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: BoxStockColors.fundoSecundario,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: BoxStockColors.papelaoEscuro.withOpacity(0.1),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Icon( // Ícone de estoque vazio ou busca vazia
              _termoBusca.isEmpty
                  ? Icons.inventory_2_outlined // Ícone de estoque vazio
                  : Icons.search_off, // Ícone de busca vazia
              size: 56,
              color: BoxStockColors.papelaoClaro,
            ),
          ),
          const SizedBox(height: 16),
          Text( // Mensagem principal
            _termoBusca.isEmpty
                ? '📦 Nenhum produto cadastrado'
                : '🔍 Nenhum produto encontrado para "$_termoBusca"',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BoxStockColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text( // Mensagem secundária
            _termoBusca.isEmpty
                ? 'Clique no botão + para adicionar'
                : 'Tente buscar com outro termo',
            style: TextStyle(
              fontSize: 14,
              color: BoxStockColors.textoPrincipal.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔘 _BUILDLOADMOREBUTTON — "CONSTRÓI O BOTÃO CARREGAR MAIS"
  // ============================================================
  // Linha 283: Função que constrói o botão "Carregar Mais".
  // Analogia: É como "PUXAR" mais produtos da prateleira.
  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _carregando // Se está carregando...
            ? const CircularProgressIndicator( // Mostra a roda
                color: BoxStockColors.papelaoMedio,
              )
            : ElevatedButton( // Senão, mostra o botão
                onPressed: _carregarMaisProdutos,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BoxStockColors.fundoSecundario,
                  foregroundColor: BoxStockColors.textoPrincipal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: BoxStockColors.papelaoClaro.withOpacity(0.3),
                    width: 2,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: Row( // Ícone + texto
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.arrow_downward, size: 18), // Ícone de seta para baixo
                    const SizedBox(width: 8),
                    const Text(
                      'Carregar Mais Produtos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ============================================================
  // 🃏 _BUILDPRODUTOCARD — "CONSTRÓI O CARD DE UM PRODUTO"
  // ============================================================
  // Linha 320: Função que constrói cada card de produto.
  // Analogia: É como cada "PRODUTO" na vitrine da loja.
  Widget _buildProdutoCard(Produto produto) {
    // Linha 321: Retorna um container com o card
    return Container(
      margin: const EdgeInsets.only(bottom: 14), // Espaço entre cards
      padding: const EdgeInsets.all(16), // Espaço interno
      decoration: BoxDecoration(
        color: BoxStockColors.campos, // Fundo creme
        borderRadius: BorderRadius.circular(16), // Bordas arredondadas
        boxShadow: [ // Sombra (efeito 3D)
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.08),
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
          color: BoxStockColors.papelaoClaro.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column( // Linha 344: Organiza em coluna
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // 📋 LINHA 1: NOME + STATUS
          // ============================================================
          Row(
            children: [
              Expanded( // Nome e código
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( // Nome do produto
                      produto.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: BoxStockColors.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text( // Código do produto
                      'Código: ${produto.codigo}',
                      style: TextStyle(
                        fontSize: 12,
                        color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              StatusEstoque( // O "semáforo" do produto
                status: produto.situacaoEstoque,
                quantidade: produto.quantidade,
                estoqueMinimo: produto.estoqueMinimo,
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          // ============================================================
          // 📋 LINHA 2: CATEGORIA + PREÇO
          // ============================================================
          Row(
            children: [
              Expanded( // Categoria
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: BoxStockColors.fundoSecundario,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '📂 ${produto.categoria}',
                    style: TextStyle(
                      fontSize: 12,
                      color: BoxStockColors.textoPrincipal.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container( // Preço
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: BoxStockColors.fundoSecundario,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '💰 ${produto.precoVendaFormatado}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.papelaoEscuro,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // ============================================================
          // 🔥 BOTÃO VER DETALHES
          // ============================================================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildActionButton( // O botão "Ver Detalhes"
                icon: Icons.visibility,
                label: 'Ver Detalhes',
                color: BoxStockColors.papelaoMedio,
                onPressed: () {
                  Navigator.push( // Vai para a tela de detalhes
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetalhesProdutoScreen(produto: produto),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔘 _BUILDACTIONBUTTON — "CONSTRÓI UM BOTÃO DE AÇÃO"
  // ============================================================
  // Linha 401: Função que constrói o botão "Ver Detalhes".
  // Analogia: É como um "BOTÃO" na vitrine que você aperta para ver mais.
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    // Linha 406: Retorna um botão com ícone e texto
    return SizedBox(
      width: 150,
      height: 38,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.12), // Fundo fraco
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide( // Borda com a cor
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          elevation: 0, // Sem sombra
        ),
        child: Row( // Ícone + texto + seta
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18), // Ícone (lupa)
            const SizedBox(width: 8),
            Text( // Texto "Ver Detalhes"
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon( // Seta para a direita
              Icons.arrow_forward,
              size: 16,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}