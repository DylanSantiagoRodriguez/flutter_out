import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TranslatorScreen extends StatefulWidget {
  const TranslatorScreen({super.key});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String _englishText = '';
  final _formKey = GlobalKey<FormState>();

  Future<String> translateText(String textValue) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please add OPENAI_API_KEY to your .env file.');
      }

      final prompt = 'Traduce el siguiente texto del español al inglés. Devuelve ' 
          'solamente el texto traducido sin incluir explicaciones:\n\n$textValue';

      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4.1-mini',
          'temperature': 0,
          'messages': [
            { 'role': 'system', 'content': 'You are a translator that converts Spanish text to English. Return only the translated text without explanations.' },
            { 'role': 'user', 'content': prompt }
          ]
        }),
      );

      if (response.statusCode != 200) {
        return 'Error: ${response.statusCode} ${response.body}';
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final String? content = data['choices']?[0]?['message']?['content'];
      return content?.trim() ?? 'No se pudo obtener una traducción.';
    } catch (e) {
      return 'Error: ${e.toString()}';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleTranslate() async {
    if (_formKey.currentState!.validate()) {
      String result = await translateText(_textController.text);
      setState(() {
        _englishText = result;
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Traductor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Entrada de texto en español
                TextFormField(
                  controller: _textController,
                  decoration: const InputDecoration(
                    labelText: 'Texto en Español',
                    border: OutlineInputBorder(),
                    hintText: 'Escribe o pega el texto a traducir',
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa texto para traducir';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),

                // Botón de traducción
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleTranslate,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Traducir'),
                ),
                const SizedBox(height: 24.0),

                // Sección de texto traducido
                const Text(
                  'Traducción a inglés:',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _englishText.isEmpty
                            ? 'La traducción aparecerá aquí'
                            : _englishText,
                        style: TextStyle(
                          color: _englishText.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}