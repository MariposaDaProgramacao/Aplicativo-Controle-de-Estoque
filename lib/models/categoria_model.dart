import 'package:flutter/material.dart';

/// Modelo de Categoria para o BoxStock
class Categoria {
  final String? id;
  final String nome;
  final String usuarioId;
  final DateTime createdAt;

  Categoria({
    this.id,
    required this.nome,
    required this.usuarioId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'usuarioId': usuarioId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Categoria.fromMap(String id, Map<String, dynamic> map) {
    return Categoria(
      id: id,
      nome: map['nome'] ?? '',
      usuarioId: map['usuarioId'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  Categoria copyWith({
    String? id,
    String? nome,
    String? usuarioId,
    DateTime? createdAt,
  }) {
    return Categoria(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      usuarioId: usuarioId ?? this.usuarioId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get nomeMaiusculo => nome.toUpperCase();

  String get nomeCapitalizado {
    if (nome.isEmpty) return '';
    return nome[0].toUpperCase() + nome.substring(1).toLowerCase();
  }

  bool get isValid => nome.isNotEmpty && nome.length >= 2;
}

// ==================== CATEGORIAS PRÉ-DEFINIDAS ====================

class CategoriasPadrao {
  static const List<String> lista = [
    'Informática',
    'Periféricos',
    'Eletrônicos',
    'Escritório',
    'Acessórios',
    'Alimentos',
    'Bebidas',
    'Limpeza',
    'Higiene',
    'Vestuário',
    'Calçados',
    'Livros',
    'Brinquedos',
    'Ferramentas',
    'Automotivo',
    'Construção',
    'Outros',
  ];

  static List<String> getListaOrdenada() {
    final listaOrdenada = List<String>.from(lista);
    listaOrdenada.sort();
    return listaOrdenada;
  }

  static bool contains(String categoria) {
    return lista.contains(categoria);
  }

  static String getCorCategoria(String categoria) {
    final Map<String, String> cores = {
      'Informática': '#4A90D9',
      'Periféricos': '#F5A623',
      'Eletrônicos': '#7ED321',
      'Escritório': '#9B9B9B',
      'Acessórios': '#E74C3C',
      'Alimentos': '#F39C12',
      'Bebidas': '#3498DB',
      'Limpeza': '#2ECC71',
      'Higiene': '#1ABC9C',
      'Vestuário': '#E91E63',
      'Calçados': '#795548',
      'Livros': '#3F51B5',
      'Brinquedos': '#FF5722',
      'Ferramentas': '#607D8B',
      'Automotivo': '#9E9E9E',
      'Construção': '#8D6E63',
      'Outros': '#757575',
    };
    return cores[categoria] ?? '#757575';
  }
}

// ==================== MÉTODO PARA DROPDOWN (SEPARADO) ====================

/// Utilitário para criar itens de dropdown de categorias
class CategoriaDropdownHelper {
  static List<DropdownMenuItem<String>> getDropdownItems() {
    return CategoriasPadrao.lista.map((categoria) {
      return DropdownMenuItem<String>(
        value: categoria,
        child: Text(categoria),
      );
    }).toList();
  }
}