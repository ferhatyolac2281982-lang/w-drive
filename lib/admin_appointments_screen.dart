import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAppointmentsScreen extends StatefulWidget {
  const AdminAppointmentsScreen({super.key});

  @override
  State<AdminAppointmentsScreen> createState() => _AdminAppointmentsScreenState();
}

class _AdminAppointmentsScreenState extends State<AdminAppointmentsScreen> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  List<Map<String, dynamic>> items = [];

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final data = await supabase
          .from('appointments')
          .select()
          .order('created_at', ascending: false);

      items = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await supabase.from('appointments').update({'status': status}).eq('id', id);
      await load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update Fehler: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Termine'),
        actions: [
          IconButton(onPressed: load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final a = items[i];
                final id = a['id'] as String;
                final cat = (a['category'] ?? '') as String;
                final date = (a['preferred_date'] ?? '') as String;
                final time = (a['preferred_time'] ?? '') as String;
                final plate = (a['license_plate'] ?? '') as String;
                final status = (a['status'] ?? '') as String;

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$cat • $date $time',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text('Kennzeichen: $plate'),
                        const SizedBox(height: 6),
                        Text('Status: $status'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => updateStatus(id, 'in_progress'),
                              child: const Text('in Bearbeitung'),
                            ),
                            OutlinedButton(
                              onPressed: () => updateStatus(id, 'confirmed'),
                              child: const Text('bestätigt'),
                            ),
                            OutlinedButton(
                              onPressed: () => updateStatus(id, 'done'),
                              child: const Text('erledigt'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
