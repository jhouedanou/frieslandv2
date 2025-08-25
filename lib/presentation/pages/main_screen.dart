import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import 'home_calendar_page.dart';
import 'map_page.dart';
import 'pdv_list_page.dart';
import 'profile_page.dart';
import 'create_visit_page.dart';
import 'orders/order_main_page.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  bool _isOrderMode = false; // Pour basculer entre visite et commande
  
  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _bottomNavItems;

  @override
  void initState() {
    super.initState();
    _initializePages();
  }

  void _initializePages() {
    _pages = [
      const HomeCalendarPage(), // Page principale avec calendrier et routing
      const MapPage(showAppBar: false), // Carte OpenStreetMap
      const PDVListPage(), // Liste et création de PDV
      const OrderMainPage(), // Page de commande
      const ProfilePage(), // Profil utilisateur
    ];

    _bottomNavItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today_outlined),
        activeIcon: Icon(Icons.calendar_today),
        label: 'Accueil',
        tooltip: 'Calendrier et routing',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.map_outlined),
        activeIcon: Icon(Icons.map),
        label: 'Carte',
        tooltip: 'Carte Treichville',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.store_outlined),
        activeIcon: Icon(Icons.store),
        label: 'PDV',
        tooltip: 'Gérer les PDV',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.shopping_cart_outlined),
        activeIcon: Icon(Icons.shopping_cart),
        label: 'Commande',
        tooltip: 'Réapprovisionner les PDV',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Profil',
        tooltip: 'Mon profil',
      ),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
  void _createNewVisit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateVisitPage(),
      ),
    );
  }

  void _createNewOrder() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderMainPage(),
      ),
    );
  }

  void _toggleFabMode() {
    setState(() {
      _isOrderMode = !_isOrderMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.local_drink,
                color: Color(0xFFE53E3E),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Bonnet Rouge',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _authService.userName ?? 'Utilisateur',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE53E3E),
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Badge de notification (optionnel)
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                    child: const Text(
                      '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () {
              // TODO: Implémenter les notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications à implémenter')),
              );
            },
            tooltip: 'Notifications',
          ),
          
          // Status de connexion
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_done, 
                    size: 16,
                    color: Colors.green.shade200,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'En ligne',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green.shade200,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bouton principal FAB
          FloatingActionButton(
            onPressed: _isOrderMode ? _createNewOrder : _createNewVisit,
            backgroundColor: const Color(0xFFE53E3E),
            foregroundColor: Colors.white,
            heroTag: "mainFab",
            child: Icon(_isOrderMode ? Icons.shopping_cart : Icons.add),
            tooltip: _isOrderMode ? 'Nouvelle commande' : 'Nouvelle visite',
          ),
          const SizedBox(height: 8),
          // Mini bouton pour basculer le mode
          GestureDetector(
            onTap: _toggleFabMode,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFE53E3E),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isOrderMode ? Icons.edit : Icons.shopping_cart,
                color: const Color(0xFFE53E3E),
                size: 20,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFFE53E3E),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        elevation: 8,
        backgroundColor: Colors.white,
        items: _bottomNavItems,
      ),
    );
  }
}
