// ============================================================
// 📁 status_estoque.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está em um "SEMÁFORO" que
//              mostra a situação do estoque de um produto.
//              Verde = Disponível, Amarelo = Estoque Baixo,
//              Vermelho = Sem Estoque. Esse widget é o
//              "SEMÁFORO" do BoxStock!
// 
// 🏠 Ele é como um "INDICADOR DE STATUS" reutilizável:
//    - Mostra se o produto está Disponível (verde)
//    - Mostra se o produto está com Estoque Baixo (laranja)
//    - Mostra se o produto está Sem Estoque (vermelho)
//    - Tem versões: simples, detalhada e bolinha
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir o widget
import 'package:flutter/material.dart';

// ============================================================
// 🟢🟠🔴 CLASSE STATUSESTOQUE — O "SEMÁFORO" DO ESTOQUE
// ============================================================
// Linha 6: Define a classe StatusEstoque
// StatelessWidget = o widget não muda (é fixo)
// 
// 🔍 Analogia: É como um "SEMÁFORO" que mostra a situação do estoque.
class StatusEstoque extends StatelessWidget {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "características" do semáforo
  // ============================================================
  
  // Linha 9: O status do estoque (não usado diretamente, mas mantido)
  final String status;
  
  // Linha 10: A quantidade atual do produto
  // Exemplo: 10 unidades disponíveis
  final double quantidade;
  
  // Linha 11: O estoque mínimo do produto
  // Exemplo: 5 unidades (se chegar a 5, acende o amarelo)
  final double estoqueMinimo;
  
  // Linha 12: Se deve mostrar o ícone
  // Exemplo: true = mostra o ícone, false = só o texto
  final bool showIcon;
  
  // Linha 13: Se é a versão compacta (menor)
  // Exemplo: true = versão pequena, false = versão normal
  final bool compact;

  // ============================================================
  // 🏗️ CONSTRUTOR — "CRIA O SEMÁFORO"
  // ============================================================
  // Linha 16-24: O construtor da classe.
  const StatusEstoque({
    super.key,
    required this.status, // Obrigatório: o status (ex: "Disponível")
    required this.quantidade, // Obrigatório: a quantidade
    required this.estoqueMinimo, // Obrigatório: o estoque mínimo
    this.showIcon = true, // Opcional: mostra ícone (padrão: true)
    this.compact = false, // Opcional: versão compacta (padrão: false)
  });

  // ============================================================
  // 🎨 MÉTODOS PRIVADOS — "O QUE O SEMÁFORO FAZ"
  // ============================================================

  // ============================================================
  // 🎨 _GETSTATUSCOLOR — "QUAL É A COR DO SEMÁFORO?"
  // ============================================================
  // Linha 29: Função que retorna a cor baseada na quantidade.
  // 
  // 🔍 Analogia: O semáforo decide qual cor acender:
  //              Verde = Disponível, Laranja = Baixo, Vermelho = Sem Estoque
  // 
  // Retorna: A cor correspondente ao status
  Color _getStatusColor() {
    // Linha 30: Se não tem estoque (quantidade <= 0) → Vermelho
    if (quantidade <= 0) return Colors.red.shade700;
    
    // Linha 31: Se está abaixo do mínimo (quantidade <= estoqueMinimo) → Laranja
    if (quantidade <= estoqueMinimo) return Colors.orange.shade700;
    
    // Linha 32: Se está acima do mínimo → Verde
    return Colors.green.shade700;
  }

  // ============================================================
  // 🎯 _GETSTATUSICON — "QUAL É O ÍCONE DO SEMÁFORO?"
  // ============================================================
  // Linha 37: Função que retorna o ícone baseado na quantidade.
  // 
  // 🔍 Analogia: O semáforo mostra um símbolo diferente para cada situação.
  // 
  // Retorna: O ícone correspondente ao status
  IconData _getStatusIcon() {
    // Linha 38: Se não tem estoque → Ícone de erro
    if (quantidade <= 0) return Icons.error_outline;
    
    // Linha 39: Se está baixo → Ícone de aviso
    if (quantidade <= estoqueMinimo) return Icons.warning_amber_rounded;
    
    // Linha 40: Se está disponível → Ícone de check
    return Icons.check_circle_outline;
  }

  // ============================================================
  // 📝 _GETSTATUSLABEL — "QUAL É O TEXTO DO SEMÁFORO?"
  // ============================================================
  // Linha 45: Função que retorna o texto do status.
  // 
  // 🔍 Analogia: O semáforo mostra uma palavra para cada situação.
  // 
  // Retorna: O texto correspondente ao status
  String _getStatusLabel() {
    // Linha 46: Se não tem estoque → "SEM ESTOQUE"
    if (quantidade <= 0) return 'SEM ESTOQUE';
    
    // Linha 47: Se está baixo → "ESTOQUE BAIXO"
    if (quantidade <= estoqueMinimo) return 'ESTOQUE BAIXO';
    
    // Linha 48: Se está disponível → "DISPONÍVEL"
    return 'DISPONÍVEL';
  }

  // ============================================================
  // 📝 _GETSTATUSLABELSHORT — "TEXTO CURTO DO SEMÁFORO"
  // ============================================================
  // Linha 53: Função que retorna o texto curto do status.
  // 
  // 🔍 Analogia: Versão "resumida" do semáforo para espaços pequenos.
  // 
  // Retorna: O texto curto correspondente ao status
  String _getStatusLabelShort() {
    // Linha 54: Se não tem estoque → "SEM"
    if (quantidade <= 0) return 'SEM';
    
    // Linha 55: Se está baixo → "BAIXO"
    if (quantidade <= estoqueMinimo) return 'BAIXO';
    
    // Linha 56: Se está disponível → "OK"
    return 'OK';
  }

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI O SEMÁFORO NA TELA"
  // ============================================================
  // Linha 61: A função que constrói o widget na tela.
  @override
  Widget build(BuildContext context) {
    // Linha 62: Pega a cor do status
    final color = _getStatusColor();
    
    // Linha 63: Pega o texto (normal ou compacto)
    final label = compact ? _getStatusLabelShort() : _getStatusLabel();
    
    // Linha 64: Pega o ícone
    final icon = _getStatusIcon();

    // Linha 66: Retorna um Container (a "caixa" do semáforo)
    return Container(
      // Linha 67: Espaço interno
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12, // Menos espaço se for compacto
        vertical: compact ? 4 : 6, // Menos espaço se for compacto
      ),
      
      // ============================================================
      // 🎨 DECORAÇÃO — O "ESTILO" DO SEMÁFORO
      // ============================================================
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), // Cor com transparência
        borderRadius: BorderRadius.circular(16), // Bordas arredondadas
        border: Border.all( // Borda com a cor
          color: color,
          width: 1.5,
        ),
        boxShadow: [ // Sombra sutil
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      
      // ============================================================
      // 📋 CONTEÚDO — O QUE APARECE DENTRO
      // ============================================================
      child: Row(
        mainAxisSize: MainAxisSize.min, // Ocupa só o espaço necessário
        children: [
          // ============================================================
          // 🎯 ÍCONE — O "SÍMBOLO" DO SEMÁFORO
          // ============================================================
          if (showIcon) ...[ // Se deve mostrar o ícone...
            Icon(
              icon, // O ícone correspondente ao status
              color: color, // A cor correspondente ao status
              size: compact ? 14 : 18, // Tamanho (menor se for compacto)
            ),
            if (!compact) const SizedBox(width: 6), // Espaço (só se não for compacto)
          ],
          
          // ============================================================
          // 📝 TEXTO — A "PALAVRA" DO SEMÁFORO
          // ============================================================
          Text(
            label, // O texto correspondente ao status
            style: TextStyle(
              fontSize: compact ? 10 : 13, // Tamanho (menor se for compacto)
              fontWeight: FontWeight.bold, // Negrito
              color: color, // Cor correspondente ao status
              letterSpacing: 0.5, // Espaço entre as letras
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// 📋 STATUSESTOQUEDETALHADO — "SEMÁFORO COM MAIS INFORMAÇÕES"
// ============================================================
// Linha 105: Define a classe StatusEstoqueDetalhado
// 
// 🔍 Analogia: É como um "SEMÁFORO GRANDE" que mostra mais informações
//              sobre o produto (nome, quantidade, preço).
class StatusEstoqueDetalhado extends StatelessWidget {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "características" do semáforo detalhado
  // ============================================================
  
  // Linha 108: O nome do produto
  final String nome;
  
  // Linha 109: A quantidade atual
  final double quantidade;
  
  // Linha 110: O estoque mínimo
  final double estoqueMinimo;
  
  // Linha 111: O preço de venda (opcional)
  final double? precoVenda;
  
  // Linha 112: Função chamada quando clica (opcional)
  final VoidCallback? onTap;

  // ============================================================
  // 🏗️ CONSTRUTOR — "CRIA O SEMÁFORO DETALHADO"
  // ============================================================
  const StatusEstoqueDetalhado({
    super.key,
    required this.nome,
    required this.quantidade,
    required this.estoqueMinimo,
    this.precoVenda,
    this.onTap,
  });

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI O SEMÁFORO DETALHADO NA TELA"
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Linha 126: Pega a cor, ícone e texto
    final color = _getStatusColor();
    final icon = _getStatusIcon();
    final label = _getStatusLabel();

    // Linha 130: Retorna um GestureDetector (para detectar cliques)
    return GestureDetector(
      onTap: onTap, // Quando clica, chama a função (se tiver)
      
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFE9B3), // Cor creme
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.shade800.withOpacity(0.15),
              offset: const Offset(3, 3),
              blurRadius: 6,
            ),
          ],
          border: Border.all(
            color: Colors.brown.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // ============================================================
            // 📝 INFORMAÇÕES PRINCIPAIS
            // ============================================================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do produto
                  Text(
                    nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      // Ícone de estoque
                      Icon(
                        Icons.inventory_2,
                        size: 14,
                        color: Colors.brown.shade600,
                      ),
                      const SizedBox(width: 4),
                      // Quantidade
                      Text(
                        '${quantidade.toStringAsFixed(0)} unidades',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.brown.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Preço (se tiver)
                      if (precoVenda != null) ...[
                        Icon(
                          Icons.attach_money,
                          size: 14,
                          color: Colors.brown.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'R\$ ${precoVenda!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.brown.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // ============================================================
            // 🟢🟠🔴 STATUS — O "SEMÁFORO"
            // ============================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🎨 MÉTODOS PRIVADOS — "O QUE O SEMÁFORO DETALHADO FAZ"
  // ============================================================
  
  // Linha 199: Cor do status
  Color _getStatusColor() {
    if (quantidade <= 0) return Colors.red.shade700;
    if (quantidade <= estoqueMinimo) return Colors.orange.shade700;
    return Colors.green.shade700;
  }

  // Linha 204: Ícone do status
  IconData _getStatusIcon() {
    if (quantidade <= 0) return Icons.error_outline;
    if (quantidade <= estoqueMinimo) return Icons.warning_amber_rounded;
    return Icons.check_circle_outline;
  }

  // Linha 209: Texto do status
  String _getStatusLabel() {
    if (quantidade <= 0) return 'SEM ESTOQUE';
    if (quantidade <= estoqueMinimo) return 'ESTOQUE BAIXO';
    return 'DISPONÍVEL';
  }
}

// ============================================================
// 🔴🟠🟢 BOLINHA — "INDICADOR MINIATURA"
// ============================================================
// Linha 219: Define a classe StatusBolinha
// 
// 🔍 Analogia: É como uma "BOLINHA" colorida que indica o status
//              em espaços muito pequenos.
class StatusBolinha extends StatelessWidget {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "características" da bolinha
  // ============================================================
  
  // Linha 222: A quantidade atual
  final double quantidade;
  
  // Linha 223: O estoque mínimo
  final double estoqueMinimo;
  
  // Linha 224: O tamanho da bolinha
  final double tamanho;

  // ============================================================
  // 🏗️ CONSTRUTOR — "CRIA A BOLINHA"
  // ============================================================
  const StatusBolinha({
    super.key,
    required this.quantidade,
    required this.estoqueMinimo,
    this.tamanho = 12, // Tamanho padrão: 12
  });

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI A BOLINHA NA TELA"
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // Linha 234-240: Decide a cor da bolinha
    Color cor;
    if (quantidade <= 0) {
      cor = Colors.red; // Sem estoque → Vermelho
    } else if (quantidade <= estoqueMinimo) {
      cor = Colors.orange; // Estoque baixo → Laranja
    } else {
      cor = Colors.green; // Disponível → Verde
    }

    // Linha 242: Retorna um Container redondo
    return Container(
      width: tamanho, // Largura
      height: tamanho, // Altura
      decoration: BoxDecoration(
        color: cor, // A cor decidida
        shape: BoxShape.circle, // Formato de círculo
        boxShadow: [ // Sombra
          BoxShadow(
            color: cor.withOpacity(0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}