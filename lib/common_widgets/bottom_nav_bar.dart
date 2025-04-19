import 'package:flutter/material.dart';
import 'package:waste_wise/common_widgets/background_image_wrapper.dart';
import 'package:waste_wise/screens/_main_screens/home_main.dart';
import 'package:waste_wise/screens/_main_screens/transaction_page.dart';
import 'package:waste_wise/screens/_main_screens/profile_page.dart';
import 'package:waste_wise/screens/_main_screens/recycled_items_main.dart';
import 'package:waste_wise/screens/_main_screens/waste_pickup_schedule_main.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<Widget> _pages = <Widget>[
    Center(child: HomeMain()),
    Center(child: WastePickupScheduleMain()),
    Center(child: RecycledItemsMain()),
    Center(child: TransactionMain()),
    Center(
      child: ProfilePage(),
    )
  ];

  @override
  Widget build(BuildContext context) {
    return BackgroundImageWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.green[600], // Color for the selected item
          unselectedItemColor: Colors.grey[500], // Color for unselected items
          showUnselectedLabels: false, // Hides unselected labels
          showSelectedLabels: true, // Hides selected labels
          elevation: 15, // Adds shadow effect
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon:
                  Icon(Icons.home, size: 30), // Active icon with larger size
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month, size: 30),
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.store_outlined,
              ),
              activeIcon:
                  Icon(Icons.store, size: 30), // Active icon with larger size
              label: 'Store',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history, size: 30),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person, size: 30),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
