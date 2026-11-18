import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_repository.dart';
import '../profile/profile_provider.dart';
import 'leave_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(employeeProfileProvider);
    final pages = [
      _Dashboard(profile: profile, onLeave: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaveScreen()))),
      const _PlaceholderPage(title: 'My profile', subtitle: 'Keep your employee information up to date.', icon: Icons.person_outline),
      const _PlaceholderPage(title: 'Payslips', subtitle: 'Your latest payslips will appear here.', icon: Icons.receipt_long_outlined),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Payslips'),
        ],
      ),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard({required this.profile, required this.onLeave});
  final AsyncValue<Map<String, dynamic>> profile;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = profile.valueOrNull?['name']?.toString() ?? 'there';
    return ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 28), children: [
      Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('GOOD MORNING', style: Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 1.5, color: Colors.black54)),
          const SizedBox(height: 5),
          Text(name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        ])),
        IconButton.filledTonal(tooltip: 'Sign out', onPressed: () => ref.read(authRepositoryProvider).signOut(), icon: const Icon(Icons.logout)),
      ]),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: const Color(0xFF176B58), borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.wb_sunny_outlined, color: Colors.white70), SizedBox(width: 8), Text('TODAY AT A GLANCE', style: TextStyle(color: Colors.white70, letterSpacing: 1.1, fontSize: 12, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 22),
          const Text('Ready to make it count?', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Your attendance and team updates are just a tap away.', style: TextStyle(color: Colors.white70, height: 1.4)),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connect your attendance endpoint to enable check-in.'))),
            icon: const Icon(Icons.fingerprint),
            label: const Text('Check in'),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54), minimumSize: const Size(140, 46)),
          ),
        ]),
      ),
      const SizedBox(height: 26),
      Text('Quick actions', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 14),
      Row(children: [
        Expanded(child: _ActionCard(icon: Icons.event_available_outlined, title: 'Request leave', color: const Color(0xFFECF5F1), onTap: onLeave)),
        const SizedBox(width: 12),
        Expanded(child: _ActionCard(icon: Icons.receipt_long_outlined, title: 'Payslips', color: const Color(0xFFFFF3E8), onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payslips are coming soon.'))))),
      ]),
      const SizedBox(height: 26),
      Text('Announcements', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Card(child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFEAF2FF), child: Icon(Icons.campaign_outlined, color: Color(0xFF396BC1))), title: const Text('Welcome to ESS', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: const Text('Your employee self-service hub is ready.'))),
    ]);
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.icon, required this.title, required this.color, required this.onTap});
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(padding: const EdgeInsets.all(18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(backgroundColor: color, child: Icon(icon, color: const Color(0xFF176B58))),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ])),
        ),
      );
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 52, color: const Color(0xFF176B58)), const SizedBox(height: 14), Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54))])));
}
