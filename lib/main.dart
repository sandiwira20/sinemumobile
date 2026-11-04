import 'package:flutter/material.dart';
import 'auth_gate.dart';
import 'beranda_page.dart';
import 'akun_page.dart';
import 'notifikasi_page.dart';
import 'maps_page.dart';
import 'login_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const SiNemuApp());
}

class SiNemuApp extends StatelessWidget {
  const SiNemuApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5B4FCF);

    return MaterialApp(
      title: 'SiNemu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          primary: primaryColor,
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
        ),
      ),
      home: const AuthGate(
        authenticatedPage: MainScreen(),
        unauthenticatedPage: LoginPage(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    BerandaPage(),
    MapsPage(),
    NotifikasiPage(),
    AkunPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF5B4FCF);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: primaryColor,
            unselectedItemColor: const Color(0xFF9E9E9E),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'BERANDA',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map_rounded),
                label: 'MAPS',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications_none_rounded),
                activeIcon: Icon(Icons.notifications_rounded),
                label: 'NOTIFIKASI',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'AKUN',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
