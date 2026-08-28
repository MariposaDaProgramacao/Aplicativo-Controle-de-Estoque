// ============================================================
// 📁 entrada_screen.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está no "ESTOQUE" da sua loja
//              e chegou uma nova remessa de produtos. Você precisa
//              registrar a ENTRADA desses produtos no sistema.
//              Essa tela é o "FORMULÁRIO DE ENTRADA" onde você
//              adiciona mais unidades ao estoque.
// 
// 🏠 Ele é como o "REGISTRO DE CHEGADA" do estoque:
//    - Você busca o produto que chegou
//    - Digita a quantidade que chegou
//    - (Opcional) Digita o preço unitário
//    - (Opcional) Escreve uma observação
//    - Clica em "Registrar Entrada" e o estoque aumenta!
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir a tela
import 'package:flutter/material.dart';
// Linha 2: Importa o Firebase Auth para pegar o usuário logado
import 'package:firebase_auth/firebase_auth.dart';
// Linha 3: Importa o Firestore para buscar produtos
import 'package:cloud_firestore/cloud_firestore.dart';
// Linha 4: Importa o serviço do Firestore para salvar dados
import '../../services/firestore_service.dart';
// Linha 5: Importa o modelo de Produto
import '../../models/produto_model.dart';
// Linha 6: Importa o modelo de Movimento (entrada/saída)
import '../../models/movimento_model.dart';
// Linha 7: Importa as cores do sistema
import '../../main.dart';

// ============================================================
// 🏠 CLASSE ENTRADASCREEN — A "TELA DE ENTRADA"
// ============================================================
// Linha 10: Define a classe EntradaScreen
// StatefulWidget = a tela pode mudar (busca, seleção, etc.)
class EntradaScreen extends StatefulWidget {
  // Linha 11: O produto que pode vir pré-selecionado
  // Se veio da listagem, já vem com o produto escolhido.
  final Produto? produto;

  // Linha 13: Construtor com chave e produto opcional
  const EntradaScreen({super.key, this.produto});

  // Linha 15-17: Cria o estado da tela
  @override
  State<EntradaScreen> createState() => _EntradaScreenState();
}

// ============================================================
// 🧠 _ENTRADASCREENSTATE — A "MEMÓRIA" DA TELA
// ============================================================
// Linha 21: Classe que guarda o estado da tela de entrada
class _EntradaScreenState extends State<EntradaScreen> {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" da tela
  // ============================================================
  
  // Linha 24: Instância do FirestoreService (o "entregador" dos dados)
  final FirestoreService _firestoreService = FirestoreService();
  
  // Linha 25: Chave do formulário (valida os campos)
  final _formKey = GlobalKey<FormState>();
  
  // Linhas 26-29: Controladores dos campos de texto
  // Analogia: São "CADERNOS" onde o usuário escreve as informações.
  final _quantidadeController = TextEditingController(); // Caderno da quantidade
  final _precoController = TextEditingController(); // Caderno do preço
  final _observacaoController = TextEditingController(); // Caderno da observação
  final _buscaController = TextEditingController(); // Caderno da busca
  
  // Linha 31: Controla se está carregando
  bool _isLoading = false;
  
  // Linha 32: Controla se está carregando a lista de produtos
  bool _carregandoProdutos = false;
  
  // Linha 33: Se tem mais produtos para carregar (paginação)
  bool _temMaisProdutos = true;
  
  // Linha 34: Lista de produtos encontrados na busca
  List<Produto> _produtosEncontrados = [];
  
  // Linha 35: O produto selecionado para a entrada
  Produto? _produtoSelecionado;
  
  // Linha 36: Se veio da listagem (produto já selecionado)
  bool _veioDaListagem = false;
  
  // Linha 38: Quantos produtos carregar por vez (paginação)
  static const int _limitePorPagina = 5;

  // ============================================================
  // 🚀 INITSTATE — "O QUE ACONTECE QUANDO A TELA ABRE"
  // ============================================================
  // Linhas 41-49: Função chamada quando a tela é aberta.
  // Analogia: É a "RECEPCIONISTA" que prepara a tela.
  @override
  void initState() {
    super.initState(); // Chama o initState da classe pai
    _veioDaListagem = widget.produto != null; // Veio com produto?
    _produtoSelecionado = widget.produto; // Guarda o produto

    if (_veioDaListagem) { // Se veio da listagem
      _buscaController.text = _produtoSelecionado!.nome; // Coloca o nome na busca
      _produtosEncontrados = [_produtoSelecionado!]; // Já mostra o produto
    } else { // Se não veio, carrega os produtos
      _carregarProdutosIniciais();
    }
  }

  // ============================================================
  // 🧹 DISPOSE — "LIMPA A MESA" QUANDO SAI
  // ============================================================
  // Linhas 51-57: Limpa os controladores quando a tela fecha.
  @override
  void dispose() {
    _quantidadeController.dispose();
    _precoController.dispose();
    _observacaoController.dispose();
    _buscaController.dispose();
    super.dispose();
  }

  // ============================================================
  // 📋 _CARREGARPRODUTOSINICIAIS — "CARREGA OS PRIMEIROS PRODUTOS"
  // ============================================================
  // Linhas 61: Função que carrega os primeiros 5 produtos.
  // Analogia: É como "ABRIR A PRATELEIRA" e pegar os 5 primeiros.
  Future<void> _carregarProdutosIniciais() async {
    // Linha 62-65: Mostra o carregamento
    setState(() {
      _carregandoProdutos = true;
      _produtosEncontrados = [];
      _temMaisProdutos = true;
    });

    try { // Tenta buscar os produtos
      // Linha 68: Busca os produtos (termo vazio = todos)
      final produtos = await _buscarProdutos('');
      // Linha 69-73: Atualiza a lista
      setState(() {
        _produtosEncontrados = produtos;
        _carregandoProdutos = false;
        _temMaisProdutos = produtos.length >= _limitePorPagina;
      });
    } catch (e) { // Se deu erro
      setState(() {
        _carregandoProdutos = false;
      });
      _showErrorDialog('Erro ao carregar produtos: $e');
    }
  }

  // ============================================================
  // 🔍 _BUSCARPRODUTOS — "BUSCA PRODUTOS NO FIRESTORE"
  // ============================================================
  // Linha 80: Função que busca produtos por nome.
  // Analogia: É como "PROCURAR" um produto na prateleira.
  Future<List<Produto>> _buscarProdutos(String termo) async {
    try {
      // Linha 82: Pega o usuário logado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return []; // Se não tem usuário, retorna vazio

      // Linha 85: A variável que vai guardar os resultados
      QuerySnapshot snapshot;

      // Linha 87: Se o termo de busca está vazio...
      if (termo.isEmpty) {
        // Linha 88-92: Busca todos os produtos (limitado a 5)
        snapshot = await FirebaseFirestore.instance
            .collection('produtos') // Vai na coleção "produtos"
            .where('usuarioId', isEqualTo: user.uid) // Só do usuário
            .orderBy('nome') // Ordena por nome
            .limit(_limitePorPagina) // Pega só 5
            .get(); // Executa a busca
      } else {
        // Linha 94-98: Se tem termo de busca, faz uma busca com filtro
        // Analogia: É como "PROCURAR" um produto pelo nome.
        final termoLower = termo.toLowerCase(); // Tudo minúsculo
        final termoUpper = termoLower.substring(0, termoLower.length - 1) +
            String.fromCharCode(termoLower.codeUnitAt(termoLower.length - 1) + 1);

        // Linha 100-107: Busca produtos com nome parecido
        snapshot = await FirebaseFirestore.instance
            .collection('produtos')
            .where('usuarioId', isEqualTo: user.uid)
            .where('nome', isGreaterThanOrEqualTo: termoLower)
            .where('nome', isLessThan: termoUpper)
            .orderBy('nome')
            .limit(_limitePorPagina)
            .get();
      }

      // Linha 110-116: Converte os resultados em lista de Produto
      return snapshot.docs
          .where((doc) => doc.data() != null) // Ignora dados nulos
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Produto.fromMap(doc.id, data); // Converte para Produto
          })
          .toList();
    } catch (e) { // Se deu erro
      throw Exception('Erro ao buscar produtos: $e');
    }
  }

  // ============================================================
  // 📥 _CARREGARMAISPRODUTOS — "CARREGA MAIS PRODUTOS"
  // ============================================================
  // Linha 121: Função que carrega mais 5 produtos.
  // Analogia: É como "PUXAR" mais produtos da prateleira.
  Future<void> _carregarMaisProdutos() async {
    // Linha 122: Se já está carregando ou não tem mais, para aqui.
    if (_carregandoProdutos || !_temMaisProdutos) return;

    // Linha 124-126: Mostra o carregamento
    setState(() {
      _carregandoProdutos = true;
    });

    try {
      // Linha 129: Pega o usuário logado
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Linha 132: Pega o último produto da lista
      final ultimoProduto = _produtosEncontrados.last;

      // Linha 134-140: Busca produtos a partir do último
      // Analogia: É como "COMEÇAR DE ONDE PAROU".
      final snapshot = await FirebaseFirestore.instance
          .collection('produtos')
          .where('usuarioId', isEqualTo: user.uid)
          .orderBy('nome')
          .startAfter([ultimoProduto.nome]) // Começa depois do último
          .limit(_limitePorPagina) // Pega mais 5
          .get();

      // Linha 143-149: Converte os resultados
      final novosProdutos = snapshot.docs
          .where((doc) => doc.data() != null)
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Produto.fromMap(doc.id, data);
          })
          .toList();

      // Linha 151-156: Adiciona os novos à lista
      setState(() {
        _produtosEncontrados.addAll(novosProdutos);
        _carregandoProdutos = false;
        _temMaisProdutos = novosProdutos.length >= _limitePorPagina;
      });
    } catch (e) { // Se deu erro
      setState(() {
        _carregandoProdutos = false;
      });
      _showErrorDialog('Erro ao carregar mais produtos: $e');
    }
  }

  // ============================================================
  // 📝 _REGISTRARENTRADA — "REGISTRA A ENTRADA"
  // ============================================================
  // Linha 164: Função que registra a entrada.
  // Analogia: É o "ATENDENTE" que confirma a chegada do produto.
  Future<void> _registrarEntrada() async {
    // Linha 165: Valida o formulário
    if (!_formKey.currentState!.validate()) return;
    // Linha 166: Verifica se tem produto selecionado
    if (_produtoSelecionado == null) {
      _showErrorDialog('Selecione um produto');
      return;
    }

    // Linha 170: Mostra o carregamento
    setState(() => _isLoading = true);

    try {
      // Linha 173: Pega a quantidade digitada
      final quantidade = double.parse(_quantidadeController.text);
      // Linha 174: Calcula a nova quantidade
      final novaQuantidade = _produtoSelecionado!.quantidade + quantidade;

      // Linha 176-178: Atualiza a quantidade no Firestore
      await _firestoreService.atualizarQuantidade(
        _produtoSelecionado!.id!,
        novaQuantidade,
      );

      // Linha 181: Pega o usuário logado
      final user = FirebaseAuth.instance.currentUser!;
      
      // Linha 182-193: Cria o registro de movimentação
      // Analogia: É como "ESCREVER NO DIÁRIO" que algo entrou.
      final movimento = Movimento(
        produtoId: _produtoSelecionado!.id!,
        produtoNome: _produtoSelecionado!.nome,
        tipo: 'entrada',
        quantidade: quantidade,
        precoUnitario: double.tryParse(_precoController.text),
        observacao: _observacaoController.text.isNotEmpty
            ? _observacaoController.text
            : null,
        usuarioId: user.uid,
        usuarioEmail: user.email ?? '',
        createdAt: DateTime.now(),
      );
      // Linha 195: Salva a movimentação
      await _firestoreService.criarMovimento(movimento);

      // Linha 197-198: Verifica se a tela ainda está aberta
      if (!mounted) return;

      // Linha 200-204: Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ +${quantidade.toStringAsFixed(0)} unidades de "${_produtoSelecionado!.nome}" registradas!'),
          backgroundColor: BoxStockColors.sucesso,
          duration: const Duration(seconds: 3),
        ),
      );

      // Linha 206-211: Limpa os campos
      _quantidadeController.clear();
      _precoController.clear();
      _observacaoController.clear();
      setState(() {
        _produtoSelecionado = null;
        _buscaController.clear();
        _veioDaListagem = false;
      });
      // Linha 212: Recarrega a lista de produtos
      _carregarProdutosIniciais();

    } catch (e) { // Se deu erro
      _showErrorDialog('Erro ao registrar entrada: $e');
    } finally { // Sempre acontece
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // ❌ _SHOWERRORDIALOG — "MOSTRA O ERRO"
  // ============================================================
  // Linha 220: Função que mostra um diálogo de erro.
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
  // 🏗️ BUILD — "CONSTRÓI A TELA DE ENTRADA"
  // ============================================================
  // Linha 240: A função que constrói toda a tela.
  @override
  Widget build(BuildContext context) {
    // Linha 241: Retorna um Scaffold (a estrutura básica)
    return Scaffold(
      backgroundColor: BoxStockColors.fundoPrincipal,
      
      // ============================================================
      // 📱 APPBAR — A "BARRA SUPERIOR"
      // ============================================================
      appBar: AppBar(
        title: const Text(
          '➕ Registrar Entrada',
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
      
      // ============================================================
      // 📄 BODY — O "CORPO" DA TELA
      // ============================================================
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Permite rolar
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ============================================================
                // ✅ PRODUTO SELECIONADO (se veio da listagem)
                // ============================================================
                if (_veioDaListagem) _buildProdutoSelecionadoCard(),
                const SizedBox(height: 12),

                // ============================================================
                // 🔍 CAMPO DE BUSCA
                // ============================================================
                _buildBuscaField(),
                const SizedBox(height: 12),

                // ============================================================
                // 📋 LISTA DE PRODUTOS
                // ============================================================
                _buildListaProdutos(),
                const SizedBox(height: 16),

                // ============================================================
                // ➖ DIVISOR
                // ============================================================
                const Divider(color: BoxStockColors.papelaoClaro),
                const SizedBox(height: 16),

                // ============================================================
                // 🔢 QUANTIDADE
                // ============================================================
                _buildQuantidadeField(),
                const SizedBox(height: 16),

                // ============================================================
                // 💰 PREÇO UNITÁRIO
                // ============================================================
                _buildPrecoField(),
                const SizedBox(height: 16),

                // ============================================================
                // 📝 OBSERVAÇÃO
                // ============================================================
                _buildObservacaoField(),
                const SizedBox(height: 24),

                // ============================================================
                // 🔘 BOTÃO REGISTRAR
                // ============================================================
                _buildRegistrarButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ✅ _BUILDPRODUTOSELECIONADOCARD — "CONSTRÓI O CARD DO PRODUTO SELECIONADO"
  // ============================================================
  // Linha 329: Função que mostra o produto já selecionado.
  // Analogia: É como uma "ETIQUETA" verde dizendo qual produto você escolheu.
  Widget _buildProdutoSelecionadoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BoxStockColors.sucesso.withOpacity(0.08),
            BoxStockColors.sucesso.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BoxStockColors.sucesso.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.sucesso.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícone de check
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: BoxStockColors.sucesso.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: BoxStockColors.sucesso,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          // Informações do produto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produto Selecionado',
                  style: TextStyle(
                    fontSize: 12,
                    color: BoxStockColors.sucesso,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _produtoSelecionado!.nome,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
              ],
            ),
          ),
          // Estoque atual
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: BoxStockColors.fundoSecundario,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BoxStockColors.papelaoClaro.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '📦 Estoque',
                  style: TextStyle(
                    fontSize: 10,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                  ),
                ),
                Text(
                  '${_produtoSelecionado!.quantidade.toStringAsFixed(0)} und.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.papelaoEscuro,
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
  // 🔍 _BUILDBUSCAFIELD — "CONSTRÓI O CAMPO DE BUSCA"
  // ============================================================
  // Linha 399: Função que constrói o campo de busca.
  // Analogia: É como a "LUPA" para procurar produtos.
  Widget _buildBuscaField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextField(
        controller: _buscaController,
        onChanged: (value) {
          if (!_veioDaListagem) {
            _buscarProdutos(value).then((produtos) {
              setState(() {
                _produtosEncontrados = produtos;
                _temMaisProdutos = produtos.length >= _limitePorPagina;
                if (_produtosEncontrados.isNotEmpty && _produtoSelecionado == null) {
                  _produtoSelecionado = _produtosEncontrados.first;
                }
              });
            });
          }
        },
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: InputDecoration(
          hintText: _veioDaListagem
              ? '🔍 Produto já selecionado'
              : '🔍 Digite o nome do produto...',
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: BoxStockColors.papelaoMedio,
          ),
          suffixIcon: _veioDaListagem
              ? IconButton(
                  icon: Icon(
                    Icons.close,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.4),
                  ),
                  onPressed: () {
                    setState(() {
                      _veioDaListagem = false;
                      _produtoSelecionado = null;
                      _buscaController.clear();
                      _carregarProdutosIniciais();
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        enabled: !_veioDaListagem,
      ),
    );
  }

  // ============================================================
  // 📋 _BUILDLISTAPRODUTOS — "CONSTRÓI A LISTA DE PRODUTOS"
  // ============================================================
  // Linha 448: Função que constrói a lista de produtos encontrados.
  Widget _buildListaProdutos() {
    // Linha 449: Se veio da listagem, não mostra a lista
    if (_veioDaListagem) {
      return const SizedBox.shrink();
    }

    // Linha 453: Se está carregando, mostra a roda
    if (_carregandoProdutos && _produtosEncontrados.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(
            color: BoxStockColors.papelaoMedio,
          ),
        ),
      );
    }

    // Linha 463: Se não encontrou produtos, mostra mensagem
    if (_produtosEncontrados.isEmpty && _buscaController.text.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BoxStockColors.campos,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: BoxStockColors.papelaoClaro.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.search_off,
                size: 40,
                color: BoxStockColors.papelaoClaro,
              ),
              const SizedBox(height: 8),
              Text(
                'Nenhum produto encontrado',
                style: TextStyle(
                  color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Linha 491: Se não digitou nada, mostra a mensagem inicial
    if (_produtosEncontrados.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: BoxStockColors.campos,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: BoxStockColors.papelaoClaro.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.search,
                size: 40,
                color: BoxStockColors.papelaoClaro,
              ),
              SizedBox(height: 8),
              Text(
                '🔍 Digite o nome do produto',
                style: TextStyle(
                  color: BoxStockColors.textoPrincipal,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Linha 519: Mostra a lista de produtos
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(maxHeight: 200),
          decoration: BoxDecoration(
            color: BoxStockColors.campos,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: BoxStockColors.papelaoClaro.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _produtosEncontrados.length,
            itemBuilder: (context, index) {
              final produto = _produtosEncontrados[index];
              final isSelected = _produtoSelecionado?.id == produto.id;

              return InkWell(
                onTap: () {
                  setState(() {
                    _produtoSelecionado = produto;
                    _buscaController.text = produto.nome;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? BoxStockColors.fundoSecundario
                        : Colors.transparent,
                    border: Border(
                      bottom: BorderSide(
                        color: BoxStockColors.papelaoClaro.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Círculo de seleção
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? BoxStockColors.sucesso
                              : BoxStockColors.papelaoClaro.withOpacity(0.3),
                          border: Border.all(
                            color: isSelected
                                ? BoxStockColors.sucesso
                                : BoxStockColors.papelaoClaro.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      // Nome e estoque
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              produto.nome,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: BoxStockColors.textoPrincipal,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '📦 Estoque: ${produto.quantidade.toStringAsFixed(0)} unidades',
                              style: TextStyle(
                                fontSize: 12,
                                color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Preço
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BoxStockColors.fundoSecundario,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '💰 ${produto.precoVendaFormatado}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: BoxStockColors.papelaoEscuro,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Botão "Carregar Mais"
        if (_temMaisProdutos)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _carregandoProdutos ? null : _carregarMaisProdutos,
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
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: _carregandoProdutos
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: BoxStockColors.papelaoMedio,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.arrow_downward, size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Carregar Mais',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // 🔢 _BUILDQUANTIDADEFIELD — "CONSTRÓI O CAMPO QUANTIDADE"
  // ============================================================
  Widget _buildQuantidadeField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _quantidadeController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Quantidade *',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.numbers,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Digite a quantidade';
          }
          final qtd = double.tryParse(value);
          if (qtd == null || qtd <= 0) {
            return 'Digite uma quantidade válida';
          }
          return null;
        },
      ),
    );
  }

  // ============================================================
  // 💰 _BUILDPRECOFIELD — "CONSTRÓI O CAMPO PREÇO UNITÁRIO"
  // ============================================================
  Widget _buildPrecoField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _precoController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Preço unitário (opcional)',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.monetization_on,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  // ============================================================
  // 📝 _BUILDOBSERVACAOFIELD — "CONSTRÓI O CAMPO OBSERVAÇÃO"
  // ============================================================
  Widget _buildObservacaoField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: _observacaoController,
        maxLines: 2,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 16),
        decoration: const InputDecoration(
          labelText: 'Observação (opcional)',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.comment,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  // ============================================================
  // 🔘 _BUILDREGISTRARBUTTON — "CONSTRÓI O BOTÃO REGISTRAR"
  // ============================================================
  Widget _buildRegistrarButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _registrarEntrada,
        style: ElevatedButton.styleFrom(
          backgroundColor: BoxStockColors.sucesso,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 6,
          shadowColor: BoxStockColors.sucesso.withOpacity(0.3),
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
                '✅ Registrar Entrada',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}