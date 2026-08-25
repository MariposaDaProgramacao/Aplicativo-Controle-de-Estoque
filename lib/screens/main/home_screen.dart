import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../main.dart'; // 🔥 ADICIONE ESTA LINHA!
import 'dashboard_screen.dart';
import 'listagem_produtos_screen.dart';
import 'entrada_screen.dart';
import 'saida_screen.dart';
import 'historico_screen.dart';
import 'lista_compras_screen.dart';
import 'cadastro_produto_screen.dart';
import '../auth/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  int _selectedIndex = 0;

  final List<Widget> _telas = [
    const DashboardScreen(),
    const ListagemProdutosScreen(),
    const EntradaScreen(),
    const SaidaScreen(),
    const ListaComprasScreen(),
    const HistoricoScreen(),
  ];

  final List<String> _titulos = [
    'BoxStock',
    'Produtos',
    'Entrada',
    'Saída',
    'Compras',
    'Histórico',
  ];

  final List<IconData> _icones = [
    Icons.dashboard,
    Icons.inventory_2,
    Icons.add_box,
    Icons.remove_shopping_cart,
    Icons.shopping_cart,
    Icons.history,
  ];

  final List<IconData> _iconesSelecionados = [
    Icons.dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.add_box_outlined,
    Icons.remove_shopping_cart_outlined,
    Icons.shopping_cart_outlined,
    Icons.history_outlined,
  ];

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('👏 Até logo!'),
        backgroundColor: BoxStockColors.sucesso,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _abrirCadastroProduto() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CadastroProdutoScreen(),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BoxStockColors.fundoPrincipal,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/Logo.png',
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),
            Text(
              _titulos[_selectedIndex],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: BoxStockColors.papelaoMedio,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  BoxStockColors.papelaoClaro,
                  BoxStockColors.papelaoMedio,
                  BoxStockColors.papelaoClaro,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: BoxStockColors.papelaoEscuro.withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ),
      body: _telas[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: BoxStockColors.papelaoEscuro.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: BoxStockColors.papelaoEscuro,
          unselectedItemColor: BoxStockColors.papelaoEscuro.withOpacity(0.4),
          backgroundColor: BoxStockColors.fundoSecundario,
          elevation: 0,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 11,
            color: BoxStockColors.papelaoEscuro.withOpacity(0.4),
          ),
          items: List.generate(_titulos.length, (index) {
            return BottomNavigationBarItem(
              icon: Icon(
                _selectedIndex == index
                    ? _icones[index]
                    : _iconesSelecionados[index],
                size: 26,
              ),
              label: _titulos[index],
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirCadastroProduto,
        backgroundColor: BoxStockColors.acaoPrincipal,
        foregroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: BoxStockColors.papelaoMedio,
            width: 2,
          ),
        ),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}