import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';

class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({super.key});
  @override
  ConsumerState<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen> {
  final _reason = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  bool _sending = false;

  @override
  void dispose() { _reason.dispose(); super.dispose(); }

  Future<void> _pickDate({required bool start}) async {
    final now = DateTime.now();
    final date = await showDatePicker(context: context, initialDate: start ? (_start ?? now) : (_end ?? _start ?? now), firstDate: DateTime(now.year - 1), lastDate: DateTime(now.year + 2));
    if (date != null) setState(() { if (start) { _start = date; if (_end != null && _end!.isBefore(date)) _end = date; } else { _end = date; } });
  }

  Future<void> _submit() async {
    if (_start == null || _end == null || _reason.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Choose dates and add a reason.')));
      return;
    }
    setState(() => _sending = true);
    try {
      await ref.read(apiClientProvider).post('leave-requests', body: {
        'startDate': _start!.toIso8601String().substring(0, 10),
        'endDate': _end!.toIso8601String().substring(0, 10),
        'reason': _reason.text.trim(),
      });
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Leave request submitted.'))); Navigator.pop(context); }
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not submit request: $error')));
    } finally { if (mounted) setState(() => _sending = false); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Request leave')),
        body: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Plan some time off', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Choose the dates and tell your manager a little more.', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 24),
          _DateTile(label: 'First day', value: _start, onTap: () => _pickDate(start: true)),
          const SizedBox(height: 12),
          _DateTile(label: 'Last day', value: _end, onTap: () => _pickDate(start: false)),
          const SizedBox(height: 18),
          TextField(controller: _reason, minLines: 3, maxLines: 5, decoration: const InputDecoration(labelText: 'Reason', alignLabelWithHint: true, border: OutlineInputBorder())),
          const SizedBox(height: 22),
          FilledButton(onPressed: _sending ? null : _submit, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: const Color(0xFF176B58)), child: _sending ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit request')),
        ]),
      );
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.value, required this.onTap});
  final String label;
  final DateTime? value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(child: ListTile(onTap: onTap, leading: const Icon(Icons.calendar_today_outlined, color: Color(0xFF176B58)), title: Text(label), subtitle: Text(value == null ? 'Select date' : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}'), trailing: const Icon(Icons.chevron_right)));
}
