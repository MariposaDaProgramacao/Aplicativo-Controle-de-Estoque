// ============================================================
// 📁 produto_model.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você tem uma "FÁBRICA DE PRODUTOS"
//              onde cada produto tem suas características:
//              nome, código, categoria, preço, quantidade, etc.
//              Esse arquivo é o MANUAL DE INSTRUÇÕES que diz
//              como cada produto deve ser criado e guardado.
// 
// 🏠 Ele é como o "molde" para fazer produtos.
//    Cada produto tem:
//    - Um nome (ex: "Cadeira gamer")
//    - Um código (ex: "CG001")
//    - Uma categoria (ex: "Escritório")
//    - Uma descrição (ex: "Cadeira ergonômica")
//    - Quantidade em estoque (ex: 10 unidades)
//    - Estoque mínimo (ex: 5 unidades)
//    - Preço de custo (ex: R$ 350,00)
//    - Preço de venda (ex: R$ 874,00)
//    - O dono do produto (usuário)
//    - Datas de criação e atualização
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Isso é como chamar os "ajudantes" que vão nos permitir
// usar o banco de dados do Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================
// 🏠 CLASSE PRODUTO — O "MOLDE" DO PRODUTO
// ============================================================
// 🔍 Analogia: É a "forma de biscoito" que usamos para criar
//              produtos. Cada produto tem todas as suas
//              características definidas aqui.
// ============================================================

class Produto {
  // ============================================================
  // 📦 ATRIBUTOS — As "características" do produto
  // ============================================================
  
  // 🔑 ID: É o "RG" do produto. Cada produto tem um único.
  //    Exemplo: "prod_001" — é como o número de identidade.
  final String? id;
  
  // 📝 NOME: O nome do produto.
  //    Exemplo: "Cadeira gamer" — é como o nome da pessoa.
  final String nome;
  
  // 🔢 CÓDIGO: O código do produto (SKU).
  //    Exemplo: "CG001" — é como o CPF do produto.
  final String codigo;
  
  // 📂 CATEGORIA: A categoria do produto.
  //    Exemplo: "Escritório" — é como a "família" do produto.
  final String categoria;
  
  // 📋 DESCRIÇÃO: Uma descrição detalhada do produto.
  //    Exemplo: "Cadeira ergonômica com ajuste de altura"
  final String descricao;
  
  // 📦 QUANTIDADE: Quantas unidades tem no estoque.
  //    Exemplo: 10 — você tem 10 unidades disponíveis.
  final double quantidade;
  
  // ⚠️ ESTOQUE MÍNIMO: O mínimo que você deve ter no estoque.
  //    Exemplo: 5 — você não pode ter menos que 5 unidades.
  final double estoqueMinimo;
  
  // 💰 PREÇO DE CUSTO: Quanto você pagou por cada unidade.
  //    Exemplo: 350.00 — você pagou R$ 350,00 por cada.
  final double precoCusto;
  
  // 💰 PREÇO DE VENDA: Quanto você vende cada unidade.
  //    Exemplo: 874.00 — você vende por R$ 874,00 cada.
  final double precoVenda;
  
  // 👤 USUÁRIO ID: O "CPF" do dono do produto.
  //    Isso serve para saber que esse produto é do João,
  //    e não da Maria. Cada usuário só vê seus próprios produtos.
  final String usuarioId;
  
  // 📅 DATA DE CRIAÇÃO: Quando o produto foi criado.
  //    Exemplo: 28/08/2026 14:30 — é como a data de nascimento.
  final DateTime createdAt;
  
  // 📅 DATA DE ATUALIZAÇÃO: Quando o produto foi atualizado.
  //    Exemplo: 28/08/2026 15:00 — é como a data da última modificação.
  final DateTime? updatedAt;

  // ============================================================
  // 🏗️ CONSTRUTOR — A "FÁBRICA" QUE CRIA PRODUTOS
  // ============================================================
  // 🔍 Analogia: É como uma máquina que pega os ingredientes
  //              (nome, código, preço, etc.) e fabrica um produto.
  //              O "required" significa que esses ingredientes
  //              são OBRIGATÓRIOS para fazer o produto.
  // ============================================================

  Produto({
    this.id, // O ID pode ser opcional (quando o produto ainda não foi salvo no Firebase)
    required this.nome, // O nome é OBRIGATÓRIO
    required this.codigo, // O código é OBRIGATÓRIO
    required this.categoria, // A categoria é OBRIGATÓRIA
    required this.descricao, // A descrição é OBRIGATÓRIA
    required this.quantidade, // A quantidade é OBRIGATÓRIA
    required this.estoqueMinimo, // O estoque mínimo é OBRIGATÓRIO
    required this.precoCusto, // O preço de custo é OBRIGATÓRIO
    required this.precoVenda, // O preço de venda é OBRIGATÓRIO
    required this.usuarioId, // O usuário é OBRIGATÓRIO
    required this.createdAt, // A data de criação é OBRIGATÓRIA
    this.updatedAt, // A data de atualização é OPCIONAL
  });

  // ============================================================
  // 📦 toMap() — "EMPACOTA" O PRODUTO PARA ENVIAR AO FIREBASE
  // ============================================================
  // 🔍 Analogia: Imagine que você vai enviar uma carta.
  //              Você coloca o nome, o endereço e o conteúdo
  //              dentro de um envelope. Essa função faz isso:
  //              pega o produto e coloca dentro de um "Map"
  //              (um pacote) para enviar ao Firebase.
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'nome': nome, // Coloca o nome no pacote
      'codigo': codigo, // Coloca o código no pacote
      'categoria': categoria, // Coloca a categoria no pacote
      'descricao': descricao, // Coloca a descrição no pacote
      'quantidade': quantidade, // Coloca a quantidade no pacote
      'estoqueMinimo': estoqueMinimo, // Coloca o estoque mínimo no pacote
      'precoCusto': precoCusto, // Coloca o preço de custo no pacote
      'precoVenda': precoVenda, // Coloca o preço de venda no pacote
      'usuarioId': usuarioId, // Coloca o ID do usuário no pacote
      'createdAt': createdAt.toIso8601String(), // Coloca a data de criação (em formato de texto)
      'updatedAt': updatedAt?.toIso8601String(), // Coloca a data de atualização (se tiver)
    };
  }

  // ============================================================
  // 🔥 fromMap() — "DESEMPACOTA" O PRODUTO QUE VEIO DO FIREBASE
  // ============================================================
  // 🔍 Analogia: Imagine que você recebeu um pacote do correio.
  //              Você abre e tira o nome, o endereço e o conteúdo.
  //              Essa função faz isso: pega os dados que vieram
  //              do Firebase e transforma de volta em um produto.
  // ============================================================

  factory Produto.fromMap(String id, Map<String, dynamic> map) {
    // 🔥 FUNÇÃO AUXILIAR: Converte a data para o formato certo
    // 🔍 Analogia: É como um "tradutor" que converte a data
    //              que veio do Firebase (que pode ser um "Timestamp"
    //              ou um "String") para o formato que o Dart entende.
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now(); // Se não tiver data, usa a data de hoje
      if (value is Timestamp) return value.toDate(); // Se for Timestamp do Firebase, converte
      if (value is String) return DateTime.parse(value); // Se for String, converte
      if (value is DateTime) return value; // Se já for DateTime, usa assim mesmo
      return DateTime.now(); // Se for qualquer outra coisa, usa a data de hoje
    }

    // 🔥 CRIA O PRODUTO COM OS DADOS DO PACOTE
    return Produto(
      id: id, // O ID é o que veio no pacote
      nome: map['nome'] ?? '', // Pega o nome, se não tiver, usa vazio
      codigo: map['codigo'] ?? '', // Pega o código, se não tiver, usa vazio
      categoria: map['categoria'] ?? '', // Pega a categoria, se não tiver, usa vazio
      descricao: map['descricao'] ?? '', // Pega a descrição, se não tiver, usa vazio
      quantidade: (map['quantidade'] ?? 0).toDouble(), // Pega a quantidade, se não tiver, usa 0
      estoqueMinimo: (map['estoqueMinimo'] ?? 0).toDouble(), // Pega o estoque mínimo, se não tiver, usa 0
      precoCusto: (map['precoCusto'] ?? 0).toDouble(), // Pega o preço de custo, se não tiver, usa 0
      precoVenda: (map['precoVenda'] ?? 0).toDouble(), // Pega o preço de venda, se não tiver, usa 0
      usuarioId: map['usuarioId'] ?? '', // Pega o usuário, se não tiver, usa vazio
      createdAt: parseDate(map['createdAt']), // Pega a data de criação e converte
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null, // Pega a data de atualização (se tiver)
    );
  }

  // ============================================================
  // 📋 copyWith() — "COPIA" O PRODUTO COM ALTERAÇÕES
  // ============================================================
  // 🔍 Analogia: Imagine que você tem uma foto sua e quer
  //              fazer uma cópia, mas com um sorriso diferente.
  //              Essa função permite criar uma cópia do produto
  //              mudando apenas o que você quiser.
  // ============================================================

  Produto copyWith({
    String? id, // Novo ID (opcional)
    String? nome, // Novo nome (opcional)
    String? codigo, // Novo código (opcional)
    String? categoria, // Nova categoria (opcional)
    String? descricao, // Nova descrição (opcional)
    double? quantidade, // Nova quantidade (opcional)
    double? estoqueMinimo, // Novo estoque mínimo (opcional)
    double? precoCusto, // Novo preço de custo (opcional)
    double? precoVenda, // Novo preço de venda (opcional)
    String? usuarioId, // Novo usuário (opcional)
    DateTime? createdAt, // Nova data de criação (opcional)
    DateTime? updatedAt, // Nova data de atualização (opcional)
  }) {
    return Produto(
      id: id ?? this.id, // Se não passou novo ID, mantém o antigo
      nome: nome ?? this.nome, // Se não passou novo nome, mantém o antigo
      codigo: codigo ?? this.codigo, // Se não passou novo código, mantém o antigo
      categoria: categoria ?? this.categoria, // Se não passou nova categoria, mantém a antiga
      descricao: descricao ?? this.descricao, // Se não passou nova descrição, mantém a antiga
      quantidade: quantidade ?? this.quantidade, // Se não passou nova quantidade, mantém a antiga
      estoqueMinimo: estoqueMinimo ?? this.estoqueMinimo, // Se não passou novo estoque mínimo, mantém o antigo
      precoCusto: precoCusto ?? this.precoCusto, // Se não passou novo preço de custo, mantém o antigo
      precoVenda: precoVenda ?? this.precoVenda, // Se não passou novo preço de venda, mantém o antigo
      usuarioId: usuarioId ?? this.usuarioId, // Se não passou novo usuário, mantém o antigo
      createdAt: createdAt ?? this.createdAt, // Se não passou nova data de criação, mantém a antiga
      updatedAt: updatedAt ?? this.updatedAt, // Se não passou nova data de atualização, mantém a antiga
    );
  }

  // ============================================================
  // 📊 STATUS — "PERGUNTAS" SOBRE A SITUAÇÃO DO PRODUTO
  // ============================================================
  // 🔍 Analogia: São como perguntas que você faz ao produto:
  //              "Como está seu estoque?"
  //              "Qual é a cor do seu status?"
  //              "Qual é o seu ícone?"
  // ============================================================

  // 📊 SITUAÇÃO DO ESTOQUE: Retorna o status do estoque
  //    Exemplo: quantidade = 0 → "Sem Estoque"
  //              quantidade = 3 (mínimo = 5) → "Estoque Baixo"
  //              quantidade = 10 (mínimo = 5) → "Disponível"
  String get situacaoEstoque {
    if (quantidade <= 0) return 'Sem Estoque'; // Se não tem nada no estoque
    if (quantidade <= estoqueMinimo) return 'Estoque Baixo'; // Se está abaixo do mínimo
    return 'Disponível'; // Se está acima do mínimo
  }

  // 🎨 SITUAÇÃO COR: Retorna a cor do status
  //    Exemplo: "Sem Estoque" → #FF4444 (Vermelho)
  //              "Estoque Baixo" → #FF8C00 (Laranja)
  //              "Disponível" → #4CAF50 (Verde)
  String get situacaoCor {
    if (quantidade <= 0) return '#FF4444'; // Vermelho - sem estoque
    if (quantidade <= estoqueMinimo) return '#FF8C00'; // Laranja - estoque baixo
    return '#4CAF50'; // Verde - disponível
  }

  // 🎯 SITUAÇÃO ÍCONE: Retorna o ícone do status
  //    Exemplo: "Sem Estoque" → error_outline (ícone de erro)
  //              "Estoque Baixo" → warning_amber_rounded (ícone de aviso)
  //              "Disponível" → check_circle_outline (ícone de check)
  String get situacaoIcone {
    if (quantidade <= 0) return 'error_outline'; // Ícone de erro
    if (quantidade <= estoqueMinimo) return 'warning_amber_rounded'; // Ícone de aviso
    return 'check_circle_outline'; // Ícone de check
  }

  // 🎨 STATUS COR: Retorna o nome da cor do status
  //    Exemplo: "Sem Estoque" → "vermelho"
  //              "Estoque Baixo" → "laranja"
  //              "Disponível" → "verde"
  String get statusColor {
    if (quantidade <= 0) return 'vermelho'; // Vermelho
    if (quantidade <= estoqueMinimo) return 'laranja'; // Laranja
    return 'verde'; // Verde
  }

  // ============================================================
  // 💰 CÁLCULOS — "PERGUNTAS" SOBRE VALORES
  // ============================================================
  // 🔍 Analogia: São como perguntas que você faz ao produto:
  //              "Quanto vale todo o seu estoque?"
  //              "Quanto você lucra por unidade?"
  //              "Qual é a sua margem de lucro?"
  // ============================================================

  // 💰 VALOR TOTAL DO ESTOQUE: Calcula o valor total do estoque
  //    Exemplo: quantidade = 10, precoCusto = 350.00
  //             → 10 x 350 = 3500.00 (R$ 3.500,00)
  double get valorTotalEstoque => quantidade * precoCusto;

  // 💰 LUCRO POR UNIDADE: Calcula o lucro por unidade
  //    Exemplo: precoVenda = 874.00, precoCusto = 350.00
  //             → 874 - 350 = 524.00 (R$ 524,00 de lucro)
  double get lucroPorUnidade => precoVenda - precoCusto;

  // 📊 MARGEM DE LUCRO: Calcula a margem de lucro em porcentagem
  //    Exemplo: lucroPorUnidade = 524.00, precoCusto = 350.00
  //             → (524 / 350) * 100 = 149.71%
  double get margemLucro {
    if (precoCusto <= 0) return 0; // Se o preço de custo for 0, retorna 0
    return (lucroPorUnidade / precoCusto) * 100; // Calcula a porcentagem
  }

  // ============================================================
  // ✅ VALIDAÇÕES — "PERGUNTAS" SOBRE O ESTOQUE
  // ============================================================
  // 🔍 Analogia: São como perguntas que você faz ao produto:
  //              "Seu estoque está crítico?"
  //              "Você está sem estoque?"
  //              "Você está disponível?"
  // ============================================================

  // ⚠️ ESTOQUE CRÍTICO: Verifica se o estoque está crítico
  //    Exemplo: quantidade = 3, estoqueMinimo = 5
  //             → true (está crítico)
  bool get isEstoqueCritico => quantidade <= estoqueMinimo;

  // ❌ SEM ESTOQUE: Verifica se o estoque está vazio
  //    Exemplo: quantidade = 0 → true (sem estoque)
  bool get isSemEstoque => quantidade <= 0;

  // ✅ DISPONÍVEL: Verifica se o produto está disponível
  //    Exemplo: quantidade = 10, estoqueMinimo = 5
  //             → true (está disponível)
  bool get isDisponivel => quantidade > estoqueMinimo;

  // ============================================================
  // 💰 FORMATAÇÃO — "PERGUNTAS" SOBRE FORMATAÇÃO DE VALORES
  // ============================================================
  // 🔍 Analogia: São como perguntas que você faz ao produto:
  //              "Qual é o seu preço de custo formatado?"
  //              "Qual é o seu preço de venda formatado?"
  //              "Qual é o valor total do seu estoque formatado?"
  // ============================================================

  // 💰 PREÇO DE CUSTO FORMATADO: Formata o preço de custo com R$
  //    Exemplo: 350.0 → "R$ 350,00"
  String get precoCustoFormatado =>
      'R\$ ${precoCusto.toStringAsFixed(2).replaceAll('.', ',')}';

  // 💰 PREÇO DE VENDA FORMATADO: Formata o preço de venda com R$
  //    Exemplo: 874.0 → "R$ 874,00"
  String get precoVendaFormatado =>
      'R\$ ${precoVenda.toStringAsFixed(2).replaceAll('.', ',')}';

  // 💰 VALOR TOTAL FORMATADO: Formata o valor total do estoque com R$
  //    Exemplo: 3500.0 → "R$ 3.500,00"
  String get valorTotalEstoqueFormatado =>
      'R\$ ${valorTotalEstoque.toStringAsFixed(2).replaceAll('.', ',')}';
}