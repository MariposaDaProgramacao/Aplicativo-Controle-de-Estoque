import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ============================================================
  // 🔥 INICIALIZAR O SERVIÇO DE NOTIFICAÇÃO
  // ============================================================

  static Future<void> initialize() async {
    // Configuração para Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuração para iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    // Configuração geral
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Inicializa as notificações
    await _notifications.initialize(settings);
  }

  // ============================================================
  // 🔥 MOSTRAR NOTIFICAÇÃO
  // ============================================================

  static Future<void> mostrarNotificacao({
    required int id,
    required String titulo,
    required String corpo,
    String? payload,
  }) async {
    // Configuração do canal Android (necessário para Android 8+)
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'estoque_channel', // ID do canal
      'Estoque Baixo', // Nome do canal
      channelDescription: 'Notificações de estoque baixo',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    // Configuração para iOS
    const DarwinNotificationDetails iosDetails =
        DarwinNotificationDetails();

    // Configuração geral
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Mostra a notificação
    await _notifications.show(
      id,
      titulo,
      corpo,
      details,
      payload: payload,
    );
  }

  // ============================================================
  // 🔥 CANCELAR NOTIFICAÇÃO
  // ============================================================

  static Future<void> cancelarNotificacao(int id) async {
    await _notifications.cancel(id);
  }

  // ============================================================
  // 🔥 CANCELAR TODAS AS NOTIFICAÇÕES
  // ============================================================

  static Future<void> cancelarTodas() async {
    await _notifications.cancelAll();
  }
}