// ============================================================
// 📁 lista_compra_model.dart O "MOLDE DA LISTA DE COMPRAS"
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você tem um "carrinho de compras"
//              onde coloca os produtos que precisa comprar.
//              Esse arquivo é o MANUAL DE INSTRUÇÕES que diz
//              como cada item do carrinho deve ser criado e guardado.
// 
// 🏠 Ele é como o "molde" para fazer itens da lista de compras.
//    Cada item tem:
//    - O produto que precisa ser comprado (ex: "Cadeira gamer")
//    - A quantidade atual em estoque (ex: 2 unidades)
//    - A quantidade que falta para atingir o mínimo (ex: 3 unidades)
//    - Se já foi comprado ou não (ex: false = ainda não comprou)
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Isso é como chamar os "ajudantes" que vão nos permitir
// usar o banco de dados do Firebase.
import 'package:cloud_firestore/cloud_firestore.dart';

// ============================================================
// 🏠 CLASSE LISTACOMPRA — O "MOLDE" DO ITEM DA LISTA DE COMPRAS
// ============================================================
// 🔍 Analogia: É a "forma de biscoito" que usamos para criar
//              itens da lista de compras. Cada item tem:
//              - O ID do produto (para saber qual produto é)
//              - O nome do produto (para mostrar na lista)
//              - O código do produto (para identificar)
//              - A categoria (para organizar)
//              - A quantidade que precisa comprar
//              - A quantidade atual em estoque
//              - O estoque mínimo (para saber quando precisa comprar)
//              - O ID do usuário (para saber de quem é a lista)
//              - Se já foi comprado ou não
//              - A data de criação
//              - A data de atualização
// ============================================================

class ListaCompra {
  // ============================================================
  // 📦 ATRIBUTOS — As "características" do item
  // ============================================================
  
  // 🔑 ID: É o "RG" do item. Cada item tem um único.
  //    Exemplo: "abc123" — é como o número de identidade.
  final String? id;
  
  // 🏷️ PRODUTO ID: É o "CPF" do produto.
  //    Isso serve para saber qual produto está na lista.
  //    Exemplo: "prod_001" — identifica o produto "Cadeira gamer".
  final String produtoId;
  
  // 📝 PRODUTO NOME: O nome do produto que precisa ser comprado.
  //    Exemplo: "Cadeira gamer" — é o que aparece na lista.
  final String produtoNome;
  
  // 🔢 CÓDIGO: O código do produto.
  //    Exemplo: "CG001" — ajuda a identificar o produto.
  final String codigo;
  
  // 📂 CATEGORIA: A categoria do produto.
  //    Exemplo: "Escritório" — ajuda a organizar a compra.
  final String categoria;
  
  // 📦 QUANTIDADE NECESSÁRIA: Quantas unidades você precisa comprar.
  //    Exemplo: 5 — você precisa comprar 5 unidades.
  final double quantidadeNecessaria;
  
  // 📊 QUANTIDADE ATUAL: Quantas unidades você tem no estoque agora.
  //    Exemplo: 2 — você tem 2 unidades no estoque.
  final double quantidadeAtual;
  
  // ⚠️ ESTOQUE MÍNIMO: O mínimo que você deve ter no estoque.
  //    Exemplo: 5 — você não pode ter menos que 5 unidades.
  final double estoqueMinimo;
  
  // 👤 USUÁRIO ID: O "CPF" do dono do item.
  //    Isso serve para saber que esse item é do João,
  //    e não da Maria. Cada usuário só vê seus próprios itens.
  final String usuarioId;
  
  // ✅ COMPRADO: Se o item já foi comprado ou não.
  //    Exemplo: false (ainda não comprou) ou true (já comprou).
  final bool comprado;
  
  // 📅 DATA DE CRIAÇÃO: Quando o item foi criado.
  //    Exemplo: 28/08/2026 14:30 — é como a data de nascimento.
  final DateTime createdAt;
  
  // 📅 DATA DE ATUALIZAÇÃO: Quando o item foi atualizado pela última vez.
  //    Exemplo: 28/08/2026 15:00 — é como a data da última modificação.
  final DateTime? updatedAt;

  // ============================================================
  // 🏗️ CONSTRUTOR — A "FÁBRICA" QUE CRIA ITENS DA LISTA
  // ============================================================
  // 🔍 Analogia: É como uma máquina que pega os ingredientes
  //              (produto, quantidade, usuário, etc.) e fabrica
  //              um item da lista de compras.
  //              O "required" significa que esses ingredientes
  //              são OBRIGATÓRIOS para fazer o item.
  // ============================================================

  ListaCompra({
    this.id, // O ID pode ser opcional (quando o item ainda não foi salvo no Firebase)
    required this.produtoId, // O ID do produto é OBRIGATÓRIO
    required this.produtoNome, // O nome do produto é OBRIGATÓRIO
    required this.codigo, // O código é OBRIGATÓRIO
    required this.categoria, // A categoria é OBRIGATÓRIA
    required this.quantidadeNecessaria, // A quantidade necessária é OBRIGATÓRIA
    required this.quantidadeAtual, // A quantidade atual é OBRIGATÓRIA
    required this.estoqueMinimo, // O estoque mínimo é OBRIGATÓRIO
    required this.usuarioId, // O usuário é OBRIGATÓRIO
    this.comprado = false, // Se não passar, o padrão é "não comprado" (false)
    required this.createdAt, // A data de criação é OBRIGATÓRIA
    this.updatedAt, // A data de atualização é OPCIONAL
  });

  // ============================================================
  // 📦 toMap() — "EMPACOTA" O ITEM PARA ENVIAR AO FIREBASE
  // ============================================================
  // 🔍 Analogia: Imagine que você vai enviar uma carta.
  //              Você coloca o nome, o endereço e o conteúdo
  //              dentro de um envelope. Essa função faz isso:
  //              pega o item da lista e coloca dentro de um "Map"
  //              (um pacote) para enviar ao Firebase.
  // ============================================================

  Map<String, dynamic> toMap() {
    return {
      'produtoId': produtoId, // Coloca o ID do produto no pacote
      'produtoNome': produtoNome, // Coloca o nome do produto no pacote
      'codigo': codigo, // Coloca o código no pacote
      'categoria': categoria, // Coloca a categoria no pacote
      'quantidadeNecessaria': quantidadeNecessaria, // Coloca a quantidade necessária no pacote
      'quantidadeAtual': quantidadeAtual, // Coloca a quantidade atual no pacote
      'estoqueMinimo': estoqueMinimo, // Coloca o estoque mínimo no pacote
      'usuarioId': usuarioId, // Coloca o ID do usuário no pacote
      'comprado': comprado, // Coloca se já foi comprado no pacote
      'createdAt': createdAt.toIso8601String(), // Coloca a data de criação (em formato de texto)
      'updatedAt': updatedAt?.toIso8601String(), // Coloca a data de atualização (se tiver)
    };
  }

  // ============================================================
  // 🔥 fromMap() — "DESEMPACOTA" O ITEM QUE VEIO DO FIREBASE
  // ============================================================
  // 🔍 Analogia: Imagine que você recebeu um pacote do correio.
  //              Você abre e tira o nome, o endereço e o conteúdo.
  //              Essa função faz isso: pega os dados que vieram
  //              do Firebase e transforma de volta em um item
  //              da lista de compras.
  // ============================================================

  factory ListaCompra.fromMap(String id, Map<String, dynamic> map) {
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

    // 🔥 CRIA O ITEM COM OS DADOS DO PACOTE
    return ListaCompra(
      id: id, // O ID é o que veio no pacote
      produtoId: map['produtoId'] ?? '', // Pega o ID do produto, se não tiver, usa vazio
      produtoNome: map['produtoNome'] ?? '', // Pega o nome do produto, se não tiver, usa vazio
      codigo: map['codigo'] ?? '', // Pega o código, se não tiver, usa vazio
      categoria: map['categoria'] ?? '', // Pega a categoria, se não tiver, usa vazio
      quantidadeNecessaria: (map['quantidadeNecessaria'] ?? 0).toDouble(), // Pega a quantidade necessária, se não tiver, usa 0
      quantidadeAtual: (map['quantidadeAtual'] ?? 0).toDouble(), // Pega a quantidade atual, se não tiver, usa 0
      estoqueMinimo: (map['estoqueMinimo'] ?? 0).toDouble(), // Pega o estoque mínimo, se não tiver, usa 0
      usuarioId: map['usuarioId'] ?? '', // Pega o usuário, se não tiver, usa vazio
      comprado: map['comprado'] ?? false, // Pega se foi comprado, se não tiver, usa false
      createdAt: parseDate(map['createdAt']), // Pega a data de criação e converte
      updatedAt: map['updatedAt'] != null ? parseDate(map['updatedAt']) : null, // Pega a data de atualização (se tiver)
    );
  }

  // ============================================================
  // 🎨 GETTERS — "PERGUNTAS" QUE O ITEM RESPONDE
  // ============================================================
  // 🔍 Analogia: São como perguntas que você faz ao item:
  //              "Quanto falta para comprar?"
  //              "Você precisa ser comprado?"
  // ============================================================

  // 📊 QUANTIDADE FALTANTE: Calcula quantas unidades faltam para comprar
  //    🔍 Analogia: É como verificar quantos ingredientes faltam
  //                 para completar a receita.
  //    Exemplo: Estoque mínimo = 5, Quantidade atual = 2
  //             Faltante = 5 - 2 = 3 (você precisa comprar 3 unidades)
  double get quantidadeFaltante {
    final faltante = estoqueMinimo - quantidadeAtual; // Calcula a diferença
    return faltante > 0 ? faltante : 0; // Se for negativo, retorna 0 (não falta nada)
  }

  // 🛒 PRECISA COMPRAR: Verifica se o item precisa ser comprado
  //    🔍 Analogia: É como perguntar "Você precisa ir ao mercado?"
  //                 Se a quantidade atual for menor ou igual ao mínimo
  //                 E se ainda não foi comprado, então precisa comprar.
  //    Exemplo: Quantidade atual = 2, Estoque mínimo = 5, Comprado = false
  //             → true (precisa comprar!)
  bool get precisaComprar => quantidadeAtual <= estoqueMinimo && !comprado;
}