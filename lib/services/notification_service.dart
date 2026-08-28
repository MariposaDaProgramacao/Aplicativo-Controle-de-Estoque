// ============================================================
// 📁 notification_service.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você tem um "SISTEMA DE ALERTA"
//              na sua loja. Quando um produto está acabando,
//              esse sistema toca um "SINO" para avisar você.
// 
// 🏠 Ele é como o "SINALEIRO" do seu estoque:
//    - Mostra notificações no celular
//    - Avisa quando o estoque está baixo
//    - Pode cancelar notificações
//    - Funciona em Android e iOS
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1: Importa o pacote de notificações locais do Flutter
// Este pacote permite mostrar notificações no celular
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ============================================================
// 🏠 CLASSE NOTIFICATIONSERVICE — O "SINALEIRO"
// ============================================================
// Linha 4: Define a classe NotificationService
// Ela é responsável por mostrar notificações no celular.
// 
// 🔍 Analogia: É o "SINALEIRO" que toca quando algo importante acontece.
// 
// Obs: A classe é "static" (tudo é estático) porque não precisa
//      de uma instância para funcionar. É como um "UTENSÍLIO"
//      que você pode usar em qualquer lugar.
class NotificationService {
  
  // ============================================================
  // 📦 ATRIBUTOS — As "ferramentas" do sineleiro
  // ============================================================
  
  // Linha 8: Instância do FlutterLocalNotificationsPlugin.
  // É o "MOTOR" que faz as notificações funcionarem.
  // 
  // 🔍 Analogia: É como o "ALTO-FALANTE" que emite o som do alerta.
  // 
  // static = pertence à classe, não a uma instância.
  // final = não pode ser alterado depois de criado.
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // 🚀 INICIALIZAR — "LIGA O SISTEMA DE ALERTA"
  // ============================================================
  // Linha 14: Função que inicializa o serviço de notificações.
  // 
  // 🔍 Analogia: É como "LIGAR O ALTO-FALANTE" para que ele
  //              possa emitir sons quando necessário.
  // 
  // Deve ser chamada no início do app (no main.dart).
  // 
  // static = pode ser chamada sem criar uma instância.
  // Future = pode demorar (configuração assíncrona).
  // async = pode esperar.
  static Future<void> initialize() async {
    // ============================================================
    // 📱 CONFIGURAÇÃO PARA ANDROID
    // ============================================================
    // Linha 17-18: Configuração específica para Android.
    // 
    // 🔍 Analogia: É como "AJUSTAR O ALTO-FALANTE" para o sistema Android.
    // 
    // '@mipmap/ic_launcher' = o ícone que aparece na notificação
    // (é o mesmo ícone do app).
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ============================================================
    // 📱 CONFIGURAÇÃO PARA IOS
    // ============================================================
    // Linha 21-22: Configuração específica para iOS.
    // 
    // 🔍 Analogia: É como "AJUSTAR O ALTO-FALANTE" para o sistema iOS.
    // 
    // DarwinInitializationSettings = configuração para iOS/macOS.
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    // ============================================================
    // 🔧 CONFIGURAÇÃO GERAL
    // ============================================================
    // Linha 25-28: Junta as configurações de Android e iOS.
    // 
    // 🔍 Analogia: É como "UNIR OS AJUSTES" para que o alto-falante
    //              funcione em qualquer sistema.
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings, // Configuração do Android
      iOS: iosSettings, // Configuração do iOS
    );

    // ============================================================
    // 🚀 INICIALIZA AS NOTIFICAÇÕES
    // ============================================================
    // Linha 31: Inicializa o plugin com as configurações.
    // 
    // 🔍 Analogia: É como "LIGAR O ALTO-FALANTE" de vez.
    // 
    // Await = espera a inicialização terminar.
    await _notifications.initialize(settings);
  }

  // ============================================================
  // 🔔 MOSTRAR NOTIFICAÇÃO — "TOCA O SINO"
  // ============================================================
  // Linha 36: Função que mostra uma notificação.
  // 
  // 🔍 Analogia: É como "APERTAR O BOTÃO" do sino para tocar.
  // 
  // Parâmetros:
  //   - id: número da notificação (identificador único)
  //   - titulo: o título (ex: "⚠️ Estoque Baixo!")
  //   - corpo: a mensagem (ex: "Produto X está acabando")
  //   - payload: dados extras (opcional)
  // 
  // static = pode ser chamada sem criar uma instância.
  // Future = pode demorar.
  // async = pode esperar.
  static Future<void> mostrarNotificacao({
    required int id, // Obrigatório: identificador da notificação
    required String titulo, // Obrigatório: título da notificação
    required String corpo, // Obrigatório: mensagem da notificação
    String? payload, // Opcional: dados extras
  }) async {
    // ============================================================
    // 📱 CONFIGURAÇÃO DO CANAL ANDROID
    // ============================================================
    // Linha 46-54: Configuração do canal para Android 8+.
    // 
    // 🔍 Analogia: É como "CRIAR UMA RÁDIO" para as notificações.
    //              O canal é como a "FREQUÊNCIA" da rádio.
    // 
    // AndroidNotificationDetails = detalhes da notificação no Android.
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'estoque_channel', // ID do canal (identificador único)
      'Estoque Baixo', // Nome do canal (aparece nas configurações)
      channelDescription: 'Notificações de estoque baixo', // Descrição
      importance: Importance.high, // Importância (alta = faz barulho)
      priority: Priority.high, // Prioridade (alta = aparece no topo)
      icon: '@mipmap/ic_launcher', // Ícone que aparece na notificação
    );

    // ============================================================
    // 📱 CONFIGURAÇÃO PARA IOS
    // ============================================================
    // Linha 57-58: Configuração para iOS.
    // 
    // 🔍 Analogia: É como "AJUSTAR O SOM" para o sistema iOS.
    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails();

    // ============================================================
    // 🔧 CONFIGURAÇÃO GERAL DA NOTIFICAÇÃO
    // ============================================================
    // Linha 61-64: Junta as configurações de Android e iOS.
    // 
    // 🔍 Analogia: É como "UNIR OS AJUSTES" para que a notificação
    //              funcione em qualquer sistema.
    const NotificationDetails details = NotificationDetails(
      android: androidDetails, // Configuração do Android
      iOS: iosDetails, // Configuração do iOS
    );

    // ============================================================
    // 📤 MOSTRA A NOTIFICAÇÃO
    // ============================================================
    // Linha 67-73: Mostra a notificação no celular.
    // 
    // 🔍 Analogia: É como "TOCAR O SINO" de vez.
    // 
    // Await = espera a notificação ser mostrada.
    await _notifications.show(
      id, // O ID da notificação
      titulo, // O título (ex: "⚠️ Estoque Baixo!")
      corpo, // O corpo (ex: "Produto X está acabando")
      details, // As configurações
      payload: payload, // Dados extras (opcional)
    );
  }

  // ============================================================
  // ❌ CANCELAR NOTIFICAÇÃO — "SILENCIA O SINO"
  // ============================================================
  // Linha 78: Função que cancela uma notificação específica.
  // 
  // 🔍 Analogia: É como "APAGAR UM ALERTA" que já foi mostrado.
  // 
  // Parâmetros:
  //   - id: o número da notificação a ser cancelada
  // 
  // static = pode ser chamada sem criar uma instância.
  // Future = pode demorar.
  // async = pode esperar.
  static Future<void> cancelarNotificacao(int id) async {
    // Linha 81: Cancela a notificação com o ID especificado.
    // 
    // 🔍 Analogia: O "SINALEIRO" apaga o alerta específico.
    await _notifications.cancel(id);
  }

  // ============================================================
  // ❌ CANCELAR TODAS AS NOTIFICAÇÕES — "SILENCIA TUDO"
  // ============================================================
  // Linha 86: Função que cancela todas as notificações.
  // 
  // 🔍 Analogia: É como "DESLIGAR TODOS OS SONS" de uma vez.
  // 
  // static = pode ser chamada sem criar uma instância.
  // Future = pode demorar.
  // async = pode esperar.
  static Future<void> cancelarTodas() async {
    // Linha 89: Cancela todas as notificações.
    // 
    // 🔍 Analogia: O "SINALEIRO" desliga todos os alertas de uma vez.
    await _notifications.cancelAll();
  }
}