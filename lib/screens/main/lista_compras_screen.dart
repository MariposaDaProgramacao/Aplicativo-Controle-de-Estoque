// ============================================================
// 📁 lista_compras_screen.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está na "COZINHA" da sua casa
//              e percebe que alguns ingredientes estão acabando.
//              Você faz uma "LISTA DE COMPRAS" para não esquecer
//              o que precisa comprar no supermercado.
//              Essa tela é a "LISTA DE COMPRAS" digital do BoxStock!
// 
// 🏠 Ele é como o "CARRINHO DE COMPRAS" do seu estoque:
//    - Mostra automaticamente produtos com estoque baixo
//    - Sugere quantas unidades comprar
//    - Você pode ajustar a quantidade
//    - Marca os itens já comprados
//    - Compartilha a lista via WhatsApp
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir a tela
import 'package:flutter/material.dart';
// Linha 2: Importa o Firestore para ouvir mudanças em tempo real
import 'package:cloud_firestore/cloud_firestore.dart';
// Linha 3: Importa o pacote para compartilhar a lista (Share Plus)
// Analogia: É como o "CORREIO" que leva sua lista para outras pessoas.
import 'package:share_plus/share_plus.dart';
// Linha 4: Importa o serviço do Firestore (o "entregador" dos dados)
import '../../services/firestore_service.dart';
// Linha 5: Importa o modelo de Lista de Compras (o "molde" do item)
import '../../models/lista_compra_model.dart';
// Linha 6: Importa as cores do sistema
import '../../main.dart';

// ============================================================
// 🏠 CLASSE LISTACOMPRASSCREEN — A "TELA DA LISTA DE COMPRAS"
// ============================================================
// Linha 9: Define a classe ListaComprasScreen
// StatefulWidget = a tela pode mudar (quantidades, comprados, etc.)
class ListaComprasScreen extends StatefulWidget {
  const ListaComprasScreen({super.key});

  // Linha 13-15: Cria o estado da tela
  @override
  State<ListaComprasScreen> createState() => _ListaComprasScreenState();
}

// ============================================================
// 🧠 _LISTACOMPRASSCREENSTATE — A "MEMÓRIA" DA TELA
// ============================================================
// Linha 19: Classe que guarda o estado da tela de lista de compras
class _ListaComprasScreenState extends State<ListaComprasScreen> {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" da tela
  // ============================================================
  
  // Linha 22: Instância do FirestoreService (o "entregador" dos dados)
  final FirestoreService _firestoreService = FirestoreService();
  
  // Linha 23: Controla se está carregando
  // true = mostra a roda de carregamento
  bool _isLoading = false;
  
  // Linha 24: Um "DICIONÁRIO" que guarda os controladores de quantidade.
  // Analogia: É como um "CADERNO" onde cada produto tem uma página
  //           com a quantidade que você quer comprar.
  // A chave é o ID do produto, o valor é o controlador (que guarda o texto).
  final Map<String, TextEditingController> _quantidadeControllers = {};

  // ============================================================
  // 🚀 INITSTATE — "O QUE ACONTECE QUANDO A TELA ABRE"
  // ============================================================
  // Linhas 27-30: Função chamada quando a tela é aberta.
  // Analogia: É a "RECEPCIONISTA" que já prepara a lista de compras
  //           antes do usuário chegar.
  @override
  void initState() {
    super.initState(); // Chama o initState da classe pai
    _verificarLista(); // Verifica se tem produtos com estoque baixo
  }

  // ============================================================
  // 🧹 DISPOSE — "LIMPA A MESA" QUANDO SAI
  // ============================================================
  // Linhas 32-36: Quando a tela é fechada, limpamos os controladores.
  // Isso libera memória do celular.
  // Analogia: É como "JOGAR FORA" os rascunhos quando você sai da cozinha.
  @override
  void dispose() {
    // Para cada controlador no mapa, chama o dispose
    for (final controller in _quantidadeControllers.values) {
      controller.dispose(); // Libera a memória
    }
    super.dispose(); // Chama o dispose da classe pai
  }

  // ============================================================
  // 🔍 _VERIFICARLISTA — "VERIFICA A LISTA DE COMPRAS"
  // ============================================================
  // Linha 39: Função que verifica se algum produto precisa ser comprado.
  // Analogia: É como "OLHAR A GELADEIRA" e ver o que está faltando.
  Future<void> _verificarLista() async {
    // Linha 40: Mostra o "carregando..."
    setState(() => _isLoading = true);
    
    try { // Tenta fazer algo que pode dar erro
      // Linha 42: Chama o Firestore para verificar a lista de compras
      // Analogia: O "ENTREGADOR" vai até o estoque e verifica
      //           quais produtos estão abaixo do mínimo.
      await _firestoreService.verificarListaCompras();
      
      // Linha 44: Verifica se a tela ainda está aberta
      if (!mounted) return;
      
      // Linha 46-51: Mostra uma mensagem de sucesso
      // Analogia: A recepcionista diz "Lista atualizada!"
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Lista de compras atualizada!'),
          backgroundColor: BoxStockColors.sucesso,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) { // Se deu erro
      if (!mounted) return;
      // Linha 54-59: Mostra uma mensagem de erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao verificar: $e'),
          backgroundColor: BoxStockColors.alerta,
        ),
      );
    } finally { // Sempre acontece, mesmo se der erro
      if (mounted) setState(() => _isLoading = false); // Desativa o carregamento
    }
  }

  // ============================================================
  // 🗑️ _LIMPARCOMPRADOS — "LIMPA OS ITENS COMPRADOS"
  // ============================================================
  // Linha 67: Função que remove todos os itens marcados como "comprados".
  // Analogia: É como "JOGAR FORA" os itens que você já comprou.
  void _limparComprados() {
    // Linha 68: Mostra um diálogo de confirmação
    // Analogia: A recepcionista pergunta "Tem certeza que quer limpar?"
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpar itens comprados?'),
        content: const Text(
          'Isso removerá todos os itens marcados como comprados da lista.',
          style: TextStyle(color: BoxStockColors.textoPrincipal),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [ // Linha 82: Os botões
          TextButton( // Botão "Cancelar"
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton( // Botão "Limpar"
            onPressed: () async {
              Navigator.pop(context); // Fecha o diálogo
              try {
                // Linha 91: Chama o Firestore para limpar os comprados
                await _firestoreService.limparItensComprados();
                if (!mounted) return;
                // Linha 94-98: Mostra mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Itens comprados removidos!'),
                    backgroundColor: BoxStockColors.sucesso,
                  ),
                );
              } catch (e) { // Se deu erro
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erro ao limpar: $e'),
                    backgroundColor: BoxStockColors.alerta,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BoxStockColors.alerta,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📤 _COMPARTILHARLISTA — "COMPARTILHA A LISTA DE COMPRAS"
  // ============================================================
  // Linha 116: Função que compartilha a lista via WhatsApp/outros apps.
  // Analogia: É como "MANDAR UMA MENSAGEM" para alguém com a lista de compras.
  Future<void> _compartilharLista() async {
    try {
      // Linha 118: Busca todos os itens da lista de compras
      // .first = pega a primeira lista (em tempo real)
      final itens = await _firestoreService.listarListaCompras().first;
      
      // Linha 119: Filtra apenas os itens PENDENTES (não comprados)
      // .where = pega só os que têm comprado == false
      final itensPendentes = itens.where((i) => !i.comprado).toList();

      // Linha 121: Se não tem itens pendentes...
      if (itensPendentes.isEmpty) {
        // Linha 122-126: Mostra mensagem "Nenhum item pendente"
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('📭 Nenhum item pendente para comprar!'),
            backgroundColor: BoxStockColors.informacao,
          ),
        );
        return; // Para aqui
      }

      // Linha 130: Gera o texto da lista com as quantidades
      final texto = _gerarTextoListaComQuantidades(itensPendentes);
      
      // Linha 131-134: Compartilha o texto
      // Analogia: O "CORREIO" envia a mensagem para o WhatsApp.
      await Share.share(
        texto,
        subject: '🛒 Lista de Compras - BoxStock',
      );
    } catch (e) { // Se deu erro
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao compartilhar: $e'),
          backgroundColor: BoxStockColors.alerta,
        ),
      );
    }
  }

  // ============================================================
  // 📝 _GERARTEXTOLISTACOMQUANTIDADES — "CRIA O TEXTO DA LISTA"
  // ============================================================
  // Linha 144: Função que gera o texto formatado da lista de compras.
  // Analogia: É como "ESCREVER A LISTA" em um papel bonito.
  String _gerarTextoListaComQuantidades(List<ListaCompra> itens) {
    // Linha 145: Cria um "buffer" (um "espaço" para montar o texto)
    // Analogia: É como um "RASCUNHO" onde você vai escrevendo.
    final buffer = StringBuffer();
    
    // Linha 146-149: CABEÇALHO da lista
    buffer.writeln('🛒 LISTA DE COMPRAS - BoxStock'); // Título
    buffer.writeln('=' * 40); // Linha separadora (40 iguais)
    buffer.writeln('📅 ${DateTime.now().toLocal().toString().split(' ')[0]}'); // Data de hoje
    buffer.writeln(''); // Linha vazia

    // Linha 151: Para cada item na lista...
    for (var i = 0; i < itens.length; i++) {
      final item = itens[i]; // Pega o item atual
      
      // Linha 153: Pega o controlador de quantidade deste item
      final controller = _quantidadeControllers[item.id!];
      
      // Linha 154-156: Pega a quantidade digitada (ou a quantidade faltante)
      // Se o controlador existe e tem texto, usa ele; senão, usa a quantidade faltante
      final quantidadeCompra = controller != null && controller.text.isNotEmpty
          ? double.tryParse(controller.text) ?? item.quantidadeFaltante
          : item.quantidadeFaltante;

      // Linha 158-162: ESCREVE AS INFORMAÇÕES DO ITEM
      buffer.writeln('${i + 1}. ${item.produtoNome}'); // Número e nome do produto
      buffer.writeln('   📦 Estoque atual: ${item.quantidadeAtual.toStringAsFixed(0)} und.'); // Estoque atual
      buffer.writeln('   🛒 Comprar: ${quantidadeCompra.toStringAsFixed(0)} und.'); // Quantidade a comprar
      buffer.writeln('   📂 ${item.categoria}'); // Categoria
      buffer.writeln(''); // Linha vazia
    }

    // Linha 167-168: RODAPÉ da lista
    buffer.writeln('=' * 40); // Linha separadora
    buffer.writeln('📦 BoxStock - Organização que cabe no seu bolso'); // Mensagem final
    
    // Linha 169: Retorna o texto completo
    return buffer.toString();
  }

  // ============================================================
  // 📝 _GETQUANTIDADECONTROLLER — "PEGA O CONTROLADOR DE QUANTIDADE"
  // ============================================================
  // Linha 173: Função que pega o controlador de um item.
  // Analogia: É como "ABRIR O CADERNO" de um produto específico.
  // Se não existir, cria um novo.
  TextEditingController _getQuantidadeController(ListaCompra item) {
    final id = item.id!; // Pega o ID do item
    // Linha 176: Se o controlador não existe ainda...
    if (!_quantidadeControllers.containsKey(id)) {
      // Linha 177: Cria um novo controlador com a quantidade faltante
      final controller = TextEditingController(
        text: item.quantidadeFaltante.toStringAsFixed(0),
      );
      // Linha 180: Guarda no mapa (o "caderno")
      _quantidadeControllers[id] = controller;
    }
    // Linha 182: Retorna o controlador
    return _quantidadeControllers[id]!;
  }

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI A TELA DA LISTA DE COMPRAS"
  // ============================================================
  // Linha 186: A função que constrói toda a tela.
  @override
  Widget build(BuildContext context) {
    // Linha 187: Retorna um Scaffold (a estrutura básica da tela)
    return Scaffold(
      // Linha 188: Define a cor de fundo.
      backgroundColor: BoxStockColors.fundoPrincipal,
      
      // ============================================================
      // 📱 APPBAR — A "BARRA SUPERIOR"
      // ============================================================
      // Linha 190: A barra que fica no topo.
      appBar: AppBar(
        title: const Text(
          '🛒 Lista de Compras', // Título com emoji de carrinho
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: BoxStockColors.papelaoMedio,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [ // Linha 200: Botões na barra superior
          // ============================================================
          // 🔘 BOTÃO COMPARTILHAR — O "BOTÃO DE ENVIAR"
          // ============================================================
          Container(
            margin: const EdgeInsets.only(right: 4),
            child: ElevatedButton.icon(
              onPressed: _compartilharLista, // Quando clica, compartilha
              icon: const Icon(Icons.share, color: Colors.white, size: 18),
              label: const Text(
                'Compartilhar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: BoxStockColors.acaoPrincipal, // Cor laranja
                foregroundColor: Colors.white,
                elevation: 4,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          
          // ============================================================
          // 🔄 BOTÃO ATUALIZAR — O "BOTÃO DE RECARREGAR"
          // ============================================================
          IconButton(
            icon: _isLoading // Se está carregando...
                ? const SizedBox( // Mostra uma roda de carregamento
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white), // Senão, mostra o ícone
            onPressed: _isLoading ? null : _verificarLista, // Desativa se está carregando
            tooltip: 'Verificar agora',
          ),
          
          // ============================================================
          // 🗑️ BOTÃO LIMPAR — O "BOTÃO DE LIMPAR"
          // ============================================================
          IconButton(
            icon: const Icon(Icons.cleaning_services, color: Colors.white),
            onPressed: _limparComprados, // Quando clica, limpa os comprados
            tooltip: 'Limpar comprados',
          ),
        ],
        // Linha 251-259: A "fita adesiva" decorativa
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
      body: _buildListaCompras(), // Constrói a lista de compras
    );
  }

  // ============================================================
  // 📋 _BUILDLISTACOMPRAS — "CONSTRÓI A LISTA DE COMPRAS"
  // ============================================================
  // Linha 269: Função que constrói a lista de compras.
  // Analogia: É como "MONTAR A LISTA" na geladeira.
  Widget _buildListaCompras() {
    // Linha 270: StreamBuilder = escuta mudanças em tempo real
    // Analogia: É como um "RÁDIO" que fica ligado ouvindo novidades.
    return StreamBuilder<List<ListaCompra>>(
      stream: _firestoreService.listarListaCompras(), // A fonte dos dados
      builder: (context, snapshot) { // Linha 272: Constrói a lista
        // ============================================================
        // ❌ SE DEU ERRO
        // ============================================================
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: BoxStockColors.alerta,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erro ao carregar lista',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    snapshot.error.toString(),
                    style: TextStyle(
                      color: BoxStockColors.textoPrincipal,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _verificarLista,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: BoxStockColors.papelaoMedio,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Verificar agora'),
                ),
              ],
            ),
          );
        }

        // ============================================================
        // ⏳ SE ESTÁ CARREGANDO
        // ============================================================
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: BoxStockColors.papelaoMedio,
            ),
          );
        }

        // ============================================================
        // 📋 LISTA CARREGADA
        // ============================================================
        final itens = snapshot.data ?? []; // Pega os dados
        // Linha 321: Separa os itens PENDENTES e COMPRADOS
        final itensPendentes = itens.where((i) => !i.comprado).toList();
        final itensComprados = itens.where((i) => i.comprado).toList();

        // ============================================================
        // 📭 SE NÃO TEM ITENS
        // ============================================================
        if (itens.isEmpty) {
          return _buildEmptyState(); // Mostra a mensagem "Lista vazia"
        }

        // ============================================================
        // 📋 LISTA COM ITENS
        // ============================================================
        return SingleChildScrollView( // Permite rolar
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================================================
              // 📊 RESUMO (Pendentes e Comprados)
              // ============================================================
              _buildResumo(itensPendentes.length, itensComprados.length),
              const SizedBox(height: 16),

              // ============================================================
              // 📋 ITENS PENDENTES (Para Comprar)
              // ============================================================
              if (itensPendentes.isNotEmpty) ...[
                const Text(
                  '📋 Para Comprar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 8),
                ...itensPendentes.map((item) => _buildItemCard(item)), // Cada item
                const SizedBox(height: 16),
              ],

              // ============================================================
              // ✅ ITENS COMPRADOS (Já Comprados)
              // ============================================================
              if (itensComprados.isNotEmpty) ...[
                const Text(
                  '✅ Já Comprados',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.sucesso,
                  ),
                ),
                const SizedBox(height: 8),
                ...itensComprados.map((item) => _buildItemCard(item)), // Cada item
              ],
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // 📭 _BUILDEMPTYSTATE — "CONSTRÓI A TELA VAZIA"
  // ============================================================
  // Linha 374: Função que mostra a mensagem quando a lista está vazia.
  // Analogia: É como "ABRIR A GELADEIRA" e ver que está vazia.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 56,
              color: BoxStockColors.papelaoClaro,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '🛒 Lista de compras vazia',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: BoxStockColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Produtos com estoque baixo aparecerão aqui',
            style: TextStyle(
              color: BoxStockColors.textoPrincipal,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _verificarLista,
            icon: const Icon(Icons.refresh),
            style: ElevatedButton.styleFrom(
              backgroundColor: BoxStockColors.papelaoMedio,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            label: const Text('Verificar agora'),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📊 _BUILDRESUMO — "CONSTRÓI O RESUMO"
  // ============================================================
  // Linha 410: Função que mostra o resumo (Pendentes e Comprados).
  // Analogia: É como um "BILHETE" que mostra quantos itens faltam.
  Widget _buildResumo(int pendentes, int comprados) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumoItem(
            '🛒 Pendentes',
            pendentes.toString(),
            BoxStockColors.acaoPrincipal,
          ),
          Container(
            width: 1,
            height: 40,
            color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          ),
          _buildResumoItem(
            '✅ Comprados',
            comprados.toString(),
            BoxStockColors.sucesso,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📊 _BUILDRESUMOITEM — "CONSTRÓI UM ITEM DO RESUMO"
  // ============================================================
  Widget _buildResumoItem(String label, String valor, Color cor) {
    return Column(
      children: [
        Text( // O número (ex: "3")
          valor,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: cor,
          ),
        ),
        Text( // O rótulo (ex: "Pendentes")
          label,
          style: TextStyle(
            fontSize: 12,
            color: BoxStockColors.textoPrincipal,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 🃏 _BUILDEMPTYCARD — "CONSTRÓI O CARD DE UM ITEM"
  // ============================================================
  // Linha 464: Função que constrói cada card de item.
  // Analogia: É como cada "ITEM" na sua lista de compras.
  Widget _buildItemCard(ListaCompra item) {
    // Linha 465-468: Pega as informações do item
    final isComprado = item.comprado; // Já foi comprado?
    final quantidadeAtual = item.quantidadeAtual.toStringAsFixed(0); // Quantidade atual
    final controller = _getQuantidadeController(item); // Controlador da quantidade
    final faltante = item.quantidadeFaltante.toStringAsFixed(0); // Quantidade faltante

    // Linha 470: Retorna um container com o card
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComprado
            ? BoxStockColors.sucesso.withOpacity(0.08) // Fundo verde claro se comprado
            : BoxStockColors.campos, // Fundo creme se pendente
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isComprado
              ? BoxStockColors.sucesso.withOpacity(0.3) // Borda verde se comprado
              : BoxStockColors.papelaoClaro.withOpacity(0.2), // Borda clara se pendente
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column( // Linha 488: Organiza em coluna
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============================================================
          // 📋 LINHA 1: CHECKBOX + NOME + REMOVER
          // ============================================================
          Row(
            children: [
              // ============================================================
              // ☑️ CHECKBOX (CÍRCULO DE SELEÇÃO)
              // ============================================================
              GestureDetector(
                onTap: () {
                  if (!isComprado) { // Só pode marcar se não estiver comprado
                    _marcarComoComprado(item); // Marca como comprado
                  }
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isComprado
                        ? BoxStockColors.sucesso // Verde se comprado
                        : BoxStockColors.papelaoClaro, // Claro se pendente
                    border: Border.all(
                      color: isComprado
                          ? BoxStockColors.sucesso
                          : BoxStockColors.papelaoClaro,
                      width: 2,
                    ),
                  ),
                  child: isComprado
                      ? const Icon( // Se comprado, mostra um CHECK
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null, // Se pendente, mostra vazio
                ),
              ),
              const SizedBox(width: 12), // Espaço
              
              // ============================================================
              // 📝 NOME DO PRODUTO
              // ============================================================
              Expanded(
                child: Text(
                  item.produtoNome,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isComprado
                        ? BoxStockColors.textoPrincipal
                        : BoxStockColors.textoPrincipal,
                    decoration: isComprado
                        ? TextDecoration.lineThrough // Se comprado, risca o texto
                        : TextDecoration.none, // Se pendente, normal
                  ),
                ),
              ),
              
              // ============================================================
              // ❌ BOTÃO REMOVER
              // ============================================================
              IconButton(
                icon: Icon(
                  Icons.close,
                  size: 20,
                  color: BoxStockColors.textoPrincipal,
                ),
                onPressed: () => _removerItem(item), // Remove o item
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ============================================================
          // 📊 LINHA 2: INFORMAÇÕES (se não estiver comprado)
          // ============================================================
          if (!isComprado) ...[
            Row(
              children: [
                // ============================================================
                // 📦 ESTOQUE ATUAL
                // ============================================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: BoxStockColors.fundoSecundario,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.inventory_2,
                        size: 14,
                        color: BoxStockColors.papelaoMedio,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Atual: $quantidadeAtual und.',
                        style: TextStyle(
                          fontSize: 12,
                          color: BoxStockColors.textoPrincipal,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // ============================================================
                // 💡 SUGESTÃO DE QUANTIDADE
                // ============================================================
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: BoxStockColors.acaoPrincipal,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: BoxStockColors.acaoPrincipal,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.tips_and_updates,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Sugestão: $faltante und.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // ============================================================
            // 🔥 CAMPO DE QUANTIDADE (PARA AJUSTAR)
            // ============================================================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BoxStockColors.fundoPrincipal,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: BoxStockColors.papelaoClaro,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.shopping_cart,
                    size: 18,
                    color: BoxStockColors.papelaoMedio,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Comprar:',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: BoxStockColors.textoPrincipal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 🔢 CAMPO DE TEXTO PARA A QUANTIDADE
                  Container(
                    width: 55,
                    height: 35,
                    decoration: BoxDecoration(
                      color: BoxStockColors.campos,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: BoxStockColors.papelaoMedio,
                        width: 1.5,
                      ),
                    ),
                    child: TextFormField(
                      controller: controller, // O controlador da quantidade
                      keyboardType: TextInputType.number, // Teclado de números
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: BoxStockColors.acaoPrincipal,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) { // Quando o usuário digita
                        setState(() {}); // Atualiza a tela
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'und.',
                    style: TextStyle(
                      fontSize: 12,
                      color: BoxStockColors.textoPrincipal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // ✅ _MARCARCOMCOMPRADO — "MARCA O ITEM COMO COMPRADO"
  // ============================================================
  // Linha 628: Função que marca um item como comprado.
  // Analogia: É como "RISCADA" o item da lista de compras.
  Future<void> _marcarComoComprado(ListaCompra item) async {
    try {
      // Linha 630: Chama o Firestore para marcar como comprado
      await _firestoreService.marcarComoComprado(item.id!);
      if (!mounted) return;
      // Linha 633-637: Mostra mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ "${item.produtoNome}" marcado como comprado!'),
          backgroundColor: BoxStockColors.sucesso,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) { // Se deu erro
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro: $e'),
          backgroundColor: BoxStockColors.alerta,
        ),
      );
    }
  }

  // ============================================================
  // 🗑️ _REMOVERITEM — "REMOVE UM ITEM DA LISTA"
  // ============================================================
  // Linha 648: Função que remove um item da lista.
  // Analogia: É como "RASGAR" um item da lista de compras.
  Future<void> _removerItem(ListaCompra item) async {
    // Linha 649: Mostra um diálogo de confirmação
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remover item?'),
        content: Text(
          'Deseja remover "${item.produtoNome}" da lista de compras?',
          style: const TextStyle(color: BoxStockColors.textoPrincipal),
        ),
        actions: [
          TextButton( // Botão "Cancelar"
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton( // Botão "Remover"
            onPressed: () async {
              Navigator.pop(context); // Fecha o diálogo
              try {
                // Linha 666: Chama o Firestore para remover o item
                await _firestoreService.removerListaCompra(item.id!);
                if (!mounted) return;
                // Linha 669-673: Mostra mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🗑️ "${item.produtoNome}" removido!'),
                    backgroundColor: BoxStockColors.alerta,
                  ),
                );
              } catch (e) { // Se deu erro
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erro: $e'),
                    backgroundColor: BoxStockColors.alerta,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BoxStockColors.alerta,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}