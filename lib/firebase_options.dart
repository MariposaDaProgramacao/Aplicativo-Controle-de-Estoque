// ============================================================
// 📁 firebase_options.dart
// ============================================================
// 🎯 O QUE É ESSE ARQUIVO?
// 
// 🔍 ANALOGIA: Imagine que você tem um "MAPEAMENTO" de todas
//              as chaves que o BoxStock precisa para se conectar
//              ao Firebase. Esse arquivo é o "CADASTRO DE CHAVES"
//              que diz como falar com o Firebase em cada plataforma.
// 
// 🏠 Ele é como um "TRADUTOR" do Firebase:
//    - Diz quais chaves usar para Android
//    - Diz quais chaves usar para iOS
//    - Diz quais chaves usar para Web
//    - Diz quais chaves usar para Windows
//    - Diz quais chaves usar para macOS
// 
// ⚠️ IMPORTANTE: Este arquivo é GERADO AUTOMATICAMENTE pelo
//    FlutterFire CLI. Não altere manualmente!
// ============================================================

// 🔌 IMPORTANDO AS FERRAMENTAS
// Linha 1-2: Comentário dizendo que o arquivo foi gerado automaticamente
// ignore_for_file: type=lint  // Desativa avisos de tipo
// 
// Linha 3: Importa o FirebaseOptions (o "molde" das opções do Firebase)
// Este pacote define a classe que guarda as configurações.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

// Linha 4-5: Importa as ferramentas para detectar a plataforma
// defaultTargetPlatform = diz se é Android, iOS, Web, etc.
// kIsWeb = diz se é Web
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

// ============================================================
// 🏠 CLASSE DEFAULTFIREBASEOPTIONS — O "MAPEAMENTO DE CHAVES"
// ============================================================
// Linha 12: Define a classe DefaultFirebaseOptions
// 
// 🔍 Analogia: É o "MAPEAMENTO" que diz qual chave usar para cada plataforma.
// 
// Exemplo: Se você está no Android, usa as chaves do Android.
//          Se você está no iOS, usa as chaves do iOS.
class DefaultFirebaseOptions {
  
  // ============================================================
  // 🔑 CURRENTPLATFORM — "QUAL CHAVE USAR AGORA?"
  // ============================================================
  // Linha 14: Função que retorna as opções para a plataforma atual.
  // 
  // 🔍 Analogia: O "TRADUTOR" verifica qual sistema você está usando
  //              e devolve as chaves certas.
  // 
  // Retorna: FirebaseOptions da plataforma atual
  // 
  // static = pode ser chamada sem criar uma instância
  // get = é um getter (pode ser usado como propriedade)
  static FirebaseOptions get currentPlatform {
    // Linha 15-16: Se for Web...
    if (kIsWeb) {
      return web; // Usa as chaves da Web
    }
    
    // Linha 18: Switch que verifica a plataforma
    // 
    // 🔍 Analogia: O "TRADUTOR" olha o sistema e escolhe a chave certa.
    switch (defaultTargetPlatform) {
      // Linha 19-20: Se for Android...
      case TargetPlatform.android:
        return android; // Usa as chaves do Android
        
      // Linha 21-22: Se for iOS...
      case TargetPlatform.iOS:
        return ios; // Usa as chaves do iOS
        
      // Linha 23-24: Se for macOS...
      case TargetPlatform.macOS:
        return macos; // Usa as chaves do macOS
        
      // Linha 25-26: Se for Windows...
      case TargetPlatform.windows:
        return windows; // Usa as chaves do Windows
        
      // Linha 27-31: Se for Linux...
      case TargetPlatform.linux:
        // Linux não é suportado, lança um erro
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
        
      // Linha 32-35: Se for outra plataforma...
      default:
        // Outras plataformas não são suportadas
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ============================================================
  // 🌐 WEB — "AS CHAVES PARA A WEB"
  // ============================================================
  // Linha 38: Define as opções para a Web.
  // 
  // 🔍 Analogia: É o "CARTÃO DE ACESSO" para a versão Web do Firebase.
  // 
  // static = pertence à classe
  // const = não muda (é constante)
  // FirebaseOptions = tipo de dado
  static const FirebaseOptions web = FirebaseOptions(
    // Linha 39: apiKey = a "chave de API" (identifica o projeto)
    // É como o "NÚMERO DE IDENTIFICAÇÃO" do seu projeto.
    apiKey: 'AIzaSyAzIHBUa_6qtlUqpbHbhmPxBZrntauQ6dw',
    
    // Linha 40: appId = o "ID do aplicativo" (identifica o app)
    // É como o "CÓDIGO DE BARRAS" do seu aplicativo.
    appId: '1:1098709745631:web:7a19af25f0356419f48e6a',
    
    // Linha 41: messagingSenderId = o "ID do remetente" (para notificações)
    messagingSenderId: '1098709745631',
    
    // Linha 42: projectId = o "ID do projeto" Firebase
    // É como o "NOME DO PROJETO" no Firebase Console.
    projectId: 'boxstock-c4c33',
    
    // Linha 43: authDomain = o "domínio de autenticação"
    // É a URL para fazer login.
    authDomain: 'boxstock-c4c33.firebaseapp.com',
    
    // Linha 44: storageBucket = o "bucket de armazenamento"
    // Onde as imagens e arquivos são guardados.
    storageBucket: 'boxstock-c4c33.firebasestorage.app',
  );

  // ============================================================
  // 📱 ANDROID — "AS CHAVES PARA O ANDROID"
  // ============================================================
  // Linha 49: Define as opções para o Android.
  // 
  // 🔍 Analogia: É o "CARTÃO DE ACESSO" para a versão Android do Firebase.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAueBg4cGr2CAvlQvahxF7loTjrOSfKrRg',
    appId: '1:1098709745631:android:7f6d67693a0413acf48e6a',
    messagingSenderId: '1098709745631',
    projectId: 'boxstock-c4c33',
    storageBucket: 'boxstock-c4c33.firebasestorage.app',
    // Nota: Android não precisa de authDomain e iosBundleId
  );

  // ============================================================
  // 🍎 IOS — "AS CHAVES PARA O IOS"
  // ============================================================
  // Linha 58: Define as opções para o iOS.
  // 
  // 🔍 Analogia: É o "CARTÃO DE ACESSO" para a versão iOS do Firebase.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDIbG1Ogr0NXAAfL3GlDS3nHSxeG6yIJPE',
    appId: '1:1098709745631:ios:c198941ab82051a2f48e6a',
    messagingSenderId: '1098709745631',
    projectId: 'boxstock-c4c33',
    storageBucket: 'boxstock-c4c33.firebasestorage.app',
    // Linha 65: iosBundleId = o "ID do pacote" iOS
    // É o identificador único do aplicativo na App Store.
    iosBundleId: 'com.example.boxstock',
  );

  // ============================================================
  // 🖥️ MACOS — "AS CHAVES PARA O MACOS"
  // ============================================================
  // Linha 68: Define as opções para o macOS.
  // 
  // 🔍 Analogia: É o "CARTÃO DE ACESSO" para a versão macOS do Firebase.
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDIbG1Ogr0NXAAfL3GlDS3nHSxeG6yIJPE',
    appId: '1:1098709745631:ios:c198941ab82051a2f48e6a',
    messagingSenderId: '1098709745631',
    projectId: 'boxstock-c4c33',
    storageBucket: 'boxstock-c4c33.firebasestorage.app',
    iosBundleId: 'com.example.boxstock', // Mesmo do iOS
  );

  // ============================================================
  // 🪟 WINDOWS — "AS CHAVES PARA O WINDOWS"
  // ============================================================
  // Linha 78: Define as opções para o Windows.
  // 
  // 🔍 Analogia: É o "CARTÃO DE ACESSO" para a versão Windows do Firebase.
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAzIHBUa_6qtlUqpbHbhmPxBZrntauQ6dw',
    appId: '1:1098709745631:web:72083db0fec5319bf48e6a',
    messagingSenderId: '1098709745631',
    projectId: 'boxstock-c4c33',
    authDomain: 'boxstock-c4c33.firebaseapp.com',
    storageBucket: 'boxstock-c4c33.firebasestorage.app',
  );
}