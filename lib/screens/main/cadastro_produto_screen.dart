// ============================================================
// 📁 cadastro_produto_screen.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está em uma "LOJA DE DEPARTAMENTOS"
//              e precisa cadastrar um novo produto na prateleira.
//              Essa tela é o "FORMULÁRIO DE CADASTRO" onde você
//              coloca todas as informações do produto.
// 
// 🏠 Ele é como a "FICHA DE CADASTRO" do produto:
//    - Nome do produto (ex: "Cadeira gamer")
//    - Código (ex: "CG001")
//    - Categoria (ex: "Escritório")
//    - Descrição (ex: "Cadeira ergonômica")
//    - Quantidade (ex: 10 unidades)
//    - Estoque mínimo (ex: 5 unidades)
//    - Preço de custo (ex: R$ 350,00)
//    - Preço de venda (ex: R$ 874,00)
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir a tela
import 'package:flutter/material.dart';
// Linha 2: Importa o Firebase Auth para pegar o usuário logado
import 'package:firebase_auth/firebase_auth.dart';
// Linha 3: Importa o serviço do Firestore para salvar no banco
import '../../services/firestore_service.dart';
// Linha 4: Importa o modelo de Produto (o "molde" do produto)
import '../../models/produto_model.dart';
// Linha 5: Importa o modelo de Categoria (para o dropdown)
import '../../models/categoria_model.dart';
// Linha 6: Importa as cores do sistema
import '../../main.dart';

// ============================================================
// 🏠 CLASSE CADASTROPRODUTOSCREEN — A "TELA DE CADASTRO"
// ============================================================
// Linha 9: Define a classe CadastroProdutoScreen
// StatefulWidget = a tela pode mudar (ex: mostrar carregando)
class CadastroProdutoScreen extends StatefulWidget {
  // Linha 10: O produto que está sendo editado (se houver)
  // Se for null, é um novo produto. Se tiver valor, é edição.
  final Produto? produto;

  // Linha 12: Construtor com chave opcional e o produto opcional
  const CadastroProdutoScreen({super.key, this.produto});

  // Linha 14-16: Cria o estado da tela (a "memória" da tela)
  @override
  State<CadastroProdutoScreen> createState() => _CadastroProdutoScreenState();
}

// ============================================================
// 🧠 _CADASTROPRODUTOSCREENSTATE — A "MEMÓRIA" DA TELA
// ============================================================
// Linha 20: Classe que guarda o estado da tela de cadastro
class _CadastroProdutoScreenState extends State<CadastroProdutoScreen> {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" da tela
  // ============================================================
  
  // Linha 23: Instância do FirestoreService (o "entregador" que leva os dados)
  final FirestoreService _firestoreService = FirestoreService();
  
  // Linha 24: Chave do formulário. Valida todos os campos juntos.
  // Exemplo: Verifica se o nome não está vazio, se o preço é válido, etc.
  final _formKey = GlobalKey<FormState>();
  
  // Linhas 26-32: Controladores dos campos de texto.
  // Cada controlador guarda o que o usuário digita em cada campo.
  // Analogia: São como "CADERNOS" onde o usuário anota as informações.
  final _nomeController = TextEditingController(); // Caderno do nome
  final _codigoController = TextEditingController(); // Caderno do código
  final _descricaoController = TextEditingController(); // Caderno da descrição
  final _quantidadeController = TextEditingController(); // Caderno da quantidade
  final _estoqueMinimoController = TextEditingController(); // Caderno do estoque mínimo
  final _precoCustoController = TextEditingController(); // Caderno do preço de custo
  final _precoVendaController = TextEditingController(); // Caderno do preço de venda
  
  // Linha 35: A categoria selecionada no dropdown.
  // Analogia: É a "GAVETA" onde o produto vai ser guardado.
  String _categoriaSelecionada = '';
  
  // Linha 36: Controla se está carregando.
  // true = mostra a roda de carregamento.
  bool _isLoading = false;
  
  // Linha 37: Se é edição (true) ou novo cadastro (false).
  bool _isEditando = false;
  
  // Linha 38: Contador de caracteres da descrição.
  // Exemplo: 30/200 caracteres.
  int _descricaoCaracteres = 0;

  // ============================================================
  // 🚀 INITSTATE — "O QUE ACONTECE QUANDO A TELA ABRE"
  // ============================================================
  // Linhas 41-46: Função chamada quando a tela é aberta.
  // É como a "RECEPCIONISTA" que prepara o formulário antes
  // do usuário começar a preencher.
  @override
  void initState() {
    super.initState(); // Chama o initState da classe pai
    _isEditando = widget.produto != null; // Se veio um produto, é edição
    if (_isEditando) { // Se for edição
      _preencherCampos(); // Preenche os campos com os dados do produto
    }
  }

  // ============================================================
  // 📝 _PREENCHERCAMPOS — "PREENCHE OS CAMPOS COM OS DADOS"
  // ============================================================
  // Linha 49: Função que preenche os campos quando é edição.
  // Analogia: É a "AJUDANTE" que pega a ficha do produto e
  //           já coloca as informações nos lugares certos.
  void _preencherCampos() {
    final produto = widget.produto!; // Pega o produto que veio
    _nomeController.text = produto.nome; // Coloca o nome no campo
    _codigoController.text = produto.codigo; // Coloca o código no campo
    _categoriaSelecionada = produto.categoria; // Seleciona a categoria
    _descricaoController.text = produto.descricao; // Coloca a descrição
    _quantidadeController.text = produto.quantidade.toString(); // Coloca a quantidade
    _estoqueMinimoController.text = produto.estoqueMinimo.toString(); // Coloca o estoque mínimo
    _precoCustoController.text = produto.precoCusto.toString(); // Coloca o preço de custo
    _precoVendaController.text = produto.precoVenda.toString(); // Coloca o preço de venda
    _descricaoCaracteres = produto.descricao.length; // Conta os caracteres da descrição
  }

  // ============================================================
  // 💾 _SALVARPRODUTO — "SALVA O PRODUTO NO BANCO"
  // ============================================================
  // Linha 62: Função que salva o produto (novo ou editado).
  // Analogia: É a "ATENDENTE" que pega o formulário preenchido
  //           e guarda na gaveta certa.
  Future<void> _salvarProduto() async {
    // Linha 63: Valida o formulário. Se algo estiver errado, para aqui.
    if (!_formKey.currentState!.validate()) return;

    // Linha 65: Mostra o "carregando..."
    setState(() => _isLoading = true);

    // Linha 68: Tenta salvar no Firebase.
    // O try tenta fazer algo que pode dar erro.
    try {
      // Linha 69: Pega o usuário logado.
      // O ! significa "tenho certeza que não é null".
      final user = FirebaseAuth.instance.currentUser!;
      
      // Linhas 70-73: Pega os valores dos campos e converte para números.
      // double.parse = transforma texto em número decimal.
      final quantidade = double.parse(_quantidadeController.text);
      final estoqueMinimo = double.parse(_estoqueMinimoController.text);
      final precoCusto = double.parse(_precoCustoController.text);
      final precoVenda = double.parse(_precoVendaController.text);

      // Linha 76: Se for edição (true), atualiza o produto.
      if (_isEditando) {
        // Linha 77-88: Chama o Firestore para atualizar o produto.
        // Passa o ID do produto e os novos dados.
        await _firestoreService.atualizarProduto(
          widget.produto!.id!, // O ID do produto (o "RG")
          {
            'nome': _nomeController.text.trim(), // Remove espaços do nome
            'codigo': _codigoController.text.trim(), // Remove espaços do código
            'categoria': _categoriaSelecionada, // A categoria escolhida
            'descricao': _descricaoController.text.trim(), // Remove espaços da descrição
            'estoqueMinimo': estoqueMinimo, // O estoque mínimo
            'precoCusto': precoCusto, // O preço de custo
            'precoVenda': precoVenda, // O preço de venda
          },
        );

        // Linha 91: Verifica se a tela ainda está aberta.
        if (!mounted) return;
        
        // Linha 93-97: Mostra uma mensagem de sucesso.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Produto atualizado com sucesso!'),
            backgroundColor: BoxStockColors.sucesso, // Verde = sucesso
          ),
        );
      } else {
        // Linha 101: Se for novo produto (não é edição), cria um novo.
        // Analogia: É como criar uma "FICHA NOVA" para um produto.
        final produto = Produto(
          nome: _nomeController.text.trim(), // Nome do produto
          codigo: _codigoController.text.trim(), // Código do produto
          categoria: _categoriaSelecionada, // Categoria
          descricao: _descricaoController.text.trim(), // Descrição
          quantidade: quantidade, // Quantidade
          estoqueMinimo: estoqueMinimo, // Estoque mínimo
          precoCusto: precoCusto, // Preço de custo
          precoVenda: precoVenda, // Preço de venda
          usuarioId: user.uid, // ID do usuário que está cadastrando
          createdAt: DateTime.now(), // Data e hora de criação
        );

        // Linha 116: Salva o produto no Firestore.
        await _firestoreService.criarProduto(produto);

        // Linha 119: Verifica se a tela ainda está aberta.
        if (!mounted) return;
        
        // Linha 121-125: Mostra uma mensagem de sucesso.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Produto cadastrado com sucesso!'),
            backgroundColor: BoxStockColors.sucesso,
          ),
        );
      }

      // Linha 130: Volta para a tela anterior.
      Navigator.pop(context);
    } catch (e) {
      // Linha 132: Se deu erro, mostra a mensagem de erro.
      _showErrorDialog('Erro ao salvar produto: $e');
    } finally {
      // Linha 134-136: Isso acontece SEMPRE, mesmo se der erro.
      // Desativa o "carregando".
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // ❌ _SHOWERRORDIALOG — "MOSTRA O ERRO"
  // ============================================================
  // Linha 140: Função que mostra um diálogo de erro.
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
  // 🧹 DISPOSE — "LIMPA A MESA" QUANDO SAI
  // ============================================================
  // Linhas 158-168: Quando a tela é fechada, limpamos os controladores.
  // Isso libera memória do celular.
  @override
  void dispose() {
    _nomeController.dispose();
    _codigoController.dispose();
    _descricaoController.dispose();
    _quantidadeController.dispose();
    _estoqueMinimoController.dispose();
    _precoCustoController.dispose();
    _precoVendaController.dispose();
    super.dispose();
  }

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI A TELA DE CADASTRO"
  // ============================================================
  // Linha 172: A função que constrói toda a tela.
  @override
  Widget build(BuildContext context) {
    // Linha 173: Retorna um Scaffold (a estrutura básica da tela)
    return Scaffold(
      // Linha 174: Define a cor de fundo.
      backgroundColor: BoxStockColors.fundoPrincipal,
      
      // ============================================================
      // 📱 APPBAR — A "BARRA SUPERIOR"
      // ============================================================
      // Linha 176: A barra que fica no topo.
      appBar: AppBar(
        title: Text( // Linha 177: O título da barra
          _isEditando ? '✏️ Editar Produto' : '📦 Novo Produto',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: BoxStockColors.papelaoMedio,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [ // Linha 185: Botões na barra superior
          if (_isEditando) // Se for edição, mostra o botão de excluir
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _confirmarExclusao, // Confirma a exclusão
              tooltip: 'Excluir',
            ),
        ],
        // Linha 193-201: A "fita adesiva" decorativa abaixo da barra
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
      body: SingleChildScrollView( // Linha 207: Permite rolar a tela
        padding: const EdgeInsets.all(20), // Espaço nas bordas
        child: Form( // Linha 209: O formulário que valida os campos
          key: _formKey, // A chave que valida tudo
          child: Column( // Linha 211: Organiza os widgets em coluna
            children: [
              // ===== INDICADOR DE EDIÇÃO =====
              // Linha 214: Se for edição, mostra o indicador.
              if (_isEditando) _buildEditIndicator(),
              const SizedBox(height: 20), // Espaço

              // ===== FORMULÁRIO =====
              // Linha 218: Constrói o formulário com todos os campos.
              _buildForm(),
              const SizedBox(height: 24), // Espaço

              // ===== BOTÃO SALVAR =====
              // Linha 222: Constrói o botão "Salvar".
              _buildSalvarButton(),
              const SizedBox(height: 16), // Espaço extra
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ✏️ _BUILDEDITINDICATOR — "INDICA QUE ESTÁ EDITANDO"
  // ============================================================
  // Linha 231: Função que constrói o indicador de edição.
  // Analogia: É uma "PLACA" que diz "Você está editando este produto".
  Widget _buildEditIndicator() {
    // Linha 232: Retorna um container com informações da edição.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: BoxStockColors.fundoSecundario,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row( // Linha 242: Organiza em linha
        children: [
          // Linha 243: O ícone de edição
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: BoxStockColors.informacao.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_note,
              color: BoxStockColors.informacao,
              size: 20,
            ),
          ),
          const SizedBox(width: 12), // Espaço
          
          // Linha 256: As informações do produto que está sendo editado
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Editando: ${widget.produto!.nome}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
                Text(
                  'Altere as informações abaixo',
                  style: TextStyle(
                    fontSize: 12,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          
          // Linha 275: O código do produto (o "RG")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: BoxStockColors.informacao.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: BoxStockColors.informacao.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'ID: ${widget.produto!.codigo}',
              style: TextStyle(
                fontSize: 10,
                color: BoxStockColors.informacao,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📄 _BUILDFORM — "CONSTRÓI O FORMULÁRIO"
  // ============================================================
  // Linha 298: Função que constrói todos os campos do formulário.
  Widget _buildForm() {
    // Linha 299: Retorna um container com todos os campos.
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column( // Linha 314: Todos os campos em coluna
        children: [
          // Campo 1: Nome
          _buildNomeField(),
          const SizedBox(height: 16),

          // Campo 2: Código
          _buildCodigoField(),
          const SizedBox(height: 16),

          // Campo 3: Categoria
          _buildCategoriaField(),
          const SizedBox(height: 16),

          // Campo 4: Descrição
          _buildDescricaoField(),
          const SizedBox(height: 16),

          // ============================================================
          // 🔥 CAMPOS ORGANIZADOS - UM ABAIXO DO OUTRO
          // ============================================================

          // 🔥 QUANTIDADE
          _buildQuantidadeField(),
          const SizedBox(height: 16),

          // 🔥 ESTOQUE MÍNIMO
          _buildEstoqueMinimoField(),
          const SizedBox(height: 16),

          // 🔥 PREÇO DE CUSTO
          _buildPrecoCustoField(),
          const SizedBox(height: 16),

          // 🔥 PREÇO DE VENDA
          _buildPrecoVendaField(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ============================================================
  // 📝 _BUILDNOMEFIELD — "CONSTRÓI O CAMPO NOME"
  // ============================================================
  // Linha 350: Função que constrói o campo "Nome do Produto".
  Widget _buildNomeField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _nomeController,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 15),
        decoration: const InputDecoration(
          labelText: 'Nome do Produto *',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.label_outline,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          hintText: 'Ex: Teclado USB',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Digite o nome do produto';
          }
          return null;
        },
      ),
    );
  }

  // ============================================================
  // 🔢 _BUILDCODIGOFIELD — "CONSTRÓI O CAMPO CÓDIGO"
  // ============================================================
  Widget _buildCodigoField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _codigoController,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 15),
        decoration: const InputDecoration(
          labelText: 'Código do Produto *',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.qr_code,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
          hintText: 'Ex: TEC001',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Digite o código do produto';
          }
          return null;
        },
      ),
    );
  }

  // ============================================================
  // 📂 _BUILDCATEGORIAFIELD — "CONSTRÓI O CAMPO CATEGORIA"
  // ============================================================
  Widget _buildCategoriaField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          labelText: 'Categoria *',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.category_outlined,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        value: _categoriaSelecionada.isNotEmpty ? _categoriaSelecionada : null,
        items: CategoriaDropdownHelper.getDropdownItems(),
        onChanged: (value) {
          setState(() {
            _categoriaSelecionada = value!;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Selecione uma categoria';
          }
          return null;
        },
        dropdownColor: BoxStockColors.campos,
        style: TextStyle(color: BoxStockColors.textoPrincipal),
        icon: Icon(Icons.arrow_drop_down, color: BoxStockColors.papelaoMedio),
      ),
    );
  }

  // ============================================================
  // 📝 _BUILDDESCRICAOFIELD — "CONSTRÓI O CAMPO DESCRIÇÃO"
  // ============================================================
  Widget _buildDescricaoField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _descricaoController,
            maxLines: 3,
            maxLength: 200,
            style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 15),
            decoration: const InputDecoration(
              labelText: 'Descrição',
              labelStyle: TextStyle(
                color: BoxStockColors.textoPrincipal,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: Icon(
                Icons.description_outlined,
                color: BoxStockColors.papelaoMedio,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              counterText: '',
            ),
            onChanged: (value) {
              setState(() {
                _descricaoCaracteres = value.length;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 8),
            child: Align(
              alignment: Alignment.bottomRight,
              child: Text(
                '$_descricaoCaracteres/200',
                style: TextStyle(
                  fontSize: 12,
                  color: _descricaoCaracteres > 180
                      ? BoxStockColors.alerta
                      : BoxStockColors.textoPrincipal.withOpacity(0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔢 _BUILDQUANTIDADEFIELD — "CONSTRÓI O CAMPO QUANTIDADE"
  // ============================================================
  Widget _buildQuantidadeField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _quantidadeController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 15),
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
          if (qtd == null || qtd < 0) {
            return 'Digite um valor válido';
          }
          return null;
        },
      ),
    );
  }

  // ============================================================
  // ⚠️ _BUILDESTOQUEMINIMOFIELD — "CONSTRÓI O CAMPO ESTOQUE MÍNIMO"
  // ============================================================
  Widget _buildEstoqueMinimoField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _estoqueMinimoController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 15),
        decoration: const InputDecoration(
          labelText: 'Estoque Mínimo *',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.warning_amber_outlined,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Digite o estoque mínimo';
          }
          final qtd = double.tryParse(value);
          if (qtd == null || qtd < 0) {
            return 'Digite um valor válido';
          }
          return null;
        },
      ),
    );
  }

  // ============================================================
  // 💰 _BUILDPRECOCUSTOFIELD — "CONSTRÓI O CAMPO PREÇO DE CUSTO"
  // ============================================================
  Widget _buildPrecoCustoField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _precoCustoController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 15),
        decoration: const InputDecoration(
          labelText: 'Preço de Custo *',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.monetization_on_outlined,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Digite o preço de custo';
          }
          final preco = double.tryParse(value);
          if (preco == null || preco < 0) {
            return 'Digite um valor válido';
          }
          return null;
        },
      ),
    );
  }

  // ============================================================
  // 💰 _BUILDPRECOVENDAFIELD — "CONSTRÓI O CAMPO PREÇO DE VENDA"
  // ============================================================
  Widget _buildPrecoVendaField() {
    return Container(
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: TextFormField(
        controller: _precoVendaController,
        keyboardType: TextInputType.number,
        style: TextStyle(color: BoxStockColors.textoPrincipal, fontSize: 15),
        decoration: const InputDecoration(
          labelText: 'Preço de Venda *',
          labelStyle: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.attach_money,
            color: BoxStockColors.papelaoMedio,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Digite o preço de venda';
          }
          final preco = double.tryParse(value);
          if (preco == null || preco < 0) {
            return 'Digite um valor válido';
          }
          return null;
        },
      ),
    );
  }

  // ============================================================
  // 🔘 _BUILDSALVARBUTTON — "CONSTRÓI O BOTÃO SALVAR"
  // ============================================================
  Widget _buildSalvarButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _salvarProduto,
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
                children: [
                  Icon(
                    _isEditando ? Icons.save : Icons.add_box,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isEditando ? '✏️ Atualizar Produto' : '📦 Cadastrar Produto',
                    style: const TextStyle(
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

  // ============================================================
  // 🗑️ _CONFIRMAREXCLUSAO — "CONFIRMA A EXCLUSÃO DO PRODUTO"
  // ============================================================
  void _confirmarExclusao() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: BoxStockColors.alerta),
            SizedBox(width: 8),
            Text('Confirmar Exclusão'),
          ],
        ),
        content: Text(
          'Deseja realmente excluir o produto\n"${widget.produto!.nome}"?',
          style: const TextStyle(color: BoxStockColors.textoPrincipal),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: BoxStockColors.textoPrincipal,
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _firestoreService.excluirProduto(widget.produto!.id!);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Produto excluído com sucesso!'),
                    backgroundColor: BoxStockColors.sucesso,
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Erro ao excluir: $e'),
                    backgroundColor: BoxStockColors.alerta,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BoxStockColors.alerta,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 🎯 CATEGORIADROPDOWNHELPER — "AJUDANTE DO MENU DE CATEGORIAS"
// ============================================================
// Linha 701: Classe que ajuda a criar as opções do menu de categorias.
// Analogia: É o "CARDÁPIO" que mostra todas as categorias disponíveis.
class CategoriaDropdownHelper {
  // Linha 703: Função que cria as opções do dropdown.
  // Analogia: É como colocar os sabores de sorvete no menu.
  static List<DropdownMenuItem<String>> getDropdownItems() {
    // Linha 704: Para cada categoria na lista, cria uma opção.
    return CategoriasPadrao.lista.map((categoria) {
      return DropdownMenuItem<String>(
        value: categoria, // O valor que será salvo
        child: Text(categoria), // O texto que aparece na tela
      );
    }).toList(); // Transforma tudo em uma lista
  }
}