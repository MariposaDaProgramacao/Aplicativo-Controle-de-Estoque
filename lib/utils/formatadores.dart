import 'package:intl/intl.dart';

/// Utilitários de formatação para o BoxStock
/// 
/// Contém funções para formatar valores, datas, moedas,
/// números e textos de forma consistente em todo o app.
class Formatadores {
  // ==================== FORMATAÇÃO DE MOEDA ====================

  /// Formata um valor double para moeda brasileira (R$)
  /// 
  /// [valor] - Valor a ser formatado
  /// [comSimbolo] - Se true, inclui o símbolo R$
  /// 
  /// Exemplo: formatarMoeda(49.90) → 'R$ 49,90'
  static String formatarMoeda(double valor, {bool comSimbolo = true}) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: comSimbolo ? 'R\$ ' : '',
    );
    return formatter.format(valor);
  }

  /// Formata um valor double para moeda sem símbolo
  /// 
  /// Exemplo: formatarMoedaSemSimbolo(49.90) → '49,90'
  static String formatarMoedaSemSimbolo(double valor) {
    return formatarMoeda(valor, comSimbolo: false);
  }

  /// Formata um valor double para moeda com separador de milhar
  /// 
  /// Exemplo: formatarMoedaComMilhar(1234.56) → 'R$ 1.234,56'
  static String formatarMoedaComMilhar(double valor, {bool comSimbolo = true}) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: comSimbolo ? 'R\$ ' : '',
    );
    return formatter.format(valor);
  }

  // ==================== FORMATAÇÃO DE NÚMEROS ====================

  /// Formata um número com separador de milhar
  /// 
  /// Exemplo: formatarNumero(1234567) → '1.234.567'
  static String formatarNumero(num valor) {
    final formatter = NumberFormat.decimalPattern('pt_BR');
    return formatter.format(valor);
  }

  /// Formata um número decimal com casas decimais fixas
  /// 
  /// [valor] - Valor a ser formatado
  /// [casasDecimais] - Número de casas decimais (padrão: 2)
  /// 
  /// Exemplo: formatarDecimal(10.5, 2) → '10,50'
  static String formatarDecimal(double valor, {int casasDecimais = 2}) {
    return valor.toStringAsFixed(casasDecimais).replaceAll('.', ',');
  }

  /// Formata um número para porcentagem
  /// 
  /// [valor] - Valor a ser formatado (ex: 0.25 = 25%)
  /// [casasDecimais] - Número de casas decimais (padrão: 1)
  /// 
  /// Exemplo: formatarPorcentagem(0.25) → '25,0%'
  static String formatarPorcentagem(double valor, {int casasDecimais = 1}) {
    return '${(valor * 100).toStringAsFixed(casasDecimais).replaceAll('.', ',')}%';
  }

  // ==================== FORMATAÇÃO DE DATAS ====================

  /// Formata uma data no formato brasileiro (dd/MM/yyyy)
  /// 
  /// [data] - Data a ser formatada
  /// 
  /// Exemplo: formatarData(DateTime(2026, 8, 20)) → '20/08/2026'
  static String formatarData(DateTime data) {
    return DateFormat('dd/MM/yyyy').format(data);
  }

  /// Formata uma data com hora (dd/MM/yyyy HH:mm)
  /// 
  /// [data] - Data a ser formatada
  /// 
  /// Exemplo: formatarDataHora(DateTime(2026, 8, 20, 14, 30)) → '20/08/2026 14:30'
  static String formatarDataHora(DateTime data) {
    return DateFormat('dd/MM/yyyy HH:mm').format(data);
  }

  /// Formata uma data com hora e minutos (dd/MM/yyyy HH:mm:ss)
  /// 
  /// [data] - Data a ser formatada
  /// 
  /// Exemplo: formatarDataHoraCompleta(DateTime(2026, 8, 20, 14, 30, 15)) → '20/08/2026 14:30:15'
  static String formatarDataHoraCompleta(DateTime data) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(data);
  }

  /// Formata apenas a hora (HH:mm)
  /// 
  /// [data] - Data a ser formatada
  /// 
  /// Exemplo: formatarHora(DateTime(2026, 8, 20, 14, 30)) → '14:30'
  static String formatarHora(DateTime data) {
    return DateFormat('HH:mm').format(data);
  }

  /// Formata uma data por extenso (dd de mês de yyyy)
  /// 
  /// [data] - Data a ser formatada
  /// 
  /// Exemplo: formatarDataExtenso(DateTime(2026, 8, 20)) → '20 de agosto de 2026'
  static String formatarDataExtenso(DateTime data) {
    final meses = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return '${data.day} de ${meses[data.month - 1]} de ${data.year}';
  }

  /// Retorna o nome do mês por extenso
  /// 
  /// [mes] - Número do mês (1-12)
  /// 
  /// Exemplo: getNomeMes(8) → 'agosto'
  static String getNomeMes(int mes) {
    final meses = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return meses[mes - 1];
  }

  /// Formata uma data relativa (ex: "há 2 dias", "agora mesmo")
  /// 
  /// [data] - Data a ser formatada
  /// 
  /// Exemplo: formatarDataRelativa(DateTime.now().subtract(Duration(days: 2))) → 'há 2 dias'
  static String formatarDataRelativa(DateTime data) {
    final agora = DateTime.now();
    final diferenca = agora.difference(data);

    if (diferenca.inSeconds < 60) {
      return 'agora mesmo';
    } else if (diferenca.inMinutes < 60) {
      return 'há ${diferenca.inMinutes} minuto${diferenca.inMinutes > 1 ? 's' : ''}';
    } else if (diferenca.inHours < 24) {
      return 'há ${diferenca.inHours} hora${diferenca.inHours > 1 ? 's' : ''}';
    } else if (diferenca.inDays < 30) {
      return 'há ${diferenca.inDays} dia${diferenca.inDays > 1 ? 's' : ''}';
    } else if (diferenca.inDays < 365) {
      final meses = (diferenca.inDays / 30).floor();
      return 'há $meses mês${meses > 1 ? 'es' : ''}';
    } else {
      final anos = (diferenca.inDays / 365).floor();
      return 'há $anos ano${anos > 1 ? 's' : ''}';
    }
  }

  // ==================== FORMATAÇÃO DE TEXTO ====================

  /// Capitaliza a primeira letra de um texto
  /// 
  /// Exemplo: capitalizar('boxstock') → 'Boxstock'
  static String capitalizar(String texto) {
    if (texto.isEmpty) return texto;
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  /// Capitaliza todas as palavras de um texto
  /// 
  /// Exemplo: capitalizarTodas('controle de estoque') → 'Controle De Estoque'
  static String capitalizarTodas(String texto) {
    if (texto.isEmpty) return texto;
    final palavras = texto.split(' ');
    final capitalizadas = palavras.map((palavra) {
      if (palavra.isEmpty) return palavra;
      return palavra[0].toUpperCase() + palavra.substring(1).toLowerCase();
    });
    return capitalizadas.join(' ');
  }

  /// Limita o tamanho de um texto
  /// 
  /// [texto] - Texto a ser limitado
  /// [limite] - Número máximo de caracteres
  /// [sufixo] - Sufixo a ser adicionado (padrão: '...')
  /// 
  /// Exemplo: limitarTexto('Um texto muito longo', 10) → 'Um texto m...'
  static String limitarTexto(String texto, int limite, {String sufixo = '...'}) {
    if (texto.length <= limite) return texto;
    return '${texto.substring(0, limite)}$sufixo';
  }

  /// Remove espaços extras de um texto
  /// 
  /// Exemplo: removerEspacosExtras('  BoxStock  ') → 'BoxStock'
  static String removerEspacosExtras(String texto) {
    return texto.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Converte um texto para slug (URL amigável)
  /// 
  /// Exemplo: gerarSlug('Controle de Estoque') → 'controle-de-estoque'
  static String gerarSlug(String texto) {
    return texto
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-');
  }

  // ==================== FORMATAÇÃO DE DOCUMENTOS ====================

  /// Formata um CPF (###.###.###-##)
  /// 
  /// [cpf] - CPF sem formatação (apenas números)
  /// 
  /// Exemplo: formatarCPF('12345678909') → '123.456.789-09'
  static String formatarCPF(String cpf) {
    final numeros = cpf.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 11) return cpf;
    return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
  }

  /// Formata um CNPJ (##.###.###/####-##)
  /// 
  /// [cnpj] - CNPJ sem formatação (apenas números)
  /// 
  /// Exemplo: formatarCNPJ('12345678000199') → '12.345.678/0001-99'
  static String formatarCNPJ(String cnpj) {
    final numeros = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 14) return cnpj;
    return '${numeros.substring(0, 2)}.${numeros.substring(2, 5)}.${numeros.substring(5, 8)}/${numeros.substring(8, 12)}-${numeros.substring(12)}';
  }

  /// Formata um telefone (com DDD)
  /// 
  /// [telefone] - Telefone sem formatação (apenas números)
  /// 
  /// Exemplo: formatarTelefone('11999999999') → '(11) 99999-9999'
  static String formatarTelefone(String telefone) {
    final numeros = telefone.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length == 10) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 6)}-${numeros.substring(6)}';
    } else if (numeros.length == 11) {
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7)}';
    }
    return telefone;
  }

  // ==================== FORMATAÇÃO DE ENDEREÇO ====================

  /// Formata um CEP (#####-###)
  /// 
  /// [cep] - CEP sem formatação (apenas números)
  /// 
  /// Exemplo: formatarCEP('12345678') → '12345-678'
  static String formatarCEP(String cep) {
    final numeros = cep.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length != 8) return cep;
    return '${numeros.substring(0, 5)}-${numeros.substring(5)}';
  }

  // ==================== FORMATAÇÃO DE CÓDIGO ====================

  /// Gera um código de barras fictício (para exibição)
  /// 
  /// [prefixo] - Prefixo do código (padrão: 'BOX')
  /// [tamanho] - Tamanho do código (padrão: 8)
  /// 
  /// Exemplo: gerarCodigoBarras() → 'BOX-12345678'
  static String gerarCodigoBarras({String prefixo = 'BOX', int tamanho = 8}) {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final codigo = random.substring(random.length - tamanho);
    return '$prefixo-$codigo';
  }

  /// Gera um código de produto aleatório
  /// 
  /// [prefixo] - Prefixo do código (padrão: 'PRD')
  /// 
  /// Exemplo: gerarCodigoProduto() → 'PRD-20260820-001'
  static String gerarCodigoProduto({String prefixo = 'PRD'}) {
    final now = DateTime.now();
    final data = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final random = (DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0');
    return '$prefixo-$data-$random';
  }

  // ==================== EXEMPLO DE USO ====================
  /*
  // Moeda
  print(Formatadores.formatarMoeda(49.90)); // R$ 49,90
  print(Formatadores.formatarNumero(1234567)); // 1.234.567
  
  // Data
  print(Formatadores.formatarData(DateTime.now())); // 20/08/2026
  print(Formatadores.formatarDataRelativa(DateTime.now().subtract(Duration(days: 2)))); // há 2 dias
  
  // Texto
  print(Formatadores.capitalizarTodas('controle de estoque')); // Controle De Estoque
  print(Formatadores.limitarTexto('Um texto muito longo', 10)); // Um texto m...
  
  // Código
  print(Formatadores.gerarCodigoProduto()); // PRD-20260820-001
  */
}