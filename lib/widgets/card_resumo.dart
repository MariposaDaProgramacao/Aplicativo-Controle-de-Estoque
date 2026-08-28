// ============================================================
// 📁 card_resumo.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está em um "PAINEL DE CONTROLE"
//              e vê vários "QUADRADINHOS" com informações
//              importantes. Cada quadradinho mostra um número
//              e uma descrição. Esse widget é um desses
//              "QUADRADINHOS" do BoxStock!
// 
// 🏠 Ele é como um "CARD DE RESUMO" reutilizável:
//    - Mostra um ícone (ex: 📦 para produtos)
//    - Mostra um número grande (ex: 15)
//    - Mostra um título (ex: "Total Produtos")
//    - Tem um design bonito estilo caixa de papelão
//    - Pode ser clicado (se quiser)
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir o widget
import 'package:flutter/material.dart';

// ============================================================
// 🏠 CLASSE CARDRESUMO — O "QUADRADINHO DO PAINEL"
// ============================================================
// Linha 5: Define a classe CardResumo
// StatelessWidget = o widget não muda (é fixo)
// 
// 🔍 Analogia: É como um "QUADRADINHO" no painel do carro
//              que mostra uma informação (velocímetro, combustível, etc.)
class CardResumo extends StatelessWidget {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "características" do card
  // ============================================================
  
  // Linha 8: O título que aparece embaixo do número
  // Analogia: É a "ETIQUETA" que diz o que o número significa.
  // Exemplo: "Total Produtos", "Estoque Baixo"
  final String titulo;
  
  // Linha 9: O número grande que aparece no card
  // Analogia: É o "VALOR" que você está medindo.
  // Exemplo: "15" (produtos), "3" (estoque baixo)
  final String valor;
  
  // Linha 10: O ícone que aparece no card
  // Analogia: É o "SÍMBOLO" que representa a informação.
  // Exemplo: Icons.inventory_2, Icons.warning_amber_rounded
  final IconData icone;
  
  // Linha 11: A cor principal do card (ícone e borda)
  // Analogia: É a "COR" que destaca o card.
  // Exemplo: Colors.blue, Colors.orange, Colors.red
  final Color cor;
  
  // Linha 12: A cor de fundo do card (opcional)
  // Analogia: É a "COR DE FUNDO" do quadradinho.
  final Color? backgroundColor;
  
  // Linha 13: Função chamada quando o card é clicado (opcional)
  // Analogia: É o "BOTÃO" que você aperta para ver mais detalhes.
  final VoidCallback? onTap;

  // ============================================================
  // 🏗️ CONSTRUTOR — "CRIA O QUADRADINHO"
  // ============================================================
  // Linha 16-24: O construtor da classe.
  // 
  // 🔍 Analogia: É a "FÁBRICA" que cria o quadradinho com as
  //              características que você pedir.
  const CardResumo({
    super.key,
    required this.titulo, // Obrigatório: o título
    required this.valor, // Obrigatório: o valor
    required this.icone, // Obrigatório: o ícone
    required this.cor, // Obrigatório: a cor
    this.backgroundColor, // Opcional: a cor de fundo
    this.onTap, // Opcional: a função de clique
  });

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI O QUADRADINHO NA TELA"
  // ============================================================
  // Linha 28: A função que constrói o widget na tela.
  @override
  Widget build(BuildContext context) {
    // Linha 29: Retorna um GestureDetector (para detectar cliques)
    // 
    // 🔍 Analogia: É como um "BOTÃO" que você pode apertar.
    return GestureDetector(
      onTap: onTap, // Quando clica, chama a função (se tiver)
      
      // ============================================================
      // 🃏 O CARD — O "QUADRADINHO" EM SI
      // ============================================================
      child: Container(
        // Linha 35: Espaço interno do card
        padding: const EdgeInsets.all(16),
        
        // ============================================================
        // 🎨 DECORAÇÃO — O "ESTILO" DO QUADRADINHO
        // ============================================================
        decoration: BoxDecoration(
          // Linha 38: Cor de fundo (usa a passada ou a padrão)
          color: backgroundColor ?? const Color(0xFFFFE9B3), // Cor creme padrão
          
          // Linha 39: Bordas arredondadas
          borderRadius: BorderRadius.circular(12),
          
          // Linha 40-44: Sombra (efeito 3D "caixa de papelão")
          boxShadow: [
            BoxShadow(
              color: Colors.brown.shade800.withOpacity(0.25), // Cor da sombra
              offset: const Offset(4, 4), // Sombra para baixo e direita
              blurRadius: 6, // Quão embaçada é a sombra
            ),
          ],
          
          // Linha 45-47: Borda (contorno)
          border: Border.all(
            color: Colors.brown.shade300, // Cor marrom
            width: 2, // Espessura da borda
          ),
        ),
        
        // ============================================================
        // 📋 CONTEÚDO DO CARD — O QUE APARECE DENTRO
        // ============================================================
        child: Column(
          // Linha 53: Centraliza o conteúdo verticalmente
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ============================================================
            // 🎯 ÍCONE — O "SÍMBOLO" DO CARD
            // ============================================================
            // Linha 57: Um container com o ícone
            // 
            // 🔍 Analogia: É o "SÍMBOLO" que representa a informação.
            Container(
              padding: const EdgeInsets.all(8), // Espaço interno
              decoration: BoxDecoration(
                color: cor.withOpacity(0.15), // Cor fraca (transparente)
                borderRadius: BorderRadius.circular(10), // Bordas arredondadas
                border: Border.all( // Borda com a cor
                  color: cor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon( // O ícone em si
                icone, // O ícone que foi passado
                color: cor, // A cor que foi passada
                size: 28, // Tamanho do ícone
              ),
            ),
            const SizedBox(height: 8), // Espaço entre o ícone e o número
            
            // ============================================================
            // 🔢 VALOR — O "NÚMERO GRANDE"
            // ============================================================
            // Linha 78: O valor (número grande)
            // 
            // 🔍 Analogia: É o "NÚMERO" que você está medindo.
            Text(
              valor, // O valor que foi passado
              style: TextStyle(
                fontSize: 26, // Tamanho grande
                fontWeight: FontWeight.bold, // Negrito
                color: Colors.brown.shade800, // Cor marrom escuro
                letterSpacing: 0.5, // Espaço entre as letras
              ),
            ),
            const SizedBox(height: 4), // Espaço entre o número e o título
            
            // ============================================================
            // 📝 TÍTULO — A "DESCRIÇÃO" DO CARD
            // ============================================================
            // Linha 92: O título (descrição)
            // 
            // 🔍 Analogia: É a "ETIQUETA" que diz o que o número significa.
            Text(
              titulo, // O título que foi passado
              style: TextStyle(
                fontSize: 13, // Tamanho pequeno
                color: Colors.brown.shade700, // Cor marrom médio
                fontWeight: FontWeight.w500, // Peso médio
              ),
              textAlign: TextAlign.center, // Centralizado
            ),
          ],
        ),
      ),
    );
  }
}