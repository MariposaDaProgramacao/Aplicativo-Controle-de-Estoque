import 'package:flutter/material.dart';

/// Widget de campo de busca com estilo "caixa de papelão"
/// 
/// Utilizado para pesquisar produtos na listagem.
class CampoBusca extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? hintText;
  final bool autoFocus;
  final VoidCallback? onClear;

  const CampoBusca({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.autoFocus = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFE9B3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.shade800.withOpacity(0.2),
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
          // Ícone de busca
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Icon(
              Icons.search,
              color: Colors.brown.shade600,
              size: 22,
            ),
          ),
          
          // Campo de texto
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              autofocus: autoFocus,
              style: TextStyle(
                color: Colors.brown.shade800,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: hintText ?? '🔍 Buscar produtos...',
                hintStyle: TextStyle(
                  color: Colors.brown.shade500,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),
          
          // Botão de limpar (aparece quando tem texto)
          if (controller.text.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.brown.shade600,
                size: 20,
              ),
              onPressed: () {
                controller.clear();
                onChanged('');
                onClear?.call();
              },
              splashRadius: 20,
            ),
          
          // Ícone de lupa (alternativo)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.search_outlined,
              color: Colors.brown.shade400,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}