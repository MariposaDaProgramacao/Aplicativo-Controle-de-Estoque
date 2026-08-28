// ============================================================
// 📁 validadores.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você tem um "CONTROLADOR DE ACESSO"
//              na porta do seu estoque. Antes de alguém entrar,
//              ele verifica se a pessoa tem as informações certas.
//              Esse arquivo é o "CONTROLADOR DE ACESSO" do BoxStock!
// 
// 🏠 Ele é como um "SISTEMA DE VALIDAÇÃO":
//    - Verifica se o e-mail é válido
//    - Verifica se a senha tem 6+ caracteres
//    - Verifica se campos obrigatórios estão preenchidos
//    - Verifica se números são positivos
//    - Verifica se CPF e CNPJ são válidos
//    - Verifica se a quantidade de saída é válida
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o Flutter para usar cores e widgets (se necessário)
import 'package:flutter/material.dart';
// Linha 2: Importa o arquivo de formatadores para usar a formatação de datas
import 'formatadores.dart';

// ============================================================
// 🏠 CLASSE VALIDADORES — O "CONTROLADOR DE ACESSO"
// ============================================================
// Linha 6: Define a classe Validadores
// Todos os métodos são "static" (podem ser usados sem criar uma instância)
// 
// 🔍 Analogia: É como um "SEGURANÇA" que verifica tudo antes de deixar passar.
class Validadores {
  
  // ============================================================
  // ✉️ VALIDAÇÃO DE EMAIL — "VERIFICA SE O E-MAIL É VÁLIDO"
  // ============================================================
  
  // ============================================================
  // 📧 VALIDAR EMAIL — "O E-MAIL TEM @ E .COM?"
  // ============================================================
  // Linha 18: Função que valida se o e-mail é válido.
  // 
  // 🔍 Analogia: O segurança verifica se o e-mail tem "@" e "."
  //              Exemplo: "joao@email.com" é válido.
  // 
  // Parâmetros: email (o e-mail a ser verificado)
  // Retorna: null se for válido, ou uma mensagem de erro
  static String? validarEmail(String? email) {
    // Linha 19: Se o e-mail está vazio ou é null...
    if (email == null || email.isEmpty) {
      return 'Digite seu e-mail'; // Mensagem: "Digite seu e-mail"
    }
    
    // Linha 22: Remove espaços em branco no início e no fim
    final trimmed = email.trim();
    
    // Linha 23-24: Verifica se o e-mail tem o formato certo
    // RegExp = Expressão Regular (um "padrão" de busca)
    // ^ = começo da string, $ = fim da string
    // [\w-\.]+ = letras, números, underline, hífen ou ponto
    // @ = o @ é obrigatório
    // ([\w-]+\.)+ = domínio (ex: gmail.com, yahoo.com)
    // [\w-]{2,4} = final (ex: com, br, org)
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(trimmed)) {
      return 'Digite um e-mail válido'; // Mensagem: "Digite um e-mail válido"
    }
    
    // Linha 26: Se passou por todas as verificações, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // ✅ IS EMAIL VALIDO — "PERGUNTA SE O E-MAIL É VÁLIDO"
  // ============================================================
  // Linha 31: Função que retorna true ou false se o e-mail é válido.
  // 
  // 🔍 Analogia: O segurança responde "sim" ou "não" quando perguntado.
  // 
  // Exemplo: isEmailValido('joao@email.com') → true
  static bool isEmailValido(String email) {
    // Linha 34: Se validarEmail retornar null, o e-mail é válido
    return validarEmail(email) == null;
  }

  // ============================================================
  // 🔐 VALIDAÇÃO DE SENHA — "VERIFICA SE A SENHA É FORTE"
  // ============================================================

  // ============================================================
  // 🔐 VALIDAR SENHA — "A SENHA TEM 6+ CARACTERES?"
  // ============================================================
  // Linha 40: Função que valida se a senha é forte o suficiente.
  // 
  // 🔍 Analogia: O segurança verifica se a senha tem pelo menos 6 caracteres.
  // 
  // Parâmetros: senha (a senha a ser verificada)
  // Retorna: null se for válida, ou uma mensagem de erro
  static String? validarSenha(String? senha) {
    // Linha 41: Se a senha está vazia ou é null...
    if (senha == null || senha.isEmpty) {
      return 'Digite sua senha'; // Mensagem: "Digite sua senha"
    }
    
    // Linha 44: Se a senha tem menos de 6 caracteres...
    if (senha.length < 6) {
      return 'A senha deve ter no mínimo 6 caracteres'; // Mensagem de erro
    }
    
    // Linha 46: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 🔐 VALIDAR CONFIRMAÇÃO DE SENHA — "AS SENHAS SÃO IGUAIS?"
  // ============================================================
  // Linha 51: Função que valida se as senhas coincidem.
  // 
  // 🔍 Analogia: O segurança verifica se a senha e a confirmação são iguais.
  // 
  // Parâmetros: senha (a senha original), confirmacao (a confirmação)
  // Retorna: null se forem iguais, ou uma mensagem de erro
  static String? validarConfirmacaoSenha(String? senha, String? confirmacao) {
    // Linha 52: Se a confirmação está vazia ou é null...
    if (confirmacao == null || confirmacao.isEmpty) {
      return 'Confirme sua senha'; // Mensagem: "Confirme sua senha"
    }
    
    // Linha 55: Se a senha e a confirmação são diferentes...
    if (senha != confirmacao) {
      return 'As senhas não coincidem'; // Mensagem: "As senhas não coincidem"
    }
    
    // Linha 57: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // ✅ IS SENHA FORTE — "PERGUNTA SE A SENHA É FORTE"
  // ============================================================
  // Linha 62: Função que retorna true se a senha tem 6+ caracteres.
  // 
  // Exemplo: isSenhaForte('senha123') → true
  static bool isSenhaForte(String senha) {
    return senha.length >= 6; // Retorna true se tiver 6+ caracteres
  }

  // ============================================================
  // 📝 VALIDAÇÃO DE CAMPOS OBRIGATÓRIOS — "O CAMPO ESTÁ PREENCHIDO?"
  // ============================================================

  // ============================================================
  // 📝 VALIDAR OBRIGATÓRIO — "O CAMPO ESTÁ VAZIO?"
  // ============================================================
  // Linha 70: Função que valida se um campo obrigatório está preenchido.
  // 
  // 🔍 Analogia: O segurança verifica se o campo não está em branco.
  // 
  // Parâmetros: valor (o valor do campo), nome (nome do campo)
  // Retorna: null se estiver preenchido, ou uma mensagem de erro
  static String? validarObrigatorio(String? valor, {String nome = 'Campo'}) {
    // Linha 71: Se o valor está vazio ou é null...
    if (valor == null || valor.trim().isEmpty) {
      return '$nome é obrigatório'; // Mensagem: "Nome é obrigatório"
    }
    
    // Linha 73: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 📝 VALIDAR CAMPO VAZIO — "VERIFICA SE O CAMPO ESTÁ VAZIO"
  // ============================================================
  // Linha 78: Função que verifica se um campo está vazio.
  // 
  // Exemplo: validarCampoVazio('', 'Nome') → "Nome é obrigatório"
  static String? validarCampoVazio(String? valor, String nome) {
    return validarObrigatorio(valor, nome: nome);
  }

  // ============================================================
  // 🔢 VALIDAÇÃO DE NÚMEROS — "O NÚMERO É VÁLIDO?"
  // ============================================================

  // ============================================================
  // 🔢 VALIDAR NÚMERO — "ISSO É UM NÚMERO?"
  // ============================================================
  // Linha 86: Função que valida se o valor é um número válido.
  // 
  // 🔍 Analogia: O segurança verifica se o que foi digitado é um número.
  // 
  // Parâmetros: valor (o valor a ser verificado), nome (nome do campo)
  // Retorna: null se for um número válido, ou uma mensagem de erro
  static String? validarNumero(String? valor, {String nome = 'Valor'}) {
    // Linha 87: Se o valor está vazio ou é null...
    if (valor == null || valor.isEmpty) {
      return 'Digite o $nome'; // Mensagem: "Digite o Valor"
    }
    
    // Linha 90: Tenta converter para número (trocando vírgula por ponto)
    final numero = double.tryParse(valor.replaceAll(',', '.'));
    
    // Linha 91: Se não é um número...
    if (numero == null) {
      return 'Digite um número válido'; // Mensagem: "Digite um número válido"
    }
    
    // Linha 93: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 🔢 VALIDAR NÚMERO POSITIVO — "O NÚMERO É POSITIVO?"
  // ============================================================
  // Linha 98: Função que valida se o número é positivo (>= 0).
  // 
  // 🔍 Analogia: O segurança verifica se o número não é negativo.
  // 
  // Parâmetros: valor (o valor a ser verificado), nome (nome do campo)
  // Retorna: null se for positivo, ou uma mensagem de erro
  static String? validarNumeroPositivo(String? valor, {String nome = 'Valor'}) {
    // Linha 99: Primeiro valida se é um número
    final erro = validarNumero(valor, nome: nome);
    if (erro != null) return erro; // Se deu erro, retorna o erro

    // Linha 102: Converte para número
    final numero = double.tryParse(valor!.replaceAll(',', '.'));
    
    // Linha 103: Se o número é negativo...
    if (numero != null && numero < 0) {
      return '$nome deve ser positivo'; // Mensagem: "Valor deve ser positivo"
    }
    
    // Linha 105: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 🔢 VALIDAR NÚMERO MAIOR QUE ZERO — "O NÚMERO É > 0?"
  // ============================================================
  // Linha 110: Função que valida se o número é maior que zero.
  // 
  // 🔍 Analogia: O segurança verifica se o número é positivo e não é zero.
  // 
  // Exemplo: validarNumeroMaiorQueZero('0') → "Valor deve ser maior que zero"
  static String? validarNumeroMaiorQueZero(String? valor, {String nome = 'Valor'}) {
    // Linha 111: Primeiro valida se é um número
    final erro = validarNumero(valor, nome: nome);
    if (erro != null) return erro; // Se deu erro, retorna o erro

    // Linha 114: Converte para número
    final numero = double.tryParse(valor!.replaceAll(',', '.'));
    
    // Linha 115: Se o número é zero ou negativo...
    if (numero != null && numero <= 0) {
      return '$nome deve ser maior que zero'; // Mensagem de erro
    }
    
    // Linha 117: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 💰 VALIDAR PREÇOS — "O PREÇO DE VENDA É MAIOR QUE O DE CUSTO?"
  // ============================================================
  // Linha 122: Função que valida se o preço de venda é maior que o de custo.
  // 
  // 🔍 Analogia: O segurança verifica se você não está vendendo por menos do que comprou.
  // 
  // Parâmetros: precoCusto (preço de custo), precoVenda (preço de venda)
  // Retorna: null se for válido, ou uma mensagem de erro
  static String? validarPrecos(double precoCusto, double precoVenda) {
    // Linha 123: Se o preço de venda é menor que o de custo...
    if (precoVenda < precoCusto) {
      return 'Preço de venda deve ser maior que o preço de custo';
    }
    
    // Linha 125: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 📦 VALIDAÇÃO DE QUANTIDADE — "TEM ESTOQUE SUFICIENTE?"
  // ============================================================

  // ============================================================
  // 📦 VALIDAR SAÍDA ESTOQUE — "VAI SAIR MAIS DO QUE TEM?"
  // ============================================================
  // Linha 131: Função que valida se a saída não é maior que o estoque.
  // 
  // 🔍 Analogia: O segurança verifica se você não está tentando tirar
  //              mais produtos do que tem na prateleira.
  // 
  // Parâmetros: quantidadeSaida (quantidade que vai sair)
  //             estoqueDisponivel (quantidade disponível)
  // Retorna: null se for válido, ou uma mensagem de erro
  static String? validarSaidaEstoque(double quantidadeSaida, double estoqueDisponivel) {
    // Linha 132: Se a saída é maior que o estoque...
    if (quantidadeSaida > estoqueDisponivel) {
      return 'Estoque insuficiente!\nDisponível: ${estoqueDisponivel.toStringAsFixed(0)} unidades';
    }
    
    // Linha 134: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // ✅ IS SAIDA VALIDA — "A SAÍDA É VÁLIDA?"
  // ============================================================
  // Linha 139: Função que retorna true se a saída é válida.
  // 
  // Exemplo: isSaidaValida(3, 5) → true (pode tirar 3 de 5)
  static bool isSaidaValida(double quantidadeSaida, double estoqueDisponivel) {
    return quantidadeSaida <= estoqueDisponivel && quantidadeSaida > 0;
  }

  // ============================================================
  // 🏷️ VALIDAÇÃO DE CÓDIGO — "O CÓDIGO É VÁLIDO?"
  // ============================================================

  // ============================================================
  // 🏷️ VALIDAR CÓDIGO PRODUTO — "O CÓDIGO TEM 3+ CARACTERES?"
  // ============================================================
  // Linha 146: Função que valida se o código do produto é válido.
  // 
  // 🔍 Analogia: O segurança verifica se o código não é muito curto.
  // 
  // Exemplo: validarCodigoProduto('A') → "O código deve ter no mínimo 3 caracteres"
  static String? validarCodigoProduto(String? codigo) {
    // Linha 147: Se o código está vazio ou é null...
    if (codigo == null || codigo.isEmpty) {
      return 'Digite o código do produto'; // Mensagem: "Digite o código do produto"
    }
    
    // Linha 150: Remove espaços em branco
    final trimmed = codigo.trim();
    
    // Linha 151: Se o código tem menos de 3 caracteres...
    if (trimmed.length < 3) {
      return 'O código deve ter no mínimo 3 caracteres';
    }
    
    // Linha 153: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 📅 VALIDAÇÃO DE DATA — "A DATA É VÁLIDA?"
  // ============================================================

  // ============================================================
  // 📅 VALIDAR DATA NÃO FUTURA — "A DATA NÃO É NO FUTURO?"
  // ============================================================
  // Linha 159: Função que valida se a data não é futura.
  // 
  // 🔍 Analogia: O segurança verifica se você não está tentando
  //              registrar algo no futuro.
  // 
  // Exemplo: validarDataNaoFutura(DateTime.now()) → null (válido)
  //          validarDataNaoFutura(DateTime.now().add(Days(1))) → erro
  static String? validarDataNaoFutura(DateTime data) {
    // Linha 160: Se a data é depois de agora...
    if (data.isAfter(DateTime.now())) {
      return 'A data não pode ser futura';
    }
    
    // Linha 162: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 📅 VALIDAR DATA MAIOR — "A DATA É MAIOR QUE A REFERÊNCIA?"
  // ============================================================
  // Linha 168: Função que valida se a data é maior que a data de referência.
  // 
  // 🔍 Analogia: O segurança verifica se a data é depois da data de referência.
  // 
  // Parâmetros: data (a data a ser verificada), dataReferencia (a data de referência)
  // Retorna: null se for válido, ou uma mensagem de erro
  // 
  // Exemplo: validarDataMaior(DateTime(2026, 8, 20), DateTime(2026, 8, 19)) → null
  static String? validarDataMaior(DateTime data, DateTime dataReferencia) {
    // Linha 172: Se a data é antes da data de referência...
    if (data.isBefore(dataReferencia)) {
      // Linha 173: Usa o Formatadores para mostrar a data de referência formatada
      return 'A data deve ser maior que ${Formatadores.formatarData(dataReferencia)}';
    }
    
    // Linha 175: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 📝 VALIDAÇÃO DE TEXTO — "O TEXTO É DO TAMANHO CERTO?"
  // ============================================================

  // ============================================================
  // 📝 VALIDAR TAMANHO MÍNIMO — "O TEXTO TEM X CARACTERES?"
  // ============================================================
  // Linha 181: Função que valida se o texto tem um tamanho mínimo.
  // 
  // 🔍 Analogia: O segurança verifica se o texto não é muito curto.
  // 
  // Parâmetros: texto (o texto a ser verificado), minimo (tamanho mínimo)
  //             nome (nome do campo)
  static String? validarTamanhoMinimo(String? texto, int minimo, {String nome = 'Campo'}) {
    // Linha 182: Se o texto está vazio ou é null...
    if (texto == null || texto.trim().isEmpty) {
      return '$nome é obrigatório';
    }
    
    // Linha 185: Se o texto tem menos que o mínimo...
    if (texto.trim().length < minimo) {
      return '$nome deve ter no mínimo $minimo caracteres';
    }
    
    // Linha 187: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 📝 VALIDAR TAMANHO MÁXIMO — "O TEXTO NÃO É MUITO LONGO?"
  // ============================================================
  // Linha 192: Função que valida se o texto tem um tamanho máximo.
  // 
  // 🔍 Analogia: O segurança verifica se o texto não é muito longo.
  // 
  // Parâmetros: texto (o texto a ser verificado), maximo (tamanho máximo)
  //             nome (nome do campo)
  static String? validarTamanhoMaximo(String? texto, int maximo, {String nome = 'Campo'}) {
    // Linha 193: Se o texto é null, retorna null (sem erro)
    if (texto == null) return null;
    
    // Linha 194: Se o texto tem mais que o máximo...
    if (texto.trim().length > maximo) {
      return '$nome deve ter no máximo $maximo caracteres';
    }
    
    // Linha 196: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 🌐 VALIDAÇÃO DE URL — "A URL É VÁLIDA?"
  // ============================================================

  // ============================================================
  // 🌐 VALIDAR URL — "ISSO É UMA URL?"
  // ============================================================
  // Linha 202: Função que valida se a URL é válida.
  // 
  // 🔍 Analogia: O segurança verifica se o endereço da internet é válido.
  // 
  // Exemplo: validarURL('https://google.com') → null (válido)
  static String? validarURL(String? url) {
    // Linha 203: Se a URL está vazia ou é null, retorna null (sem erro)
    if (url == null || url.isEmpty) return null;
    
    // Linha 204: Expressão regular para validar URL
    final pattern = RegExp(
      r'^(https?:\/\/)?([\w\-]+\.)+[\w\-]+(\/[\w\-./?%&=]*)?$',
      caseSensitive: false,
    );
    
    // Linha 208: Se a URL não corresponde ao padrão...
    if (!pattern.hasMatch(url)) {
      return 'Digite uma URL válida';
    }
    
    // Linha 210: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 🎯 VALIDAÇÃO DE SELEÇÃO — "UM ITEM FOI SELECIONADO?"
  // ============================================================

  // ============================================================
  // 🎯 VALIDAR SELEÇÃO — "ALGO FOI ESCOLHIDO?"
  // ============================================================
  // Linha 216: Função que valida se um item foi selecionado.
  // 
  // 🔍 Analogia: O segurança verifica se você escolheu uma opção.
  // 
  // Parâmetros: value (o valor selecionado), nome (nome do campo)
  // Retorna: null se foi selecionado, ou uma mensagem de erro
  static String? validarSelecao(dynamic value, {String nome = 'Item'}) {
    // Linha 217: Se o valor é null ou está vazio...
    if (value == null || value.toString().isEmpty) {
      return 'Selecione um $nome';
    }
    
    // Linha 219: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // ✅ VALIDAÇÃO DE CONFIRMAÇÃO — "A CONFIRMAÇÃO FOI MARCADA?"
  // ============================================================

  // ============================================================
  // ✅ VALIDAR CONFIRMAÇÃO — "O CHECKBOX FOI MARCADO?"
  // ============================================================
  // Linha 225: Função que valida se a confirmação foi marcada.
  // 
  // 🔍 Analogia: O segurança verifica se você marcou a caixinha de confirmação.
  // 
  // Parâmetros: confirmado (true/false), mensagem (mensagem de erro)
  // Retorna: null se foi confirmado, ou uma mensagem de erro
  static String? validarConfirmacao(bool confirmado, {String mensagem = 'Confirme para continuar'}) {
    // Linha 226: Se não foi confirmado...
    if (!confirmado) {
      return mensagem; // Mensagem: "Confirme para continuar"
    }
    
    // Linha 228: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 🆔 VALIDAÇÃO DE CPF — "O CPF É VÁLIDO?"
  // ============================================================

  // ============================================================
  // 🆔 VALIDAR CPF — "O CPF TEM 11 DÍGITOS E É VÁLIDO?"
  // ============================================================
  // Linha 235: Função que valida se o CPF é válido.
  // 
  // 🔍 Analogia: O segurança verifica se o CPF é um documento válido.
  // 
  // Exemplo: validarCPF('12345678909') → "CPF inválido" (exemplo)
  //          validarCPF('52998224725') → null (válido)
  static String? validarCPF(String? cpf) {
    // Linha 236: Se o CPF está vazio ou é null, retorna null (sem erro)
    if (cpf == null || cpf.isEmpty) return null;

    // Linha 238: Remove tudo que não é número
    final numeros = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Linha 239: Se não tem 11 dígitos...
    if (numeros.length != 11) {
      return 'CPF deve ter 11 dígitos';
    }

    // Linha 242: Verifica se todos os dígitos são iguais (ex: 111.111.111-11)
    // Isso é um CPF inválido.
    if (RegExp(r'^(\d)\1+$').hasMatch(numeros)) {
      return 'CPF inválido';
    }

    // Linha 245-250: Calcula o primeiro dígito verificador
    int soma = 0;
    for (int i = 0; i < 9; i++) {
      soma += int.parse(numeros[i]) * (10 - i);
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    // Linha 253-258: Calcula o segundo dígito verificador
    soma = 0;
    for (int i = 0; i < 10; i++) {
      soma += int.parse(numeros[i]) * (11 - i);
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    // Linha 260: Verifica se os dígitos calculados são iguais aos do CPF
    if (int.parse(numeros[9]) != digito1 || int.parse(numeros[10]) != digito2) {
      return 'CPF inválido';
    }

    // Linha 262: Se passou, retorna null (sem erro)
    return null;
  }

  // ============================================================
  // 🆔 VALIDAÇÃO DE CNPJ — "O CNPJ É VÁLIDO?"
  // ============================================================

  // ============================================================
  // 🆔 VALIDAR CNPJ — "O CNPJ TEM 14 DÍGITOS E É VÁLIDO?"
  // ============================================================
  // Linha 269: Função que valida se o CNPJ é válido.
  // 
  // 🔍 Analogia: O segurança verifica se o CNPJ é um documento válido.
  // 
  // Exemplo: validarCNPJ('12345678000199') → "CNPJ inválido" (exemplo)
  //          validarCNPJ('11222333000181') → null (válido)
  static String? validarCNPJ(String? cnpj) {
    // Linha 270: Se o CNPJ está vazio ou é null, retorna null (sem erro)
    if (cnpj == null || cnpj.isEmpty) return null;

    // Linha 272: Remove tudo que não é número
    final numeros = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Linha 273: Se não tem 14 dígitos...
    if (numeros.length != 14) {
      return 'CNPJ deve ter 14 dígitos';
    }

    // Linha 276: Verifica se todos os dígitos são iguais
    if (RegExp(r'^(\d)\1+$').hasMatch(numeros)) {
      return 'CNPJ inválido';
    }

    // Linha 279-285: Calcula o primeiro dígito verificador
    int soma = 0;
    int peso = 5;
    for (int i = 0; i < 12; i++) {
      soma += int.parse(numeros[i]) * peso;
      peso = peso == 2 ? 9 : peso - 1;
    }
    int resto = soma % 11;
    int digito1 = resto < 2 ? 0 : 11 - resto;

    // Linha 288-294: Calcula o segundo dígito verificador
    soma = 0;
    peso = 6;
    for (int i = 0; i < 13; i++) {
      soma += int.parse(numeros[i]) * peso;
      peso = peso == 2 ? 9 : peso - 1;
    }
    resto = soma % 11;
    int digito2 = resto < 2 ? 0 : 11 - resto;

    // Linha 296: Verifica se os dígitos calculados são iguais aos do CNPJ
    if (int.parse(numeros[12]) != digito1 || int.parse(numeros[13]) != digito2) {
      return 'CNPJ inválido';
    }

    // Linha 298: Se passou, retorna null (sem erro)
    return null;
  }
}