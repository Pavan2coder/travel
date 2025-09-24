import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';
import 'tabs/tracker_tab.dart';
import 'tabs/history_tab.dart';
import 'tabs/complaints_tab.dart';
import 'tabs/profile_tab.dart';

class HomePage extends StatefulWidget {
  static const route = '/home';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _idx = 0;

  @override
  Widget build(BuildContext context) {
    final stars = context.watch<AppState>().totalStars;
    return Scaffold(
      appBar: AppBar(
        title: const Text('NATPAC Travel'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Row(children: [const Icon(Icons.star, color: Colors.amber), const SizedBox(width: 4), Text('$stars')]))
          )
        ],
      ),
      body: IndexedStack(
        index: _idx,
        children: const [
          TrackerTab(),
          HistoryTab(),
          ComplaintsTab(),
          ProfileTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.navigation), label: 'Tracker'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
          NavigationDestination(icon: Icon(Icons.report), label: 'Complaints'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

