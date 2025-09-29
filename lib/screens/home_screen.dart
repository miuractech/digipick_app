import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'homepage.dart';
import 'care_tab_screen.dart';
import 'shop_page.dart';
import 'profile_page.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _currentIndex;
  
  void switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  List<Widget> _getPages(bool isManager) {
    if (isManager) {
      return [
        Homepage(),
        const CareTabScreen(),
        const ShopPage(),
        const ProfilePage(),
      ];
    } else {
      return [
        Homepage(),
        const ProfilePage(),
      ];
    }
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  List<BottomNavigationBarItem> _getNavigationItems(bool isManager) {
    if (isManager) {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: ImageIcon(AssetImage('lib/assets/care.png')),
          activeIcon: ImageIcon(AssetImage('lib/assets/care.png')),
          label: 'Care',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          activeIcon: Icon(Icons.shopping_cart),
          label: 'Shop',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          activeIcon: Icon(Icons.menu),
          label: 'Menu',
        ),
      ];
    } else {
      return const [
        BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_outlined),
          activeIcon: Icon(Icons.grid_view),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          activeIcon: Icon(Icons.menu),
          label: 'Menu',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isManager = authProvider.hasManagerRole;
    final pages = _getPages(isManager);
    final navigationItems = _getNavigationItems(isManager);
    
    // Ensure current index is valid for the current role
    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundColor,
        selectedItemColor: AppColors.secondaryAccent,
        unselectedItemColor: AppColors.primaryAccent,
        elevation: 10,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: navigationItems,
      ),
    );
  }

}
