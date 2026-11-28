import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'library_screen.dart';
import 'prepare_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('البيان لتحضير الدروس'),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout),
            onPressed: () => Supabase.instance.client.auth.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 25),
            const Icon(Icons.school, size: 80, color: Color(0xFF075B9A)),
            const SizedBox(height: 15),
            const Text(
              'مرحباً بك في البيان',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'حضّر درسك بذكاء وقدّم حصتك بثقة',
              textAlign: TextAlign.center,
            ),
            if (email.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                email,
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              ),
            ],
            const SizedBox(height: 35),
            FilledButton.icon(
              icon: const Icon(Icons.auto_awesome),
              label: const Text('تحضير درس جديد'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrepareScreen()),
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton.icon(
              icon: const Icon(Icons.library_books),
              label: const Text('مكتبتي'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LibraryScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
