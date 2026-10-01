import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person_outline)
                    : null,
              ),
              title: Text(user?.displayName ?? 'Pengguna'),
              subtitle: Text(user?.email ?? '-'),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            onPressed: () => auth.signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Keluar'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ],
      ),
    );
  }
}
