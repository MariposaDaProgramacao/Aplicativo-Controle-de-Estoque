import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';
import '../../models/produto_model.dart';
import '../../models/categoria_model.dart';
import '../../main.dart';

class CadastroProdutoScreen extends StatefulWidget {
  final Produto? produto;

  const CadastroProdutoScreen({super.key, this.produto});

  @override
  State<CadastroProdutoScreen> createState() => _CadastroProdutoScreenState();
}

class _CadastroProdutoScreenState extends State<CadastroProdutoScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _codigoController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _quantidadeController = TextEditingController();
  final _estoqueMinimoController = TextEditingController();
  final _precoCustoController = TextEditingController();
  final _precoVendaController = TextEditingController();

  String _categoriaSelecionada = '';
  bool _isLoading = false;
  bool _isEditando = false;
  int _descricaoCaracteres = 0;

  @override
  void initState() {
    super.initState();
    _isEditando = widget.produto != null;
    if (_isEditando) {
      _preencherCampos();
    }
  }

  void _preencherCampos() {
    final produto = widget.produto!;
    _nomeController.text = produto.nome;
    _codigoController.text = produto.codigo;
    _categoriaSelecionada = produto.categoria;
    _descricaoController.text = produto.descricao;
    _quantidadeController.text = produto.quantidade.toString();
    _estoqueMinimoController.text = produto.estoqueMinimo.toString();
    _precoCustoController.text = produto.precoCusto.toString();
    _precoVendaController.text = produto.precoVenda.toString();
    _descricaoCaracteres = produto.descricao.length;
  }

  Future<void> _salvarProduto() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final quantidade = double.parse(_quantidadeController.text);
      final estoqueMinimo = double.parse(_estoqueMinimoController.text);
      final precoCusto = double.parse(_precoCustoController.text);
      final precoVenda = double.parse(_precoVendaController.text);

      if (_isEditando) {
        await _firestoreService.atualizarProduto(
          widget.produto!.id!,
          {
            'nome': _nomeController.text.trim(),
            'codigo': _codigoController.text.trim(),
            'categoria': _categoriaSelecionada,
            'descricao': _descricaoController.text.trim(),
            'estoqueMinimo': estoqueMinimo,
            'precoCusto': precoCusto,
            'precoVenda': precoVenda,
          },
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Produto atualizado com sucesso!'),
            backgroundColor: BoxStockColors.sucesso,
          ),
        );
      } else {
        final produto = Produto(
          nome: _nomeController.text.trim(),
          codigo: _codigoController.text.trim(),
          categoria: _categoriaSelecionada,
          descricao: _descricaoController.text.trim(),
          quantidade: quantidade,
          estoqueMinimo: estoqueMinimo,
          precoCusto: precoCusto,
          precoVenda: precoVenda,
          usuarioId: user.uid,
          createdAt: DateTime.now(),
        );

        await _firestoreService.criarProduto(produto);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Produto cadastrado com sucesso!'),
            backgroundColor: BoxStockColors.sucesso,
          ),
        );
      }

      Navigator.pop(context);
    } catch (e) {
      _showErrorDialog('Erro ao salvar produto: $e');
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

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BoxStockColors.fundoPrincipal,
      appBar: AppBar(
        title: Text(
          _isEditando ? '✏️ Editar Produto' : '📦 Novo Produto',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: BoxStockColors.papelaoMedio,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (_isEditando)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white),
              onPressed: _confirmarExclusao,
              tooltip: 'Excluir',
            ),
        ],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ===== INDICADOR DE EDIÇÃO =====
              if (_isEditando) _buildEditIndicator(),
              const SizedBox(height: 20),

              // ===== FORMULÁRIO =====
              _buildForm(),
              const SizedBox(height: 24),

              // ===== BOTÃO SALVAR =====
              _buildSalvarButton(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== INDICADOR DE EDIÇÃO ====================

  Widget _buildEditIndicator() {
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
      child: Row(
        children: [
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
          const SizedBox(width: 12),
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

  // ==================== FORMULÁRIO ====================

  Widget _buildForm() {
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
      child: Column(
        children: [
          // Campo 1: Nome
          _buildNomeField(),
          const SizedBox(height: 16),

          // Campos 2: Código
          _buildCodigoField(),
          const SizedBox(height: 16),

          // Campo 3: Categoria
          _buildCategoriaField(),
          const SizedBox(height: 16),

          // Campo 4: Descrição
          _buildDescricaoField(),
          const SizedBox(height: 16),

          // Campos 5 e 6: Quantidade e Estoque Mínimo
          Row(
            children: [
              Expanded(child: _buildQuantidadeField()),
              const SizedBox(width: 12),
              Expanded(child: _buildEstoqueMinimoField()),
            ],
          ),
          const SizedBox(height: 16),

          // Campos 7 e 8: Preço Custo e Preço Venda
          Row(
            children: [
              Expanded(child: _buildPrecoCustoField()),
              const SizedBox(width: 12),
              Expanded(child: _buildPrecoVendaField()),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== CAMPOS ====================

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

  // ==================== BOTÃO SALVAR ====================

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

  // ==================== EXCLUSÃO ====================

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

// ==================== HELPER ====================

class CategoriaDropdownHelper {
  static List<DropdownMenuItem<String>> getDropdownItems() {
    return CategoriasPadrao.lista.map((categoria) {
      return DropdownMenuItem<String>(
        value: categoria,
        child: Text(categoria),
      );
    }).toList();
  }
}