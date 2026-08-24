import 'package:flutter/material.dart';

/// Widget de card de resumo para o Dashboard
/// 
/// Exibe uma informação resumida com ícone, valor e título,
/// seguindo o estilo "caixa de papelão".
class CardResumo extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icone;
  final Color cor;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const CardResumo({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icone,
    required this.cor,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? const Color(0xFFFFE9B3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.shade800.withOpacity(0.25),
              offset: const Offset(4, 4),
              blurRadius: 6,
            ),
          ],
          border: Border.all(
            color: Colors.brown.shade300,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: cor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icone,
                color: cor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            
            // Valor
            Text(
              valor,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            
            // Título
            Text(
              titulo,
              style: TextStyle(
                fontSize: 13,
                color: Colors.brown.shade700,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}