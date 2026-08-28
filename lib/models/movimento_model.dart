// ============================================================
// 📁 movimento_model.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você tem um "DIÁRIO DE BORDO"
//              onde registra tudo que entra e sai do seu estoque.
//              Esse arquivo é o MANUAL DE INSTRUÇÕES que diz
//              como cada movimentação (entrada ou saída)
//              deve ser criada e guardada.
// 
// 🏠 Ele é como o "molde" para fazer registros de movimentação.
//    Cada movimento tem:
//    - O produto que foi movimentado (ex: "Cadeira gamer")
//    - O tipo de movimentação (entrada ou saída)
//    - A quantidade movimentada (ex: +5 ou -3)
//    - Quem fez a movimentação (ex: "joao@email.com")
//    - Quando foi feita (ex: 28/08/2026 14:30)
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Isso é como chamar os "ajudantes" que vão nos permitir
// usar cores, botões, textos e o banco de dados do Firebase.
import 'package:flutter/material.dart'; // Ajudante para interface (cores)
import 'package:cloud_firestore/cloud_firestore.dart'; // Ajudante para o Firebase

// ============================================================
// 🏠 CLASSE MOVIMENTO — O "MOLDE" DA MOVIMENTAÇÃO
// ============================================================
// 🔍 Analogia: É a "forma de biscoito" que usamos para criar
//              registros de movimentação. Cada movimento tem:
//              - O ID do produto (para saber qual produto é)
//              - O nome do produto (para mostrar no histórico)
//              - O tipo de movimentação (entrada ou saída)
//              - A quantidade movimentada
//              - O preço unitário (opcional)
//              - Uma observação (opcional)
//              - O ID do usuário (quem fez)
//              - O e-mail do usuário (para mostrar quem foi)
//              - A data de criação (quando aconteceu)
// ============================================================

class Movimento {
  // ============================================================
  // 📦 ATRIBUTOS — As "características" do movimento
  // ============================================================
  
  // 🔑 ID: É o "RG" do movimento. Cada movimento tem um único.
  //    Exemplo: "mov_001" — é como o número de identidade.
  final String? id;
  
  // 🏷️ PRODUTO ID: É o "CPF" do produto movimentado.
  //    Exemplo: "prod_001" — identifica o produto "Cadeira gamer".
  final String produtoId;
  
  // 📝 PRODUTO NOME: O nome do produto movimentado.
  //    Exemplo: "Cadeira gamer" — é o que aparece no histórico.
  final String produtoNome;
  
  // 🔄 TIPO: O tipo de movimentação.
  //    Exemplo: "entrada" (entrou no estoque) ou "saida" (saiu do estoque)
  final String tipo;
  
  // 🔢 QUANTIDADE: Quantas unidades foram movimentadas.
  //    Exemplo: 5 (entraram 5 unidades) ou -3 (saíram 3 unidades)
  final double quantidade;
  
  // 💰 PREÇO UNITÁRIO: O preço de cada unidade (opcional).
  //    Exemplo: 25.00 (cada unidade custou R$ 25,00)
  final double? precoUnitario;
  
  // 📝 OBSERVAÇÃO: Um comentário sobre a movimentação (opcional).
  //    Exemplo: "Compra do fornecedor XYZ"
  final String? observacao;
  
  // 👤 USUÁRIO ID: O "CPF" de quem fez a movimentação.
  //    Exemplo: "user_123" — identifica quem fez o registro.
  final String usuarioId;
  
  // 📧 USUÁRIO E-MAIL: O e-mail de quem fez a movimentação.
  //    Exemplo: "joao@email.com" — mostra quem fez no histórico.
  final String usuarioEmail;
  
  // 📅 DATA DE CRIAÇÃO: Quando a movimentação aconteceu.
  //    Exemplo: 28/08/2026 14:30 — é como a data do evento.
  final DateTime createdAt;

  // ============================================================
  // 🏗️ CONSTRUTOR — A "FÁBRICA" QUE CRIA MOVIMENTAÇÕES
  // ============================================================
  // 🔍 Analogia: É como uma máquina que pega os ingredientes
  //              (produto, tipo, quantidade, usuário, etc.)
  //              e fabrica um registro de movimentação.
  //              O "required" significa que esses ingredientes
  //              são OBRIGATÓRIOS para fazer o movimento.
  // ============================================================

  Movimento({
    this.id, // O ID pode ser opcional (quando o movimento ainda não foi salvo no Firebase)
    required this.produtoId, // O ID do produto é OBRIGATÓRIO
    required this.produtoNome, // O nome do produto é OBRIGATÓRIO
    required this.tipo, // O tipo é OBRIGATÓRIO (entrada ou saída)
    required this.quantidade, // A quantidade é OBRIGATÓRIA
    this.precoUnitario, // O preço unitário é OPCIONAL
    this.observacao, // A observação é OPCIONAL
    required this.usuarioId, // O usuário é OBRIGATÓRIO
    required this.usuarioEmail, // O e-mail é OBRIGATÓRIO
    required this.createdAt, // A data de criação é OBRIGATÓRIA
  });

  // ============================================================
  // 📦 toMap() — "EMPACOTA" O MOVIMENTO PARA ENVIAR AO FIREBASE
  // ============================================================
  // 🔍 Analogia: Imagine que você vai enviar uma carta.
  //              Você coloca o nome, o endereço e o conteúdo
  //              dentro de um envelope. Essa função faz isso:
  //              pega o movimento e coloca dentro de um "Map"
  //              (um pacote) para enviar ao Firebase.
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId, // Coloca o ID do produto no pacote
      'produtoNome': produtoNome, // Coloca o nome do produto no pacote
      'tipo': tipo, // Coloca o tipo no pacote
      'quantidade': quantidade, // Coloca a quantidade no pacote
      'precoUnitario': precoUnitario, // Coloca o preço (se tiver)
      'observacao': observacao, // Coloca a observação (se tiver)
      'usuarioId': usuarioId, // Coloca o ID do usuário no pacote
      'usuarioEmail': usuarioEmail, // Coloca o e-mail do usuário no pacote
      'createdAt': createdAt.toIso8601String(), // Coloca a data de criação (em formato de texto)
    };
  }

  // ============================================================
  // 🔥 fromMap() — "DESEMPACOTA" O MOVIMENTO QUE VEIO DO FIREBASE
  // ============================================================
  // 🔍 Analogia: Imagine que você recebeu um pacote do correio.
  //              Você abre e tira o nome, o endereço e o conteúdo.
  //              Essa função faz isso: pega os dados que vieram
  //              do Firebase e transforma de volta em um movimento.
  // ============================================================

  factory Movimento.fromMap(String id, Map<String, dynamic> map) {
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

    // 🔥 CRIA O MOVIMENTO COM OS DADOS DO PACOTE
    return Movimento(
      id: id, // O ID é o que veio no pacote
      produtoId: map['produtoId'] ?? '', // Pega o ID do produto, se não tiver, usa vazio
      produtoNome: map['produtoNome'] ?? '', // Pega o nome do produto, se não tiver, usa vazio
      tipo: map['tipo'] ?? '', // Pega o tipo, se não tiver, usa vazio
      quantidade: (map['quantidade'] ?? 0).toDouble(), // Pega a quantidade, se não tiver, usa 0
      precoUnitario: map['precoUnitario']?.toDouble(), // Pega o preço (se tiver)
      observacao: map['observacao'], // Pega a observação (se tiver)
      usuarioId: map['usuarioId'] ?? '', // Pega o usuário, se não tiver, usa vazio
      usuarioEmail: map['usuarioEmail'] ?? '', // Pega o e-mail, se não tiver, usa vazio
      createdAt: parseDate(map['createdAt']), // Pega a data e converte
    );
  }

  // ============================================================
  // 🎨 GETTERS — "PERGUNTAS" QUE O MOVIMENTO RESPONDE
  // ============================================================
  // 🔍 Analogia: São como perguntas que você faz ao movimento:
  //              "É entrada ou saída?"
  //              "Qual é o ícone?"
  //              "Qual é a cor?"
  //              "Quanto foi movimentado?"
  //              "Quando aconteceu?"
  // ============================================================

  // 📝 TIPO LABEL: Retorna o tipo em português
  //    Exemplo: "entrada" → "Entrada"
  String get tipoLabel => tipo == 'entrada' ? 'Entrada' : 'Saída';

  // 🎯 TIPO ÍCONE: Retorna o símbolo do tipo
  //    Exemplo: "entrada" → "➕" (mais)
  //              "saida" → "➖" (menos)
  String get tipoIcon => tipo == 'entrada' ? '➕' : '➖';

  // 🎨 TIPO COR: Retorna a cor do tipo
  //    Exemplo: "entrada" → Verde (entrar é bom)
  //              "saida" → Vermelho (sair é perda)
  Color get tipoColor => tipo == 'entrada' ? Colors.green : Colors.red;

  // 🔢 QUANTIDADE SÍMBOLO: Retorna a quantidade com o sinal
  //    Exemplo: 5 → "+5" (entrada)
  //              3 → "-3" (saída)
  String get quantidadeSimbolo => tipo == 'entrada' ? '+$quantidade' : '-$quantidade';

  // 📅 DATA FORMATADA: Retorna a data completa com hora
  //    Exemplo: 28/08/2026 - 14:30
  String get dataFormatada {
    final dia = createdAt.day.toString().padLeft(2, '0'); // Dia com 2 dígitos
    final mes = createdAt.month.toString().padLeft(2, '0'); // Mês com 2 dígitos
    final ano = createdAt.year; // Ano com 4 dígitos
    final hora = createdAt.hour.toString().padLeft(2, '0'); // Hora com 2 dígitos
    final minuto = createdAt.minute.toString().padLeft(2, '0'); // Minuto com 2 dígitos
    return '$dia/$mes/$ano - $hora:$minuto';
  }

  // 📅 DATA APENAS: Retorna só a data (sem hora)
  //    Exemplo: 28/08/2026
  String get dataApenas {
    final dia = createdAt.day.toString().padLeft(2, '0');
    final mes = createdAt.month.toString().padLeft(2, '0');
    final ano = createdAt.year;
    return '$dia/$mes/$ano';
  }

  // 🕐 HORA APENAS: Retorna só a hora (sem data)
  //    Exemplo: 14:30
  String get horaApenas {
    final hora = createdAt.hour.toString().padLeft(2, '0');
    final minuto = createdAt.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  // 💰 PREÇO FORMATADO: Formata o preço com R$
  //    Exemplo: 25.0 → "R$ 25,00"
  //              null → "--" (se não tiver preço)
  String get precoUnitarioFormatado {
    if (precoUnitario == null) return '--'; // Se não tiver preço, mostra "--"
    return 'R\$ ${precoUnitario!.toStringAsFixed(2).replaceAll('.', ',')}'; // Formata com R$
  }

  // 💰 VALOR TOTAL: Calcula o valor total da movimentação
  //    Exemplo: quantidade = 5, precoUnitario = 25.00 → 5 x 25 = 125.00
  double get valorTotal {
    if (precoUnitario == null) return 0; // Se não tiver preço, retorna 0
    return quantidade * precoUnitario!; // Multiplica quantidade pelo preço
  }

  // 💰 VALOR TOTAL FORMATADO: Formata o valor total com R$
  //    Exemplo: 125.0 → "R$ 125,00"
  String get valorTotalFormatado {
    if (precoUnitario == null) return '--'; // Se não tiver preço, mostra "--"
    return 'R\$ ${valorTotal.toStringAsFixed(2).replaceAll('.', ',')}'; // Formata com R$
  }

  // ✅ IS ENTRADA: Verifica se é uma entrada
  //    Exemplo: "entrada" → true
  bool get isEntrada => tipo == 'entrada';

  // ✅ IS SAÍDA: Verifica se é uma saída
  //    Exemplo: "saida" → true
  bool get isSaida => tipo == 'saida';

  // 📝 DESCRIÇÃO DETALHADA: Cria uma frase descrevendo a movimentação
  //    Exemplo: "entrada de 5.0 unidade(s) do produto 'Cadeira gamer'"
  String get descricaoDetalhada {
    final tipoTexto = tipoLabel.toLowerCase(); // Tipo em minúsculo
    final qtd = quantidade.toStringAsFixed(1); // Quantidade com 1 casa decimal
    return '$tipoTexto de $qtd unidade(s) do produto "$produtoNome"'; // Frase descritiva
  }
}