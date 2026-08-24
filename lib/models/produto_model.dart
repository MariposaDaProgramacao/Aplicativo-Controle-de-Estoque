/// Modelo de Produto para o BoxStock
/// 
/// Representa um produto no estoque com todos os seus atributos
/// e métodos para manipulação de dados.
class Produto {
  // ==================== ATRIBUTOS ====================
  final String? id;
  final String nome;
  final String codigo;
  final String categoria;
  final String descricao;
  final double quantidade;
  final double estoqueMinimo;
  final double precoCusto;
  final double precoVenda;
  final String usuarioId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ==================== CONSTRUTOR ====================
  Produto({
    this.id,
    required this.nome,
    required this.codigo,
    required this.categoria,
    required this.descricao,
    required this.quantidade,
    required this.estoqueMinimo,
    required this.precoCusto,
    required this.precoVenda,
    required this.usuarioId,
    required this.createdAt,
    this.updatedAt,
  });

  // ==================== MÉTODOS DE CONVERSÃO ====================

  /// Converte o objeto para um Map (para enviar ao Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'codigo': codigo,
      'categoria': categoria,
      'descricao': descricao,
      'quantidade': quantidade,
      'estoqueMinimo': estoqueMinimo,
      'precoCusto': precoCusto,
      'precoVenda': precoVenda,
      'usuarioId': usuarioId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Converte um Map (do Firestore) para um objeto Produto
  factory Produto.fromMap(String id, Map<String, dynamic> map) {
    return Produto(
      id: id,
      nome: map['nome'] ?? '',
      codigo: map['codigo'] ?? '',
      categoria: map['categoria'] ?? '',
      descricao: map['descricao'] ?? '',
      quantidade: (map['quantidade'] ?? 0).toDouble(),
      estoqueMinimo: (map['estoqueMinimo'] ?? 0).toDouble(),
      precoCusto: (map['precoCusto'] ?? 0).toDouble(),
      precoVenda: (map['precoVenda'] ?? 0).toDouble(),
      usuarioId: map['usuarioId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
    );
  }

  // ==================== MÉTODOS DE CÓPIA ====================

  /// Cria uma cópia do produto com alguns campos alterados
  Produto copyWith({
    String? id,
    String? nome,
    String? codigo,
    String? categoria,
    String? descricao,
    double? quantidade,
    double? estoqueMinimo,
    double? precoCusto,
    double? precoVenda,
    String? usuarioId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Produto(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      codigo: codigo ?? this.codigo,
      categoria: categoria ?? this.categoria,
      descricao: descricao ?? this.descricao,
      quantidade: quantidade ?? this.quantidade,
      estoqueMinimo: estoqueMinimo ?? this.estoqueMinimo,
      precoCusto: precoCusto ?? this.precoCusto,
      precoVenda: precoVenda ?? this.precoVenda,
      usuarioId: usuarioId ?? this.usuarioId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==================== MÉTODOS DE STATUS ====================

  /// Retorna a situação do estoque (texto)
  /// 
  /// Possíveis valores:
  /// - 'Sem Estoque' → quantidade <= 0
  /// - 'Estoque Baixo' → quantidade > 0 e <= estoqueMinimo
  /// - 'Disponível' → quantidade > estoqueMinimo
  String get situacaoEstoque {
    if (quantidade <= 0) return 'Sem Estoque';
    if (quantidade <= estoqueMinimo) return 'Estoque Baixo';
    return 'Disponível';
  }

  /// Retorna a cor da situação do estoque (hex)
  /// 
  /// Cores da paleta:
  /// - Sem Estoque → Vermelho (#FF4444)
  /// - Estoque Baixo → Laranja (#FF8C00)
  /// - Disponível → Verde (#4CAF50)
  String get situacaoCor {
    if (quantidade <= 0) return '#FF4444';
    if (quantidade <= estoqueMinimo) return '#FF8C00';
    return '#4CAF50';
  }

  /// Retorna o ícone da situação do estoque
  /// 
  /// Ícones:
  /// - Sem Estoque → Icons.error_outline
  /// - Estoque Baixo → Icons.warning_amber_rounded
  /// - Disponível → Icons.check_circle_outline
  String get situacaoIcone {
    if (quantidade <= 0) return 'error_outline';
    if (quantidade <= estoqueMinimo) return 'warning_amber_rounded';
    return 'check_circle_outline';
  }

  /// Retorna a cor do status para uso no widget StatusEstoque
  String get statusColor {
    if (quantidade <= 0) return 'vermelho';
    if (quantidade <= estoqueMinimo) return 'laranja';
    return 'verde';
  }

  // ==================== MÉTODOS DE CÁLCULO ====================

  /// Calcula o valor total do produto em estoque
  /// 
  /// Fórmula: quantidade × preço de custo
  double get valorTotalEstoque => quantidade * precoCusto;

  /// Calcula o lucro potencial por unidade
  /// 
  /// Fórmula: preço de venda - preço de custo
  double get lucroPorUnidade => precoVenda - precoCusto;

  /// Calcula a margem de lucro em porcentagem
  /// 
  /// Fórmula: (lucroPorUnidade / precoCusto) × 100
  double get margemLucro {
    if (precoCusto <= 0) return 0;
    return (lucroPorUnidade / precoCusto) * 100;
  }

  // ==================== MÉTODOS DE VALIDAÇÃO ====================

  /// Verifica se o produto está com estoque crítico
  bool get isEstoqueCritico => quantidade <= estoqueMinimo;

  /// Verifica se o produto está sem estoque
  bool get isSemEstoque => quantidade <= 0;

  /// Verifica se o produto está disponível
  bool get isDisponivel => quantidade > estoqueMinimo;

  // ==================== MÉTODO DE FORMATAÇÃO ====================

  /// Formata o preço para moeda brasileira (R$)
  String get precoCustoFormatado =>
      'R\$ ${precoCusto.toStringAsFixed(2)}';

  String get precoVendaFormatado =>
      'R\$ ${precoVenda.toStringAsFixed(2)}';

  String get valorTotalEstoqueFormatado =>
      'R\$ ${valorTotalEstoque.toStringAsFixed(2)}';

  // ==================== EXEMPLO DE USO ====================
  /*
  // Criando um produto
  final produto = Produto(
    nome: 'Teclado USB',
    codigo: 'TEC001',
    categoria: 'Periféricos',
    descricao: 'Teclado USB ABNT2',
    quantidade: 15,
    estoqueMinimo: 5,
    precoCusto: 35.00,
    precoVenda: 59.90,
    usuarioId: 'user123',
    createdAt: DateTime.now(),
  );

  // Verificando situação
  print(produto.situacaoEstoque); // 'Disponível'
  print(produto.isEstoqueCritico); // false
  print(produto.valorTotalEstoque); // 525.0
  */
}