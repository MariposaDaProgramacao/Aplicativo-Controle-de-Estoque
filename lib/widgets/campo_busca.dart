// ============================================================
// 📁 campo_busca.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você está em uma "BIBLIOTECA" e
//              quer encontrar um livro específico. Você usa
//              uma "LUPA" para procurar pelo título.
//              Esse widget é a "LUPA" do BoxStock!
// 
// 🏠 Ele é como um "CAMPO DE PESQUISA" reutilizável:
//    - Tem um ícone de lupa para pesquisar
//    - Tem um botão "X" para limpar a pesquisa
//    - Pode ser usado em várias telas
//    - Tem um design bonito e consistente
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para construir o widget
import 'package:flutter/material.dart';
// Linha 2: Importa as cores do sistema (BoxStockColors)
import '../../main.dart';

// ============================================================
// 🏠 CLASSE CAMPOBUSCA — A "LUPA" DO SISTEMA
// ============================================================
// Linha 5: Define a classe CampoBusca
// StatelessWidget = o widget não muda (não tem estado)
// 
// 🔍 Analogia: É como uma "LUPA" que você pode usar em qualquer lugar.
class CampoBusca extends StatelessWidget {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "características" da lupa
  // ============================================================
  
  // Linha 8: O controlador do campo de texto.
  // Analogia: É o "CADERNO" onde o usuário escreve o que quer procurar.
  final TextEditingController controller;
  
  // Linha 9: Função chamada quando o texto muda.
  // Analogia: É o "SINAL" que avisa que o usuário digitou algo.
  final Function(String) onChanged;
  
  // Linha 10: Texto de exemplo que aparece quando o campo está vazio.
  // Analogia: É a "DICA" que diz "Digite aqui o que você quer procurar".
  final String? hintText;
  
  // Linha 11: Se o campo deve ficar em foco automaticamente.
  // Analogia: É como "JÁ ABRIR A LUPA" quando a tela abre.
  final bool autoFocus;
  
  // Linha 12: Função chamada quando o usuário clica no "X".
  // Analogia: É o "BOTÃO" que limpa a busca.
  final VoidCallback? onClear;

  // ============================================================
  // 🏗️ CONSTRUTOR — "CRIA A LUPA"
  // ============================================================
  // Linha 15-21: O construtor da classe.
  // 
  // Analogia: É a "FÁBRICA" que cria a lupa com as características
  //           que você pedir.
  const CampoBusca({
    super.key,
    required this.controller, // Obrigatório: o controlador
    required this.onChanged, // Obrigatório: a função de mudança
    this.hintText, // Opcional: texto de exemplo
    this.autoFocus = false, // Opcional: foco automático (padrão: false)
    this.onClear, // Opcional: função de limpar
  });

  // ============================================================
  // 🏗️ BUILD — "CONSTRÓI A LUPA NA TELA"
  // ============================================================
  // Linha 25: A função que constrói o widget na tela.
  @override
  Widget build(BuildContext context) {
    // Linha 26: Retorna um Container (a "caixa" da lupa).
    // 
    // 🔍 Analogia: É a "MOLDURA" da lupa.
    return Container(
      // ============================================================
      // 🎨 DECORAÇÃO — O "ESTILO" DA LUPA
      // ============================================================
      decoration: BoxDecoration(
        // Linha 28: Cor de fundo do campo (creme)
        color: BoxStockColors.campos,
        
        // Linha 29: Bordas arredondadas
        borderRadius: BorderRadius.circular(14),
        
        // Linha 30-34: Sombra (efeito 3D)
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4), // Sombra para baixo
            blurRadius: 12,
          ),
        ],
        
        // Linha 35-37: Borda (contorno)
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      
      // ============================================================
      // 📝 CAMPO DE TEXTO — O "ESPAÇO PARA ESCREVER"
      // ============================================================
      child: TextField(
        // Linha 43: O controlador que guarda o texto
        controller: controller,
        
        // Linha 44: A função chamada quando o texto muda
        onChanged: onChanged,
        
        // Linha 45: Se o campo deve ficar em foco automaticamente
        autofocus: autoFocus,
        
        // Linha 46: O estilo do texto (cor e tamanho)
        style: TextStyle(
          color: BoxStockColors.textoPrincipal, // Cor do texto
          fontSize: 16, // Tamanho da fonte
        ),
        
        // ============================================================
        // 🎨 DECORAÇÃO DO CAMPO — "A DECORAÇÃO DA LUPA"
        // ============================================================
        decoration: InputDecoration(
          // ============================================================
          // 🔍 ÍCONE DA LUPA — O "SÍMBOLO DE PESQUISA"
          // ============================================================
          // Linha 56: O ícone de lupa na esquerda
          // 
          // 🔍 Analogia: É o "SÍMBOLO" da lupa que mostra que é uma busca.
          prefixIcon: Icon(
            Icons.search, // Ícone de pesquisa
            color: BoxStockColors.papelaoMedio, // Cor marrom
            size: 22, // Tamanho do ícone
          ),
          
          // ============================================================
          // ❌ BOTÃO DE LIMPAR — O "X" PARA APAGAR
          // ============================================================
          // Linha 63: O botão "X" que aparece quando tem texto
          // 
          // 🔍 Analogia: É o "BOTÃO" que apaga tudo que você escreveu.
          suffixIcon: controller.text.isNotEmpty // Se tem texto...
              ? IconButton( // Mostra o botão "X"
                  icon: Icon(
                    Icons.clear, // Ícone de "X"
                    color: BoxStockColors.textoPrincipal.withOpacity(0.4), // Cor com transparência
                    size: 20,
                  ),
                  onPressed: () { // Quando clica no "X"...
                    controller.clear(); // Limpa o texto
                    onChanged(''); // Chama a função com texto vazio
                    onClear?.call(); // Chama a função opcional de limpar
                  },
                  splashRadius: 20, // Tamanho do efeito ao clicar
                )
              : null, // Se não tem texto, não mostra o botão
          
          // ============================================================
          // 📝 TEXTO DE EXEMPLO — O "HINT"
          // ============================================================
          // Linha 80: O texto que aparece quando o campo está vazio
          // 
          // 🔍 Analogia: É a "DICA" que diz o que fazer.
          hintText: hintText ?? '🔍 Buscar produtos...', // Se não passou, usa o padrão
          hintStyle: TextStyle( // Estilo do texto de exemplo
            color: BoxStockColors.textoPrincipal.withOpacity(0.4), // Cor com transparência
            fontSize: 14, // Tamanho da fonte
          ),
          
          // ============================================================
          // 🚫 SEM BORDA — "A BORDA JÁ ESTÁ NO CONTAINER"
          // ============================================================
          border: InputBorder.none, // Sem borda (já temos no Container)
          
          // ============================================================
          // 📏 ESPAÇAMENTO — "ESPAÇO DENTRO DA LUPA"
          // ============================================================
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, // Espaço nas laterais
            vertical: 14, // Espaço em cima e embaixo
          ),
        ),
      ),
    );
  }
}