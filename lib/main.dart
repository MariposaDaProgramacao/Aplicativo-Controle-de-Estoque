import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main/home_screen.dart';
import 'services/auth_service.dart';
import 'firebase_options.dart';

// ============================================================
// 🎨 PALETA DE CORES DO BOXSTOCK
// ============================================================
class BoxStockColors {
  // Fundos
  static const Color fundoPrincipal = Color(0xFFFFF1D6);
  static const Color fundoSecundario = Color(0xFFFFE0A3);
  
  // Papelão
  static const Color papelaoClaro = Color(0xFFE9A64A);
  static const Color papelaoMedio = Color(0xFFC97825);
  static const Color papelaoEscuro = Color(0xFF70451F);
  
  // Campos e texto
  static const Color campos = Color(0xFFFFF8EA);
  static const Color textoPrincipal = Color(0xFF3B2A1F);
  
  // Ações e status
  static const Color sucesso = Color(0xFF4CAF50);
  static const Color informacao = Color(0xFF3F6FA8);
  static const Color acaoPrincipal = Color(0xFFF28C18);
  static const Color alerta = Color(0xFFE45745);
  static const Color recursoSecundario = Color(0xFF8064A2);
}

// ============================================================
// 🚀 MAIN
// ============================================================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const BoxStockApp());
}

class BoxStockApp extends StatelessWidget {
  const BoxStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return MaterialApp(
      title: 'BoxStock',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        // ===== CORES PRIMÁRIAS =====
        primaryColor: BoxStockColors.papelaoMedio,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: BoxStockColors.papelaoMedio,
          onPrimary: Colors.white,
          secondary: BoxStockColors.papelaoClaro,
          onSecondary: BoxStockColors.textoPrincipal,
          error: BoxStockColors.alerta,
          onError: Colors.white,
          surface: BoxStockColors.campos,
          onSurface: BoxStockColors.textoPrincipal,
        ),
        scaffoldBackgroundColor: BoxStockColors.fundoPrincipal,

        // ===== APPBAR =====
        appBarTheme: AppBarTheme(
          backgroundColor: BoxStockColors.papelaoMedio,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        // ===== BOTÕES =====
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: BoxStockColors.papelaoMedio,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          ),
        ),

        // ===== CAMPOS DE TEXTO =====
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: BoxStockColors.campos,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: BoxStockColors.papelaoClaro.withOpacity(0.5),
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: BoxStockColors.papelaoClaro.withOpacity(0.5),
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: BoxStockColors.papelaoMedio,
              width: 2.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: BoxStockColors.alerta,
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: BoxStockColors.alerta,
              width: 2.5,
            ),
          ),
          contentPadding: const EdgeInsets.all(16),
          labelStyle: TextStyle(color: BoxStockColors.textoPrincipal),
          hintStyle: TextStyle(
            color: BoxStockColors.textoPrincipal.withOpacity(0.5),
          ),
        ),

        // ===== TEXTOS =====
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
          titleLarge: TextStyle(
            color: BoxStockColors.textoPrincipal,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(color: BoxStockColors.textoPrincipal),
          bodyMedium: TextStyle(color: BoxStockColors.textoPrincipal),
        ),

        // ===== BOTTOM NAVIGATION BAR =====
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: BoxStockColors.fundoSecundario,
          selectedItemColor: BoxStockColors.papelaoEscuro,
          unselectedItemColor: BoxStockColors.papelaoEscuro.withOpacity(0.5),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 8,
          type: BottomNavigationBarType.fixed,
        ),

        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      
      home: StreamBuilder<User?>(
        stream: authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: BoxStockColors.fundoPrincipal,
              body: Center(
                child: CircularProgressIndicator(
                  color: BoxStockColors.papelaoMedio,
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}