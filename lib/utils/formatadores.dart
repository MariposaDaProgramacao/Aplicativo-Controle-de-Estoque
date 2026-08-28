// ============================================================
// 📁 formatadores.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você tem uma "CAIXA DE FERRAMENTAS"
//              com várias ferramentas para arrumar números,
//              datas e textos. Esse arquivo é a "CAIXA DE FERRAMENTAS"
//              do BoxStock!
// 
// 🏠 Ele é como um "ESCRITÓRIO DE FORMATAÇÃO":
//    - Formata moedas (R$)
//    - Formata números (com pontos e vírgulas)
//    - Formata datas (dd/MM/yyyy)
//    - Formata textos (maiúsculas, minúsculas)
//    - Formata CPF, CNPJ, telefone, CEP
//    - Gera códigos aleatórios
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o pacote intl (internacionalização)
// Este pacote ajuda a formatar datas, números e moedas
// de acordo com a localidade (ex: Brasil)
import 'package:intl/intl.dart';

// ============================================================
// 🏠 CLASSE FORMATADORES — A "CAIXA DE FERRAMENTAS"
// ============================================================
// Linha 6: Define a classe Formatadores
// Todos os métodos são "static" (podem ser usados sem criar uma instância)
// 
// 🔍 Analogia: É como uma "CAIXA DE FERRAMENTAS" que você pode
//              usar em qualquer lugar, sem precisar pedir permissão.
class Formatadores {
  
  // ============================================================
  // 💰 FORMATAÇÃO DE MOEDA — "ARRUMANDO O DINHEIRO"
  // ============================================================

  // ============================================================
  // 💰 FORMATAR MOEDA — "COLOCA O R$ E OS CENTAVOS"
  // ============================================================
  // Linha 17: Função que formata um número para moeda brasileira.
  // 
  // 🔍 Analogia: É como "COLOCAR O SÍMBOLO DE DINHEIRO" no valor.
  // 
  // Parâmetros:
  //   - valor: o número a ser formatado (ex: 49.90)
  //   - comSimbolo: se deve incluir o "R$" (padrão: true)
  // 
  // Retorna: uma string formatada (ex: "R$ 49,90")
  // 
  // Exemplo: formatarMoeda(49.90) → "R$ 49,90"
  static String formatarMoeda(double valor, {bool comSimbolo = true}) {
    // Linha 20: Cria um formatador de moeda para o Brasil (pt_BR)
    final formatter = NumberFormat.currency(
      locale: 'pt_BR', // Localidade brasileira
      symbol: comSimbolo ? 'R\$ ' : '', // Coloca "R$" ou deixa vazio
    );
    // Linha 23: Formata o valor e retorna
    return formatter.format(valor);
  }

  // ============================================================
  // 💰 FORMATAR MOEDA SEM SÍMBOLO — "SÓ OS NÚMEROS"
  // ============================================================
  // Linha 28: Função que formata moeda sem o símbolo "R$".
  // 
  // 🔍 Analogia: É como "MOSTRAR SÓ OS NÚMEROS" sem o cifrão.
  // 
  // Exemplo: formatarMoedaSemSimbolo(49.90) → "49,90"
  static String formatarMoedaSemSimbolo(double valor) {
    // Linha 31: Chama formatarMoeda com comSimbolo = false
    return formatarMoeda(valor, comSimbolo: false);
  }

  // ============================================================
  // 💰 FORMATAR MOEDA COM MILHAR — "SEPARA OS MILHARES"
  // ============================================================
  // Linha 36: Função que formata moeda com separador de milhar.
  // 
  // 🔍 Analogia: É como "COLOCAR PONTOS" nos milhares.
  // 
  // Exemplo: formatarMoedaComMilhar(1234.56) → "R$ 1.234,56"
  static String formatarMoedaComMilhar(double valor, {bool comSimbolo = true}) {
    // Linha 39: Cria um formatador de moeda para o Brasil
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: comSimbolo ? 'R\$ ' : '',
    );
    // Linha 42: Formata o valor e retorna
    return formatter.format(valor);
  }

  // ============================================================
  // 🔢 FORMATAÇÃO DE NÚMEROS — "ARRUMANDO OS NÚMEROS"
  // ============================================================

  // ============================================================
  // 🔢 FORMATAR NÚMERO — "SEPARA OS MILHARES"
  // ============================================================
  // Linha 49: Função que formata um número com separador de milhar.
  // 
  // 🔍 Analogia: É como "COLOCAR PONTOS" nos números grandes.
  // 
  // Exemplo: formatarNumero(1234567) → "1.234.567"
  static String formatarNumero(num valor) {
    // Linha 52: Cria um formatador de decimais para o Brasil
    final formatter = NumberFormat.decimalPattern('pt_BR');
    // Linha 53: Formata o valor e retorna
    return formatter.format(valor);
  }

  // ============================================================
  // 🔢 FORMATAR DECIMAL — "ARRUDA AS CASAS DECIMAIS"
  // ============================================================
  // Linha 58: Função que formata um número com casas decimais fixas.
  // 
  // 🔍 Analogia: É como "DECIDIR QUANTAS CASAS DEPOIS DA VÍRGULA".
  // 
  // Parâmetros:
  //   - valor: o número a ser formatado (ex: 10.5)
  //   - casasDecimais: quantas casas depois da vírgula (padrão: 2)
  // 
  // Exemplo: formatarDecimal(10.5, 2) → "10,50"
  static String formatarDecimal(double valor, {int casasDecimais = 2}) {
    // Linha 63: Arredonda para o número de casas e troca ponto por vírgula
    return valor.toStringAsFixed(casasDecimais).replaceAll('.', ',');
  }

  // ============================================================
  // 🔢 FORMATAR PORCENTAGEM — "MOSTRA COMO PORCENTAGEM"
  // ============================================================
  // Linha 68: Função que formata um número como porcentagem.
  // 
  // 🔍 Analogia: É como "MOSTRAR O TAMANHO" em porcentagem.
  // 
  // Parâmetros:
  //   - valor: o número a ser formatado (ex: 0.25 = 25%)
  //   - casasDecimais: quantas casas decimais (padrão: 1)
  // 
  // Exemplo: formatarPorcentagem(0.25) → "25,0%"
  static String formatarPorcentagem(double valor, {int casasDecimais = 1}) {
    // Linha 73: Multiplica por 100, arredonda e adiciona o %
    return '${(valor * 100).toStringAsFixed(casasDecimais).replaceAll('.', ',')}%';
  }

  // ============================================================
  // 📅 FORMATAÇÃO DE DATAS — "ARRUMANDO AS DATAS"
  // ============================================================

  // ============================================================
  // 📅 FORMATAR DATA — "COLOCA A DATA NO FORMATO BRASILEIRO"
  // ============================================================
  // Linha 81: Função que formata uma data no formato dd/MM/yyyy.
  // 
  // 🔍 Analogia: É como "ESCREVER A DATA" no formato que os brasileiros usam.
  // 
  // Exemplo: formatarData(DateTime(2026, 8, 20)) → "20/08/2026"
  static String formatarData(DateTime data) {
    // Linha 84: Usa o DateFormat para formatar no padrão brasileiro
    return DateFormat('dd/MM/yyyy').format(data);
  }

  // ============================================================
  // 📅 FORMATAR DATA E HORA — "DATA COM HORA"
  // ============================================================
  // Linha 89: Função que formata uma data com hora (dd/MM/yyyy HH:mm).
  // 
  // 🔍 Analogia: É como "ESCREVER A DATA E A HORA" juntas.
  // 
  // Exemplo: formatarDataHora(DateTime(2026, 8, 20, 14, 30)) → "20/08/2026 14:30"
  static String formatarDataHora(DateTime data) {
    return DateFormat('dd/MM/yyyy HH:mm').format(data);
  }

  // ============================================================
  // 📅 FORMATAR DATA E HORA COMPLETA — "DATA COM SEGUNDOS"
  // ============================================================
  // Linha 96: Função que formata data com hora e segundos.
  // 
  // Exemplo: formatarDataHoraCompleta(DateTime(2026, 8, 20, 14, 30, 15)) → "20/08/2026 14:30:15"
  static String formatarDataHoraCompleta(DateTime data) {
    return DateFormat('dd/MM/yyyy HH:mm:ss').format(data);
  }

  // ============================================================
  // 🕐 FORMATAR HORA — "SÓ A HORA"
  // ============================================================
  // Linha 103: Função que formata apenas a hora (HH:mm).
  // 
  // Exemplo: formatarHora(DateTime(2026, 8, 20, 14, 30)) → "14:30"
  static String formatarHora(DateTime data) {
    return DateFormat('HH:mm').format(data);
  }

  // ============================================================
  // 📝 FORMATAR DATA POR EXTENSO — "DATA POR ESCRITO"
  // ============================================================
  // Linha 110: Função que formata uma data por extenso.
  // 
  // 🔍 Analogia: É como "ESCREVER A DATA" em palavras.
  // 
  // Exemplo: formatarDataExtenso(DateTime(2026, 8, 20)) → "20 de agosto de 2026"
  static String formatarDataExtenso(DateTime data) {
    // Linha 112: Lista dos meses por extenso
    final meses = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    // Linha 116: Monta a data por extenso
    return '${data.day} de ${meses[data.month - 1]} de ${data.year}';
  }

  // ============================================================
  // 📝 GETNOMEMES — "NOME DO MÊS"
  // ============================================================
  // Linha 121: Função que retorna o nome do mês por extenso.
  // 
  // Exemplo: getNomeMes(8) → "agosto"
  static String getNomeMes(int mes) {
    final meses = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return meses[mes - 1]; // Retorna o mês (1 = janeiro)
  }

  // ============================================================
  // 📅 FORMATAR DATA RELATIVA — "HÁ QUANTO TEMPO"
  // ============================================================
  // Linha 132: Função que formata uma data relativa (ex: "há 2 dias").
  // 
  // 🔍 Analogia: É como "DIZER QUANTO TEMPO PASSOU".
  // 
  // Exemplo: formatarDataRelativa(DateTime.now().subtract(Duration(days: 2))) → "há 2 dias"
  static String formatarDataRelativa(DateTime data) {
    final agora = DateTime.now(); // Data e hora atuais
    final diferenca = agora.difference(data); // Diferença entre agora e a data

    // ============================================================
    // ⏱️ VERIFICA O TIPO DE DIFERENÇA
    // ============================================================
    
    // Linha 138: Se menos de 60 segundos...
    if (diferenca.inSeconds < 60) {
      return 'agora mesmo';
    } 
    // Linha 140: Se menos de 60 minutos...
    else if (diferenca.inMinutes < 60) {
      return 'há ${diferenca.inMinutes} minuto${diferenca.inMinutes > 1 ? 's' : ''}';
    } 
    // Linha 142: Se menos de 24 horas...
    else if (diferenca.inHours < 24) {
      return 'há ${diferenca.inHours} hora${diferenca.inHours > 1 ? 's' : ''}';
    } 
    // Linha 144: Se menos de 30 dias...
    else if (diferenca.inDays < 30) {
      return 'há ${diferenca.inDays} dia${diferenca.inDays > 1 ? 's' : ''}';
    } 
    // Linha 146: Se menos de 365 dias...
    else if (diferenca.inDays < 365) {
      final meses = (diferenca.inDays / 30).floor();
      return 'há $meses mês${meses > 1 ? 'es' : ''}';
    } 
    // Linha 150: Se mais de 365 dias...
    else {
      final anos = (diferenca.inDays / 365).floor();
      return 'há $anos ano${anos > 1 ? 's' : ''}';
    }
  }

  // ============================================================
  // 📝 FORMATAÇÃO DE TEXTO — "ARRUMANDO AS PALAVRAS"
  // ============================================================

  // ============================================================
  // 🔤 CAPITALIZAR — "PRIMEIRA LETRA MAIÚSCULA"
  // ============================================================
  // Linha 161: Função que coloca a primeira letra em maiúsculo.
  // 
  // 🔍 Analogia: É como "COLOCAR A PRIMEIRA LETRA" em maiúsculo.
  // 
  // Exemplo: capitalizar('boxstock') → "Boxstock"
  static String capitalizar(String texto) {
    if (texto.isEmpty) return texto; // Se vazio, retorna vazio
    return texto[0].toUpperCase() + texto.substring(1).toLowerCase();
  }

  // ============================================================
  // 🔤 CAPITALIZAR TODAS — "TODAS AS PALAVRAS COM MAIÚSCULA"
  // ============================================================
  // Linha 170: Função que coloca a primeira letra de cada palavra em maiúsculo.
  // 
  // 🔍 Analogia: É como "COLOCAR CADA PALAVRA" com letra maiúscula.
  // 
  // Exemplo: capitalizarTodas('controle de estoque') → "Controle De Estoque"
  static String capitalizarTodas(String texto) {
    if (texto.isEmpty) return texto; // Se vazio, retorna vazio
    final palavras = texto.split(' '); // Divide as palavras
    final capitalizadas = palavras.map((palavra) {
      if (palavra.isEmpty) return palavra;
      return palavra[0].toUpperCase() + palavra.substring(1).toLowerCase();
    });
    return capitalizadas.join(' '); // Junta as palavras de novo
  }

  // ============================================================
  // ✂️ LIMITAR TEXTO — "CORTA O TEXTO"
  // ============================================================
  // Linha 184: Função que limita o tamanho de um texto.
  // 
  // 🔍 Analogia: É como "CORTAR O TEXTO" quando ele é muito longo.
  // 
  // Parâmetros:
  //   - texto: o texto a ser limitado
  //   - limite: o número máximo de caracteres
  //   - sufixo: o que colocar no final (padrão: '...')
  // 
  // Exemplo: limitarTexto('Um texto muito longo', 10) → "Um texto m..."
  static String limitarTexto(String texto, int limite, {String sufixo = '...'}) {
    if (texto.length <= limite) return texto; // Se não ultrapassou, retorna o texto
    return '${texto.substring(0, limite)}$sufixo'; // Corta e adiciona o sufixo
  }

  // ============================================================
  // 🧹 REMOVER ESPAÇOS EXTRAS — "LIMPA OS ESPAÇOS"
  // ============================================================
  // Linha 195: Função que remove espaços extras de um texto.
  // 
  // 🔍 Analogia: É como "VARRER OS ESPAÇOS" desnecessários.
  // 
  // Exemplo: removerEspacosExtras('  BoxStock  ') → "BoxStock"
  static String removerEspacosExtras(String texto) {
    return texto.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  // ============================================================
  // 🔗 GERAR SLUG — "TEXTO PARA URL"
  // ============================================================
  // Linha 203: Função que converte um texto para slug (URL amigável).
  // 
  // 🔍 Analogia: É como "PREPARAR O TEXTO" para ser usado em uma URL.
  // 
  // Exemplo: gerarSlug('Controle de Estoque') → "controle-de-estoque"
  static String gerarSlug(String texto) {
    return texto
        .toLowerCase() // Tudo minúsculo
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '') // Remove caracteres especiais
        .replaceAll(RegExp(r'\s+'), '-'); // Espaços viram hífens
  }

  // ============================================================
  // 📄 FORMATAÇÃO DE DOCUMENTOS — "ARRUMANDO DOCUMENTOS"
  // ============================================================

  // ============================================================
  // 📄 FORMATAR CPF — "COLOCA PONTOS E TRAÇO"
  // ============================================================
  // Linha 215: Função que formata um CPF (###.###.###-##).
  // 
  // 🔍 Analogia: É como "COLOCAR OS PONTOS E O TRAÇO" no CPF.
  // 
  // Exemplo: formatarCPF('12345678909') → "123.456.789-09"
  static String formatarCPF(String cpf) {
    final numeros = cpf.replaceAll(RegExp(r'[^0-9]'), ''); // Só números
    if (numeros.length != 11) return cpf; // Se não tem 11 dígitos, retorna o original
    return '${numeros.substring(0, 3)}.${numeros.substring(3, 6)}.${numeros.substring(6, 9)}-${numeros.substring(9)}';
  }

  // ============================================================
  // 📄 FORMATAR CNPJ — "COLOCA PONTOS, BARRA E TRAÇO"
  // ============================================================
  // Linha 225: Função que formata um CNPJ (##.###.###/####-##).
  // 
  // Exemplo: formatarCNPJ('12345678000199') → "12.345.678/0001-99"
  static String formatarCNPJ(String cnpj) {
    final numeros = cnpj.replaceAll(RegExp(r'[^0-9]'), ''); // Só números
    if (numeros.length != 14) return cnpj; // Se não tem 14 dígitos, retorna o original
    return '${numeros.substring(0, 2)}.${numeros.substring(2, 5)}.${numeros.substring(5, 8)}/${numeros.substring(8, 12)}-${numeros.substring(12)}';
  }

  // ============================================================
  // 📞 FORMATAR TELEFONE — "COLOCA PARÊNTESES E TRAÇO"
  // ============================================================
  // Linha 235: Função que formata um telefone com DDD.
  // 
  // Exemplo: formatarTelefone('11999999999') → "(11) 99999-9999"
  static String formatarTelefone(String telefone) {
    final numeros = telefone.replaceAll(RegExp(r'[^0-9]'), ''); // Só números
    if (numeros.length == 10) { // Telefone fixo (10 dígitos)
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 6)}-${numeros.substring(6)}';
    } else if (numeros.length == 11) { // Celular (11 dígitos)
      return '(${numeros.substring(0, 2)}) ${numeros.substring(2, 7)}-${numeros.substring(7)}';
    }
    return telefone; // Se não tem formato conhecido, retorna o original
  }

  // ============================================================
  // 📍 FORMATAÇÃO DE ENDEREÇO — "ARRUMANDO O CEP"
  // ============================================================

  // ============================================================
  // 📍 FORMATAR CEP — "COLOCA O TRAÇO"
  // ============================================================
  // Linha 250: Função que formata um CEP (#####-###).
  // 
  // Exemplo: formatarCEP('12345678') → "12345-678"
  static String formatarCEP(String cep) {
    final numeros = cep.replaceAll(RegExp(r'[^0-9]'), ''); // Só números
    if (numeros.length != 8) return cep; // Se não tem 8 dígitos, retorna o original
    return '${numeros.substring(0, 5)}-${numeros.substring(5)}';
  }

  // ============================================================
  // 🏷️ FORMATAÇÃO DE CÓDIGO — "CRIANDO CÓDIGOS"
  // ============================================================

  // ============================================================
  // 🏷️ GERAR CÓDIGO DE BARRAS — "CRIA UM CÓDIGO FICTÍCIO"
  // ============================================================
  // Linha 261: Função que gera um código de barras fictício.
  // 
  // 🔍 Analogia: É como "CRIAR UM CÓDIGO" para identificar um produto.
  // 
  // Parâmetros:
  //   - prefixo: o que vem antes (padrão: 'BOX')
  //   - tamanho: quantos números (padrão: 8)
  // 
  // Exemplo: gerarCodigoBarras() → "BOX-12345678"
  static String gerarCodigoBarras({String prefixo = 'BOX', int tamanho = 8}) {
    final random = DateTime.now().millisecondsSinceEpoch.toString(); // Número aleatório
    final codigo = random.substring(random.length - tamanho); // Pega os últimos números
    return '$prefixo-$codigo';
  }

  // ============================================================
  // 🏷️ GERAR CÓDIGO DE PRODUTO — "CRIA UM CÓDIGO DE PRODUTO"
  // ============================================================
  // Linha 272: Função que gera um código de produto aleatório.
  // 
  // 🔍 Analogia: É como "CRIAR UM CÓDIGO" para o produto.
  // 
  // Exemplo: gerarCodigoProduto() → "PRD-20260820-001"
  static String gerarCodigoProduto({String prefixo = 'PRD'}) {
    final now = DateTime.now(); // Data atual
    final data = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}'; // Data no formato AAAAMMDD
    final random = (DateTime.now().millisecondsSinceEpoch % 1000).toString().padLeft(3, '0'); // Número aleatório de 3 dígitos
    return '$prefixo-$data-$random';
  }

  // ============================================================
  // 📚 EXEMPLOS DE USO — "COMO USAR AS FERRAMENTAS"
  // ============================================================
  // Linha 282: Comentários com exemplos de uso de cada função.
  // 
  // 🔍 Analogia: É como um "MANUAL DE INSTRUÇÕES" para usar as ferramentas.
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