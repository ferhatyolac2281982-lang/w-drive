import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminQuotesScreen extends StatefulWidget {
  const AdminQuotesScreen({super.key});

  @override
  State<AdminQuotesScreen> createState() => _AdminQuotesScreenState();
}

class _AdminQuotesScreenState extends State<AdminQuotesScreen> {
  final supabase = Supabase.instance.client;
  bool loading = true;
  List<Map<String, dynamic>> items = [];

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final data = await supabase
          .from('repair_quotes')
          .select()
          .order('created_at', ascending: false);

      items = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fehler: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await supabase.from('repair_quotes').update({'status': status}).eq('id', id);
      await load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update Fehler: $e')));
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
        title: const Text('Admin: Angebote'),
        actions: [IconButton(onPressed: load, icon: const Icon(Icons.refresh))],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, i) {
                final q = items[i];
                final id = q['id'] as String;
                final cat = (q['category'] ?? '') as String;
                final desc = (q['description'] ?? '') as String;
                final status = (q['status'] ?? '') as String;

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(cat, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(desc.isEmpty ? '(keine Beschreibung)' : desc),
                        const SizedBox(height: 8),
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
                              onPressed: () => updateStatus(id, 'sent'),
                              child: const Text('Angebot gesendet'),
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
