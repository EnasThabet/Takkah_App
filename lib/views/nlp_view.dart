import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProcessedMessagesPage extends StatefulWidget {
  const ProcessedMessagesPage({super.key});

  @override
  State<ProcessedMessagesPage> createState() => _ProcessedMessagesPageState();
}

class _ProcessedMessagesPageState extends State<ProcessedMessagesPage> {
  List<Map<String, dynamic>> messages = [];
  bool isLoading = true;

  late final String supabaseUrl;
  late final String serviceRoleKey;

  @override
  void initState() {
    super.initState();

    // قراءة متغيرات البيئة من .env
    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    serviceRoleKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    fetchProcessedMessages();
  }

  Future<void> fetchProcessedMessages() async {
    setState(() => isLoading = true);

    final url = '$supabaseUrl/rest/v1/telegram_processed_messages?select=*';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'apikey': serviceRoleKey,
        'Authorization': 'Bearer $serviceRoleKey',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        messages = data.cast<Map<String, dynamic>>();
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في جلب الرسائل: ${response.statusCode}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الرسائل المحللة'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : messages.isEmpty
              ? const Center(child: Text('لا توجد رسائل محللة بعد'))
              : ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final detectedTerms = msg['detected_terms'] != null
                        ? List<String>.from(msg['detected_terms'])
                        : <String>[];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(msg['message'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الحالة: ${msg['status'] ?? '-'}'),
                            Text('المكان: ${msg['location'] ?? '-'}'),
                            Text('الثقة: ${msg['confidence'] ?? 0}'),
                            Text('السبب: ${msg['reasoning'] ?? '-'}'),
                            if (detectedTerms.isNotEmpty)
                              Text(
                                  'مصطلحات مكتشفة: ${detectedTerms.join(', ')}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
