import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final supabase = Supabase.instance.client;

  String category = 'Reparatur';
  final vehicleMake = TextEditingController();
  final vehicleModel = TextEditingController();
  final licensePlate = TextEditingController();
  final notes = TextEditingController();

  DateTime? preferredDate;
  final preferredTime = TextEditingController();

  bool loading = false;

  Future<void> submit() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    setState(() => loading = true);
    try {
      await supabase.from('appointments').insert({
        'user_id': user.id,
        'category': category,
        'preferred_date': preferredDate?.toIso8601String().substring(0, 10), // YYYY-MM-DD
        'preferred_time': preferredTime.text.trim(),
        'vehicle_make': vehicleMake.text.trim(),
        'vehicle_model': vehicleModel.text.trim(),
        'license_plate': licensePlate.text.trim(),
        'notes': notes.text.trim(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terminanfrage wurde gesendet.')),
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

  Future<void> pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: preferredDate ?? now,
    );
    if (picked != null) setState(() => preferredDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Termin anfragen')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: 'Kategorie'),
              items: const [
                DropdownMenuItem(value: 'Reparatur', child: Text('Reparatur')),
                DropdownMenuItem(value: 'Inspektion', child: Text('Inspektion')),
                DropdownMenuItem(value: 'Reifen', child: Text('Reifen')),
                DropdownMenuItem(value: 'Bremsen', child: Text('Bremsen')),
              ],
              onChanged: (v) => setState(() => category = v ?? 'Reparatur'),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: pickDate,
                    child: Text(preferredDate == null
                        ? 'Wunschdatum wählen'
                        : 'Datum: ${preferredDate!.toString().substring(0, 10)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: preferredTime,
              decoration: const InputDecoration(labelText: 'Wunschzeit (z.B. 09:00)'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: vehicleMake,
              decoration: const InputDecoration(labelText: 'Marke'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: vehicleModel,
              decoration: const InputDecoration(labelText: 'Modell'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: licensePlate,
              decoration: const InputDecoration(labelText: 'Kennzeichen'),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: notes,
              decoration: const InputDecoration(labelText: 'Beschreibung / Hinweis'),
              maxLines: 4,
            ),
            const SizedBox(height: 20),

            FilledButton(
              onPressed: loading ? null : submit,
              child: loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Terminanfrage senden'),
            ),
          ],
        ),
      ),
    );
  }
}
