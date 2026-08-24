import 'package:flutter/material.dart';
import 'formatadores.dart';  // ← ADICIONE ESTA LINHA!

/// Utilitários de validação para o BoxStock
class Validadores {
  // ==================== VALIDAÇÃO DE EMAIL ====================

  static String? validarEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Digite seu e-mail';
    }
    final trimmed = email.trim();
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
      return 'Digite um e-mail válido';
    }
    return null;
  }

  static bool isEmailValido(String email) {
    return validarEmail(email) == null;
  }

  // ==================== VALIDAÇÃO DE SENHA ====================

  static String? validarSenha(String? senha) {
    if (senha == null || senha.isEmpty) {
      return 'Digite sua senha';
    }
    if (senha.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres';
    }
    return null;
  }

  static String? validarConfirmacaoSenha(String? senha, String? confirmacao) {
    if (confirmacao == null || confirmacao.isEmpty) {
      return 'Confirme sua senha';
    }
    if (senha != confirmacao) {
      return 'As senhas não coincidem';
    }
    return null;
  }

  static bool isSenhaForte(String senha) {
    return senha.length >= 6;
  }

  // ==================== VALIDAÇÃO DE CAMPOS OBRIGATÓRIOS ====================

  static String? validarObrigatorio(String? valor, {String nome = 'Campo'}) {
    if (valor == null || valor.trim().isEmpty) {
      return '$nome é obrigatório';
    }
    return null;
  }

  static String? validarCampoVazio(String? valor, String nome) {
    return validarObrigatorio(valor, nome: nome);
  }

  // ==================== VALIDAÇÃO DE NÚMEROS ====================

  static String? validarNumero(String? valor, {String nome = 'Valor'}) {
    if (valor == null || valor.isEmpty) {
      return 'Digite o $nome';
    }
    final numero = double.tryParse(valor.replaceAll(',', '.'));
    if (numero == null) {
      return 'Digite um número válido';
    }
    return null;
  }

  static String? validarNumeroPositivo(String? valor, {String nome = 'Valor'}) {
    final erro = validarNumero(valor, nome: nome);
    if (erro != null) return erro;

    final numero = double.tryParse(valor!.replaceAll(',', '.'));
    if (numero != null && numero < 0) {
      return '$nome deve ser positivo';
    }
    return null;
  }

  static String? validarNumeroMaiorQueZero(String? valor, {String nome = 'Valor'}) {
    final erro = validarNumero(valor, nome: nome);
    if (erro != null) return erro;

    final numero = double.tryParse(valor!.replaceAll(',', '.'));
    if (numero != null && numero <= 0) {
      return '$nome deve ser maior que zero';
    }
    return null;
  }

  static String? validarPrecos(double precoCusto, double precoVenda) {
    if (precoVenda < precoCusto) {
      return 'Preço de venda deve ser maior que o preço de custo';
    }
    return null;
  }

  // ==================== VALIDAÇÃO DE QUANTIDADE ====================

  static String? validarSaidaEstoque(double quantidadeSaida, double estoqueDisponivel) {
    if (quantidadeSaida > estoqueDisponivel) {
      return 'Estoque insuficiente!\nDisponível: ${estoqueDisponivel.toStringAsFixed(0)} unidades';
    }
    return null;
  }

  static bool isSaidaValida(double quantidadeSaida, double estoqueDisponivel) {
    return quantidadeSaida <= estoqueDisponivel && quantidadeSaida > 0;
  }

  // ==================== VALIDAÇÃO DE CÓDIGO ====================

  static String? validarCodigoProduto(String? codigo) {
    if (codigo == null || codigo.isEmpty) {
      return 'Digite o código do produto';
    }
    final trimmed = codigo.trim();
    if (trimmed.length < 3) {
      return 'O código deve ter no mínimo 3 caracteres';
    }
    return null;
  }

  // ==================== VALIDAÇÃO DE DATA ====================

  static String? validarDataNaoFutura(DateTime data) {
    if (data.isAfter(DateTime.now())) {
      return 'A data não pode ser futura';
    }
    return null;
  }

  /// 🔥 MÉTODO CORRIGIDO - Agora com o import do Formatadores
  static String? validarDataMaior(DateTime data, DateTime dataReferencia) {
    if (data.isBefore(dataReferencia)) {
      return 'A data deve ser maior que ${Formatadores.formatarData(dataReferencia)}';
    }
    return null;
  }

  // ==================== VALIDAÇÃO DE TEXTO ====================

  static String? validarTamanhoMinimo(String? texto, int minimo, {String nome = 'Campo'}) {
    if (texto == null || texto.trim().isEmpty) {
      return '$nome é obrigatório';
    }
    if (texto.trim().length < minimo) {
      return '$nome deve ter no mínimo $minimo caracteres';
    }
    return null;
  }

  static String? validarTamanhoMaximo(String? texto, int maximo, {String nome = 'Campo'}) {
    if (texto == null) return null;
    if (texto.trim().length > maximo) {
      return '$nome deve ter no máximo $maximo caracteres';
    }
    return null;
  }

  // ==================== VALIDAÇÃO DE URL ====================

  static String? validarURL(String? url) {
    if (url == null || url.isEmpty) return null;
    final pattern = RegExp(
      r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-./?%&=]*)?$',
      caseSensitive: false,
    );
    if (!pattern.hasMatch(url)) {
      return 'Digite uma URL válida';
    }
    return null;
  }

  // ==================== VALIDAÇÃO DE SELEÇÃO ====================

  static String? validarSelecao(dynamic value, {String nome = 'Item'}) {
    if (value == null || value.toString().isEmpty) {
      return 'Selecione um $nome';
    }
    return null;
  }

  // ==================== VALIDAÇÃO DE CONFIRMAÇÃO ====================

  static String? validarConfirmacao(bool confirmado, {String mensagem = 'Confirme para continuar'}) {
    if (!confirmado) {
      return mensagem;
    }
    return null;
  }

  // ==================== VALIDAÇÃO DE CPF ====================

  static String? validarCPF(String? cpf) {
    if (cpf == null || cpf.isEmpty) return null;

    final numeros = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    if (RegExp(r'^(\d)\1+$').hasMatch(numeros)) {
      return 'CPF inválido';
    }

    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(numeros[i]) * (10 - i);
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(numeros[i]) * (11 - i);
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    if (int.parse(numeros[9]) != digito1 || int.parse(numeros[10]) != digito2) {
      return 'CPF inválido';
    }

    return null;
  }

  // ==================== VALIDAÇÃO DE CNPJ ====================

  static String? validarCNPJ(String? cnpj) {
    if (cnpj == null || cnpj.isEmpty) return null;

    final numeros = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }

    if (RegExp(r'^(\d)\1+$').hasMatch(numeros)) {
      return 'CNPJ inválido';
    }

    int soma = 0;
    int peso = 5;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(numeros[i]) * peso;
      peso = peso == 2 ? 9 : peso - 1;
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    soma = 0;
    peso = 6;
    for (int i = 0; i < 13; i++) {
      soma += int.parse(numeros[i]) * peso;
      peso = peso == 2 ? 9 : peso - 1;
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    if (int.parse(numeros[12]) != digito1 || int.parse(numeros[13]) != digito2) {
      return 'CNPJ inválido';
    }

    return null;
  }
}