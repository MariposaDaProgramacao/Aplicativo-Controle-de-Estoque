import 'package:flutter/material.dart';
import '../../main.dart';

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
        color: BoxStockColors.campos,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: BoxStockColors.papelaoEscuro.withOpacity(0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
        border: Border.all(
          color: BoxStockColors.papelaoClaro.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: autoFocus,
        style: TextStyle(
          color: BoxStockColors.textoPrincipal,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          // 🔥 APENAS UMA LUPA (via prefixIcon)
          prefixIcon: Icon(
            Icons.search,
            color: BoxStockColors.papelaoMedio,
            size: 22,
          ),
          // 🔥 Botão de limpar (aparece quando tem texto)
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: BoxStockColors.textoPrincipal.withOpacity(0.4),
                    size: 20,
                  ),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                    onClear?.call();
                  },
                  splashRadius: 20,
                )
              : null,
          hintText: hintText ?? '🔍 Buscar produtos...',
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.4),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}