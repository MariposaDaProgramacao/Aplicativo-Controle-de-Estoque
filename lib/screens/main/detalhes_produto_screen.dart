// ============================================================
// 📁 detalhes_produto_screen.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está em uma "LOJA" e pegou
//              um produto da prateleira para ver todas as
//              informações dele. Essa tela é a "FICHA TÉCNICA"
//              do produto, onde você vê tudo sobre ele.
// 
// 🏠 Ele é como a "ETIQUETA DETALHADA" do produto:
//    - Nome, código e categoria (quem é)
//    - Quantidade em estoque (quanto tem)
//    - Estoque mínimo (quanto deveria ter)
//    - Descrição (o que ele faz)
//    - Situação do estoque (está disponível?)
//    - Preços (quanto custa)
//    - Valor total do estoque (quanto vale tudo)
//    - Botões para: Entrada, Saída, Editar, Excluir
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir a tela
import 'package:flutter/material.dart';
// Linha 2: Importa o Firestore para excluir o produto
import 'package:cloud_firestore/cloud_firestore.dart';
// Linha 3: Importa o modelo de Produto
import '../../models/produto_model.dart';
// Linha 4: Importa as cores do sistema
import '../../main.dart';
// Linha 5: Importa a tela de Entrada
import 'entrada_screen.dart';
// Linha 6: Importa a tela de Saída
import 'saida_screen.dart';
// Linha 7: Importa a tela de Cadastro/Edição
import 'cadastro_produto_screen.dart';

// ============================================================
// 🏠 CLASSE DETALHESPRODUTOSCREEN — A "TELA DE DETALHES"
// ============================================================
// Linha 10: Define a classe DetalhesProdutoScreen
// StatelessWidget = a tela não muda (é fixa, só mostra informações)
class DetalhesProdutoScreen extends StatelessWidget {
  // Linha 11: O produto que será exibido (obrigatório)
  // Analogia: É o "PRODUTO" que você pegou da prateleira.
  final Produto produto;

  // Linha 13: Construtor com chave e o produto obrigatório
  const DetalhesProdutoScreen({super.key, required this.produto});

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI A TELA DE DETALHES"
  // ============================================================
  // Linha 16: A função que constrói toda a tela.
  @override
  Widget build(BuildContext context) {
    // Linha 17: Retorna um Scaffold (a estrutura básica da tela)
    return Scaffold(
      // Linha 18: Define a cor de fundo.
      backgroundColor: BoxStockColors.fundoPrincipal,
      
      // ============================================================
      // 📱 APPBAR — A "BARRA SUPERIOR"
      // ============================================================
      // Linha 20: A barra que fica no topo.
      appBar: AppBar(
        title: Text( // Linha 21: O título da barra é o nome do produto
          produto.nome,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: BoxStockColors.papelaoMedio,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Linha 29-37: A "fita adesiva" decorativa
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
      body: SingleChildScrollView( // Linha 42: Permite rolar a tela
        padding: const EdgeInsets.all(16), // Espaço nas bordas
        child: Column( // Linha 44: Organiza os widgets em coluna
          crossAxisAlignment: CrossAxisAlignment.start, // Alinha à esquerda
          children: [
            // ============================================================
            // 🏠 CABEÇALHO
            // ============================================================
            // Linha 49: Constrói o cabeçalho com nome, código e categoria
            _buildHeader(),
            const SizedBox(height: 16), // Espaço

            // ============================================================
            // 📋 CARD DE INFORMAÇÕES
            // ============================================================
            // Linha 53: Constrói o card com quantidade, estoque mínimo e descrição
            _buildInfoCard(),
            const SizedBox(height: 16), // Espaço

            // ============================================================
            // 📊 CARD DE STATUS
            // ============================================================
            // Linha 57: Constrói o card com a situação do estoque
            _buildStatusCard(),
            const SizedBox(height: 16), // Espaço

            // ============================================================
            // 💰 CARD DE VALORES
            // ============================================================
            // Linha 61: Constrói o card com preços e valor total
            _buildValuesCard(),
            const SizedBox(height: 20), // Espaço

            // ============================================================
            // 🔘 BOTÕES DE AÇÃO
            // ============================================================
            // Linha 66: Constrói os botões (Entrada, Saída, Editar, Excluir)
            _buildActionButtons(context),
            const SizedBox(height: 16), // Espaço extra
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🏠 _BUILDHEADER — "CONSTRÓI O CABEÇALHO"
  // ============================================================
  // Linha 76: Função que constrói o cabeçalho.
  // Analogia: É como a "ETIQUETA" do produto com nome e código.
  Widget _buildHeader() {
    // Linha 77: Retorna um container com o cabeçalho.
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            BoxStockColors.papelaoClaro.withOpacity(0.2),
            BoxStockColors.papelaoClaro.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row( // Linha 100: Organiza em linha
        children: [
          // ============================================================
          // 🖼️ ÍCONE DO PRODUTO
          // ============================================================
          // Linha 103: O ícone do produto (uma caixa)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: BoxStockColors.fundoSecundario,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: BoxStockColors.papelaoClaro.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.inventory_2,
              size: 32,
              color: BoxStockColors.papelaoMedio,
            ),
          ),
          const SizedBox(width: 16), // Espaço
          
          // ============================================================
          // 📝 NOME E CÓDIGO
          // ============================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text( // O nome do produto
                  produto.nome,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: BoxStockColors.textoPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Row( // Linha 134: Categoria e código
                  children: [
                    Container( // Categoria
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BoxStockColors.fundoSecundario,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '📂 ${produto.categoria}',
                        style: TextStyle(
                          fontSize: 12,
                          color: BoxStockColors.textoPrincipal.withOpacity(0.6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container( // Código
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: BoxStockColors.fundoSecundario,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🏷️ ${produto.codigo}',
                        style: TextStyle(
                          fontSize: 12,
                          color: BoxStockColors.textoPrincipal.withOpacity(0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📋 _BUILDINFOCARD — "CONSTRÓI O CARD DE INFORMAÇÕES"
  // ============================================================
  // Linha 170: Função que constrói o card de informações.
  // Analogia: É como a "FICHA TÉCNICA" do produto.
  Widget _buildInfoCard() {
    // Linha 171: Retorna um container com as informações.
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
      child: Column( // Linha 186: Organiza em coluna
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha 188: Título do card
          const Text(
            '📋 Informações do Produto',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: BoxStockColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 12), // Espaço
          
          // Linha 196: Quantidade em estoque
          _buildInfoRow(
            '📦 Quantidade em estoque',
            '${produto.quantidade.toStringAsFixed(0)} unidades',
          ),
          const Divider(color: BoxStockColors.papelaoClaro), // Linha separadora
          
          // Linha 202: Estoque mínimo
          _buildInfoRow(
            '⚠️ Estoque mínimo',
            '${produto.estoqueMinimo.toStringAsFixed(0)} unidades',
          ),
          
          // Linha 207: Descrição (só aparece se tiver texto)
          if (produto.descricao.isNotEmpty) ...[
            const Divider(color: BoxStockColors.papelaoClaro),
            _buildInfoRow('📝 Descrição', produto.descricao),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // 📝 _BUILDINFOROW — "CONSTRÓI UMA LINHA DE INFORMAÇÃO"
  // ============================================================
  // Linha 214: Função que constrói cada linha de informação.
  // Analogia: É como cada "LINHA" da ficha técnica.
  Widget _buildInfoRow(String label, String value) {
    // Linha 215: Retorna um padding com uma linha.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha 220: O rótulo (ex: "📦 Quantidade em estoque")
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: BoxStockColors.textoPrincipal.withOpacity(0.6),
              ),
            ),
          ),
          // Linha 229: O valor (ex: "10 unidades")
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: BoxStockColors.textoPrincipal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 📊 _BUILDSTATUSCARD — "CONSTRÓI O CARD DE STATUS"
  // ============================================================
  // Linha 240: Função que constrói o card de status.
  // Analogia: É como um "SEMÁFORO" que mostra a situação do estoque.
  Widget _buildStatusCard() {
    // Linha 241-252: Define o status, cor e ícone baseado na quantidade
    String status;
    Color cor;
    IconData icone;

    if (produto.quantidade <= 0) { // Sem estoque
      status = 'Sem Estoque';
      cor = BoxStockColors.alerta; // Vermelho
      icone = Icons.error_outline;
    } else if (produto.quantidade <= produto.estoqueMinimo) { // Estoque baixo
      status = 'Estoque Baixo';
      cor = BoxStockColors.acaoPrincipal; // Laranja
      icone = Icons.warning_amber_rounded;
    } else { // Disponível
      status = 'Disponível';
      cor = BoxStockColors.sucesso; // Verde
      icone = Icons.check_circle_outline;
    }

    // Linha 254: Retorna um container com o status.
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cor.withOpacity(0.08), // Fundo com a cor fraca
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: cor.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row( // Linha 271: Organiza em linha
        children: [
          // ============================================================
          // 🎯 ÍCONE DO STATUS
          // ============================================================
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icone,
              color: cor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14), // Espaço
          
          // ============================================================
          // 📝 TEXTO DO STATUS
          // ============================================================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text( // "Situação do Estoque"
                  'Situação do Estoque',
                  style: TextStyle(
                    fontSize: 12,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.5),
                  ),
                ),
                Text( // O status (ex: "Disponível")
                  status,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: cor,
                  ),
                ),
              ],
            ),
          ),
          
          // ============================================================
          // 🏷️ ETIQUETA DE ALERTA (CRÍTICO, ATENÇÃO, OK)
          // ============================================================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Text( // "CRÍTICO", "ATENÇÃO" ou "OK"
              produto.quantidade <= 0
                  ? 'CRÍTICO'
                  : produto.quantidade <= produto.estoqueMinimo
                      ? 'ATENÇÃO'
                      : 'OK',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 💰 _BUILDVALUESCARD — "CONSTRÓI O CARD DE VALORES"
  // ============================================================
  // Linha 329: Função que constrói o card de valores.
  // Analogia: É como a "ETIQUETA DE PREÇO" do produto.
  Widget _buildValuesCard() {
    // Linha 330: Retorna um container com os valores.
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
      child: Column( // Linha 345: Organiza em coluna
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Linha 347: Título do card
          const Text(
            '💰 Valores',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: BoxStockColors.textoPrincipal,
            ),
          ),
          const SizedBox(height: 12), // Espaço
          
          // Linha 355: Preço de Custo e Preço de Venda em linha
          Row(
            children: [
              Expanded(
                child: _buildValueItem(
                  'Preço de Custo',
                  produto.precoCustoFormatado,
                  BoxStockColors.informacao,
                ),
              ),
              Expanded(
                child: _buildValueItem(
                  'Preço de Venda',
                  produto.precoVendaFormatado,
                  BoxStockColors.sucesso,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), // Espaço
          
          // Linha 371: Valor total em estoque
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: BoxStockColors.fundoSecundario,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text( // Rótulo
                  '💰 Valor total em estoque',
                  style: TextStyle(
                    fontSize: 13,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.7),
                  ),
                ),
                Text( // Valor
                  produto.valorTotalEstoqueFormatado,
                  style: const TextStyle(
                    fontSize: 18,
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
  // 💰 _BUILDVALUEITEM — "CONSTRÓI UM ITEM DE VALOR"
  // ============================================================
  // Linha 394: Função que constrói cada item de valor.
  Widget _buildValueItem(String label, String value, Color cor) {
    // Linha 395: Retorna um container com o valor.
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: BoxStockColors.fundoPrincipal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text( // Rótulo (ex: "Preço de Custo")
            label,
            style: TextStyle(
              fontSize: 11,
              color: BoxStockColors.textoPrincipal.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text( // Valor (ex: "R$ 350,00")
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔘 _BUILDACTIONBUTTONS — "CONSTRÓI OS BOTÕES DE AÇÃO"
  // ============================================================
  // Linha 422: Função que constrói os 4 botões.
  // Analogia: É como os "BOTÕES DE CONTROLE" do produto.
  Widget _buildActionButtons(BuildContext context) {
    // Linha 423: Retorna um container com os botões.
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: BoxStockColors.campos.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row( // Linha 435: Organiza os botões em linha
          children: [
            // 🔥 BOTÃO ENTRADA (verde)
            Expanded(
              child: _buildActionButton(
                icon: Icons.add_box,
                label: 'Entrada',
                color: BoxStockColors.sucesso,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EntradaScreen(produto: produto),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8), // Espaço
            
            // 🔥 BOTÃO SAÍDA (laranja)
            Expanded(
              child: _buildActionButton(
                icon: Icons.remove_shopping_cart,
                label: 'Saída',
                color: BoxStockColors.acaoPrincipal,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SaidaScreen(produto: produto),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8), // Espaço
            
            // 🔥 BOTÃO EDITAR (azul)
            Expanded(
              child: _buildActionButton(
                icon: Icons.edit,
                label: 'Editar',
                color: BoxStockColors.informacao,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CadastroProdutoScreen(produto: produto),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8), // Espaço
            
            // 🔥 BOTÃO EXCLUIR (vermelho)
            Expanded(
              child: _buildActionButton(
                icon: Icons.delete,
                label: 'Excluir',
                color: BoxStockColors.alerta,
                onPressed: () {
                  _confirmarExclusao(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🔘 _BUILDACTIONBUTTON — "CONSTRÓI UM BOTÃO DE AÇÃO"
  // ============================================================
  // Linha 486: Função que constrói cada botão individual.
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    // Linha 491: Retorna um botão com ícone e texto.
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.12), // Fundo fraco
          foregroundColor: color, // Texto na cor
          padding: const EdgeInsets.symmetric(horizontal: 4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: BorderSide( // Borda na cor
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
          elevation: 0, // Sem sombra
        ),
        child: Column( // Linha 505: Ícone em cima, texto embaixo
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18), // Ícone
            const SizedBox(height: 2),
            Text( // Texto
              label,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🗑️ _CONFIRMAREXCLUSAO — "CONFIRMA A EXCLUSÃO"
  // ============================================================
  // Linha 519: Função que confirma a exclusão do produto.
  // Analogia: É como "PERGUNTAR" se você tem certeza
  //           que quer jogar o produto fora.
  void _confirmarExclusao(BuildContext context) {
    // Linha 520: Mostra um diálogo de confirmação.
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
        content: Text( // Linha 531: A pergunta
          'Deseja realmente excluir o produto\n"${produto.nome}"?',
          style: const TextStyle(color: BoxStockColors.textoPrincipal),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [ // Linha 539: Botões
          TextButton( // Botão "Cancelar"
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: BoxStockColors.textoPrincipal,
            ),
            child: const Text('Cancelar'),
          ),
          ElevatedButton( // Botão "Excluir"
            onPressed: () async {
              Navigator.pop(context); // Fecha o diálogo
              Navigator.pop(context); // Fecha a tela de detalhes

              try { // Tenta excluir do Firebase
                await FirebaseFirestore.instance
                    .collection('produtos')
                    .doc(produto.id)
                    .delete();

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✅ Produto excluído com sucesso!'),
                    backgroundColor: BoxStockColors.sucesso,
                  ),
                );
              } catch (e) { // Se deu erro
                if (!context.mounted) return;
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