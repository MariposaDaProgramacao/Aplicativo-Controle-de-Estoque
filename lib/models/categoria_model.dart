// ============================================================
// 📁 categoria_model.dart O "MOLDE DAS CATEGORIAS"
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você tem uma caixa de ferramentas 
//              onde guarda todas as categorias dos seus produtos 
//              (como "Informática", "Periféricos", "Escritório"). 
//              Esse arquivo é o MANUAL DE INSTRUÇÕES que diz 
//              como cada categoria deve ser criada e guardada.
// 
// 🏠 Ele é como o "molde" para fazer bolachas de categorias.
//    Cada categoria tem:
//    - Um nome (ex: "Informática") → é o sabor da bolacha
//    - Um dono (usuário) → é quem fez a bolacha
//    - Uma data de criação → é quando a bolacha foi assada
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Isso é como chamar os "ajudantes" que vão nos permitir
// usar cores, botões, textos e o banco de dados do Firebase.
import 'package:flutter/material.dart'; // Ajudante para interface (cores, botões)
import 'package:cloud_firestore/cloud_firestore.dart'; // Ajudante para o Firebase

// ============================================================
// 🏠 CLASSE CATEGORIA — O "MOLDE" DA CATEGORIA
// ============================================================
// 🔍 Analogia: É a "forma de biscoito" que usamos para criar
//              categorias. Cada categoria tem:
//              - Um nome (ex: "Informática")
//              - O ID do usuário que criou (para saber de quem é)
//              - A data em que foi criada
// ============================================================

class Categoria {
  // ============================================================
  // 📦 ATRIBUTOS — As "características" da categoria
  // ============================================================
  
  // 🔑 ID: É o "RG" da categoria. Cada categoria tem um único.
  //    Exemplo: "abc123" — é como o número de identidade.
  final String? id;
  
  // 📝 NOME: O nome da categoria.
  //    Exemplo: "Periféricos" — é como o nome da pessoa.
  final String nome;
  
  // 👤 USUÁRIO ID: O "CPF" do dono da categoria.
  //    Isso serve para saber que essa categoria é do João,
  //    e não da Maria. Cada usuário só vê suas próprias categorias.
  final String usuarioId;
  
  // 📅 DATA DE CRIAÇÃO: Quando a categoria foi criada.
  //    Exemplo: 28/08/2026 14:30 — é como a data de nascimento.
  final DateTime createdAt;

  // ============================================================
  // 🏗️ CONSTRUTOR — A "FÁBRICA" QUE CRIA CATEGORIAS
  // ============================================================
  // 🔍 Analogia: É como uma máquina que pega os ingredientes
  //              (nome, usuário, data) e fabrica uma categoria.
  //              O "required" significa que esses ingredientes
  //              são OBRIGATÓRIOS para fazer a categoria.
  // ============================================================

  Categoria({
    this.id, // O ID pode ser opcional (quando a categoria ainda não foi salva no Firebase)
    required this.nome, // O nome é OBRIGATÓRIO
    required this.usuarioId, // O usuário é OBRIGATÓRIO
    required this.createdAt, // A data é OBRIGATÓRIA
  });

  // ============================================================
  // 📦 toMap() — "EMPACOTA" A CATEGORIA PARA ENVIAR AO FIREBASE
  // ============================================================
  // 🔍 Analogia: Imagine que você vai enviar uma carta.
  //              Você coloca o nome, o endereço e o conteúdo
  //              dentro de um envelope. Essa função faz isso:
  //              pega a categoria e coloca dentro de um "Map"
  //              (um pacote) para enviar ao Firebase.
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'nome': nome, // Coloca o nome no pacote
      'usuarioId': usuarioId, // Coloca o ID do usuário no pacote
      'createdAt': createdAt.toIso8601String(), // Coloca a data no pacote (em formato de texto)
    };
  }

  // ============================================================
  // 🔥 fromMap() — "DESEMPACOTA" A CATEGORIA QUE VEIO DO FIREBASE
  // ============================================================
  // 🔍 Analogia: Imagine que você recebeu um pacote do correio.
  //              Você abre e tira o nome, o endereço e o conteúdo.
  //              Essa função faz isso: pega os dados que vieram
  //              do Firebase e transforma de volta em uma categoria.
  // ============================================================

  factory Categoria.fromMap(String id, Map<String, dynamic> map) {
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

    // 🔥 CRIA A CATEGORIA COM OS DADOS DO PACOTE
    return Categoria(
      id: id, // O ID é o que veio no pacote
      nome: map['nome'] ?? '', // Pega o nome do pacote, se não tiver, usa vazio
      usuarioId: map['usuarioId'] ?? '', // Pega o usuário do pacote, se não tiver, usa vazio
      createdAt: parseDate(map['createdAt']), // Pega a data e converte
    );
  }

  // ============================================================
  // 📋 copyWith() — "COPIA" A CATEGORIA COM ALTERAÇÕES
  // ============================================================
  // 🔍 Analogia: Imagine que você tem uma foto sua e quer
  //              fazer uma cópia, mas com um sorriso diferente.
  //              Essa função permite criar uma cópia da categoria
  //              mudando apenas o que você quiser.
  // ============================================================

  Categoria copyWith({
    String? id, // Novo ID (opcional)
    String? nome, // Novo nome (opcional)
    String? usuarioId, // Novo usuário (opcional)
    DateTime? createdAt, // Nova data (opcional)
  }) {
    return Categoria(
      id: id ?? this.id, // Se não passou novo ID, mantém o antigo
      nome: nome ?? this.nome, // Se não passou novo nome, mantém o antigo
      usuarioId: usuarioId ?? this.usuarioId, // Se não passou novo usuário, mantém o antigo
      createdAt: createdAt ?? this.createdAt, // Se não passou nova data, mantém a antiga
    );
  }

  // ============================================================
  // 🎨 GETTERS — "PERGUNTAS" QUE A CATEGORIA RESPONDE
  // ============================================================
  // 🔍 Analogia: São como perguntas que você faz à categoria:
  //              "Qual é o seu nome em maiúsculo?"
  //              "Qual é o seu nome com a primeira letra maiúscula?"
  //              "Você é uma categoria válida?"
  // ============================================================

  // 🔤 NOME MAIÚSCULO: Retorna o nome todo em letras MAIÚSCULAS
  //    Exemplo: "informática" → "INFORMÁTICA"
  String get nomeMaiusculo => nome.toUpperCase();

  // 🔤 NOME CAPITALIZADO: Retorna o nome com a primeira letra maiúscula
  //    Exemplo: "informática" → "Informática"
  String get nomeCapitalizado {
    if (nome.isEmpty) return ''; // Se o nome estiver vazio, retorna vazio
    return nome[0].toUpperCase() + nome.substring(1).toLowerCase(); // Primeira maiúscula, resto minúsculo
  }

  // ✅ VALIDAÇÃO: Verifica se a categoria é válida
  //    Exemplo: "Inf" → true (tem mais de 2 letras)
  //              "I" → false (tem só 1 letra)
  bool get isValid => nome.isNotEmpty && nome.length >= 2;
}

// ============================================================
// 📋 CATEGORIAS PADRÃO — A "LISTA PRONTA" DE CATEGORIAS
// ============================================================
// 🔍 Analogia: Imagine uma "prateleira" com categorias já
//              prontas para usar. O usuário pode escolher
//              uma delas ou criar uma nova.
// ============================================================

class CategoriasPadrao {
  // 📋 LISTA: A lista de categorias que já vem pronta
  //    Analogia: É como um cardápio de restaurante.
  //              O cliente pode escolher uma das opções.
  static const List<String> lista = [
    'Informática', // Categoria 1
    'Periféricos', // Categoria 2
    'Eletrônicos', // Categoria 3
    'Escritório', // Categoria 4
    'Acessórios', // Categoria 5
    'Alimentos', // Categoria 6
    'Bebidas', // Categoria 7
    'Limpeza', // Categoria 8
    'Higiene', // Categoria 9
    'Vestuário', // Categoria 10
    'Calçados', // Categoria 11
    'Livros', // Categoria 12
    'Brinquedos', // Categoria 13
    'Ferramentas', // Categoria 14
    'Automotivo', // Categoria 15
    'Construção', // Categoria 16
    'Outros', // Categoria 17 (para o que não se encaixa em nenhuma)
  ];

  // 🔍 getListaOrdenada(): Retorna a lista em ordem alfabética
  //    Analogia: É como organizar os livros da estante
  //              em ordem alfabética para achar mais fácil.
  static List<String> getListaOrdenada() {
    final listaOrdenada = List<String>.from(lista); // Cria uma cópia da lista
    listaOrdenada.sort(); // Ordena em ordem alfabética
    return listaOrdenada; // Retorna a lista ordenada
  }

  // 🔍 contains(): Verifica se uma categoria existe na lista
  //    Analogia: É como procurar um nome em uma lista de chamada.
  static bool contains(String categoria) {
    return lista.contains(categoria); // Retorna true se encontrar, false se não
  }

  // 🎨 getCorCategoria(): Retorna uma cor para cada categoria
  //    Analogia: É como dar uma cor diferente para cada
  //              tipo de produto, para facilitar a visualização.
  static String getCorCategoria(String categoria) {
    final Map<String, String> cores = {
      'Informática': '#4A90D9', // Azul
      'Periféricos': '#F5A623', // Amarelo
      'Eletrônicos': '#7ED321', // Verde
      'Escritório': '#9B9B9B', // Cinza
      'Acessórios': '#E74C3C', // Vermelho
      'Alimentos': '#F39C12', // Laranja
      'Bebidas': '#3498DB', // Azul claro
      'Limpeza': '#2ECC71', // Verde claro
      'Higiene': '#1ABC9C', // Verde água
      'Vestuário': '#E91E63', // Rosa
      'Calçados': '#795548', // Marrom
      'Livros': '#3F51B5', // Azul escuro
      'Brinquedos': '#FF5722', // Laranja forte
      'Ferramentas': '#607D8B', // Azul cinza
      'Automotivo': '#9E9E9E', // Cinza escuro
      'Construção': '#8D6E63', // Marrom claro
      'Outros': '#757575', // Cinza médio
    };
    return cores[categoria] ?? '#757575'; // Se não encontrar a cor, usa cinza médio
  }
}

// ============================================================
// 🎯 CATEGORIA DROPDOWN HELPER — O "AJUDANTE DO MENU"
// ============================================================
// 🔍 Analogia: Imagine que você tem um "menu de opções"
//              onde o usuário pode escolher a categoria.
//              Esse ajudante prepara as opções para aparecerem
//              nesse menu (dropdown).
// ============================================================

class CategoriaDropdownHelper {
  // 🔍 getDropdownItems(): Cria as opções do menu
  //    Analogia: É como colocar as opções de sabor
  //              de sorvete no menu para o cliente escolher.
  static List<DropdownMenuItem<String>> getDropdownItems() {
    // Para cada categoria da lista, cria uma opção no menu
    return CategoriasPadrao.lista.map((categoria) {
      return DropdownMenuItem<String>(
        value: categoria, // O valor que será salvo (o nome da categoria)
        child: Text(categoria), // O texto que aparece na tela (o nome da categoria)
      );
    }).toList(); // Transforma tudo em uma lista
  }
}