import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haulier/util.dart';
import 'package:haulier/view_login.dart';
import 'package:haulier/view_user.dart';
import 'package:haulier/widget_buttons.dart';
import 'package:haulier/widget_schedules.dart';
import 'package:haulier/widget_statistic.dart';
import 'package:haulier/widget_trucks.dart';

import 'data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  late final ThemeData theme = Theme.of(context);
  late final ColorScheme scheme = theme.colorScheme;
  late Color navColor = tintColor(scheme.surface, scheme.primary, 3);
  int currentPageIndex = 1;
  final List<String> titles = ['Trucks', 'Overview', 'Schedules'];
  final Map<String, dynamic> user = Data.getCurrentUser();

  Widget? getButton() {
    return (currentPageIndex == 2)
        ? AddScheduleButton(refresh: () => setState(() {}))
        : null;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pageView = [
      TruckListView(refresh: () => setState(() {})),
      const TruckUtilView(),
      // ignore: prefer_const_constructors
      ScheduleListView(),
    ];

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: getNavOverlay(navColor),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UserPage()),
            );
          },
          icon: const Icon(Icons.person),
        ),
        scrolledUnderElevation: 0,
        title: Text(titles[currentPageIndex]),
        centerTitle: true,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        actions: [
          Column(
            children: [
              IconButton(
                onPressed: () {
                  Data.deAuthUser();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: scheme.primary,
      body: pageView[currentPageIndex],
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() => currentPageIndex = index);
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.local_shipping),
            label: 'Trucks',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today),
            label: 'Schedules',
          ),
        ],
      ),
      floatingActionButton: getButton(),
    );
  }
}
