import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

// Key passed at launch, never written in the code (never committed)
const apiKey = String.fromEnvironment('GEMINI_KEY');
const model = 'gemini-3.8-flash';

const prompt = '''
You read a pharmacy medication label (Singapore). Extract ONLY what is printed.
Return JSON: {"medications":[{"name":string|null,"strength":string|null,
"form":string|null,"dose":string|null,"times_per_day":int|null,
"when":string|null,"as_needed":bool,"uncertain":[field names you are unsure about]}]}
Abbreviations: OM=morning, ON=night, BD=2x/day, TDS=3x/day, QDS=4x/day,
PRN=as needed, AC=before food, PC=after food.
If a field is unreadable, use null and list it in "uncertain". NEVER guess a strength or dose.
''';

void main() => runApp(const MaterialApp(home: ImportScreen()));

class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});
  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends State<ImportScreen> {
  final List<Map<String, dynamic>> meds = [];
  bool loading = false;
  String? error;

  Future<void> scan() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() { loading = true; error = null; });
    try {
      final bytes = await file.readAsBytes();
      final res = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent'),
        headers: {'Content-Type': 'application/json', 'x-goog-api-key': apiKey},
        body: jsonEncode({
          'contents': [{'parts': [
            {'text': prompt},
            {'inline_data': {'mime_type': file.mimeType ?? 'image/jpeg', 'data': base64Encode(bytes)}},
          ]}],
          'generationConfig': {'responseMimeType': 'application/json'},
        }),
      );
      if (res.statusCode != 200) throw Exception('${res.statusCode}: ${res.body}');
      final text = jsonDecode(res.body)['candidates'][0]['content']['parts'][0]['text'];
      final parsed = jsonDecode(text);
      setState(() => meds.addAll(List<Map<String, dynamic>>.from(parsed['medications'])));
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  // The AI extracts, the CODE decides the schedule (deterministic, testable)
  List<String> scheduleFor(Map<String, dynamic> m) {
    final n = int.tryParse('${m['times_per_day'] ?? ''}');
    final when = '${m['when'] ?? ''}'.toLowerCase();
    if (m['as_needed'] == true) return ['as needed'];
    if (n == 1 && when.contains('night')) return ['21:00'];
    return switch (n) {
      1 => ['09:00'],
      2 => ['09:00', '21:00'],
      3 => ['08:00', '14:00', '20:00'],
      4 => ['08:00', '12:00', '16:00', '20:00'],
      _ => ['TO CHECK'],
    };
  }

  void confirm() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Schedule'),
        content: Text(meds.map((m) =>
          '${m['name']} ${m['strength'] ?? ''} – ${m['dose'] ?? '?'} → ${scheduleFor(m).join(', ')}').join('\n\n')),
      ),
    );
  }

  Widget medCard(Map<String, dynamic> m, int i) {
    final uncertain = List<String>.from(m['uncertain'] ?? []);
    Widget field(String f) => TextFormField(
      key: ValueKey('$i-$f'),
      initialValue: '${m[f] ?? ''}',
      onChanged: (v) => m[f] = v,
      decoration: InputDecoration(
        labelText: f,
        errorText: (uncertain.contains(f) || m[f] == null) ? 'Check this' : null,
      ),
    );
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          for (final f in ['name', 'strength', 'dose', 'times_per_day', 'when']) field(f),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () => setState(() => meds.removeAt(i)), child: const Text('Remove')),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Add your medications')),
    body: Column(children: [
      if (loading) const LinearProgressIndicator(),
      if (error != null) Padding(padding: const EdgeInsets.all(8), child: Text(error!, style: const TextStyle(color: Colors.red))),
      Expanded(child: ListView(children: [for (var i = 0; i < meds.length; i++) medCard(meds[i], i)])),
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton(onPressed: loading ? null : scan, child: const Text('Scan a label')),
          ElevatedButton(onPressed: meds.isEmpty ? null : confirm, child: const Text('Confirm schedule')),
        ]),
      ),
    ]),
  );
}
