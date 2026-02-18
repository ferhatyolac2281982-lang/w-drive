import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RepairQuoteScreen extends StatefulWidget {
  const RepairQuoteScreen({super.key});

  @override
  State<RepairQuoteScreen> createState() => _RepairQuoteScreenState();
}

class _RepairQuoteScreenState extends State<RepairQuoteScreen> {
  final supabase = Supabase.instance.client;

  String category = 'Allgemein';
  final description = TextEditingController();
  bool loading = false;

  Future<void> submit() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => loading = true);
    try {
      await supabase.from('repair_quotes').insert({
        'user_id': user.id,
        'category': category,
        'description': description.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Angebotsanfrage wurde gesendet.')),
      );
      Navigator.pop(context);
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('DB Fehler: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fehler: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Angebot anfragen')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Kategorie'),
              items: const [
                DropdownMenuItem(value: 'Allgemein', child: Text('Allgemein')),
                DropdownMenuItem(value: 'Karosserie', child: Text('Karosserie / Lack')),
                DropdownMenuItem(value: 'Bremsen', child: Text('Bremsen')),
                DropdownMenuItem(value: 'Motor', child: Text('Motor')),
                DropdownMenuItem(value: 'Elektrik', child: Text('Elektrik')),
                DropdownMenuItem(value: 'Reifen', child: Text('Reifen')),
              ],
              onChanged: (v) => setState(() => category = v ?? 'Allgemein'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: description,
              decoration: const InputDecoration(
                labelText: 'Beschreibung (was soll gemacht werden?)',
              ),
              maxLines: 6,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Angebotsanfrage senden'),
            ),
          ],
        ),
      ),
    );
  }
}
