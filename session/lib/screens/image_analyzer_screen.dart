import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class ImageAnalyzerScreen extends StatefulWidget {
  const ImageAnalyzerScreen({super.key});

  @override
  State<ImageAnalyzerScreen> createState() => _ImageAnalyzerScreenState();
}

class _ImageAnalyzerScreenState extends State<ImageAnalyzerScreen> {
  File? _selectedImage;
  bool _isLoading = false;
  String _analysisResult = '';
  final ImagePicker _picker = ImagePicker();

  Future<String> analyzeImage(File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please add OPENAI_API_KEY to your .env file.');
      }

      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final prompt = 'Describe detalladamente lo que ves en esta imagen. '
          'Incluye objetos, personas, colores, acciones, emociones y cualquier '
          'detalle relevante que puedas observar.';

      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4.1-mini',
          'temperature': 0.2,
          'messages': [
            {
              'role': 'user',
              'content': [
                { 'type': 'text', 'text': prompt },
                { 'type': 'image_url', 'image_url': { 'url': 'data:image/jpeg;base64,$base64Image' } }
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        return 'Error: ${response.statusCode} ${response.body}';
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final String? content = data['choices']?[0]?['message']?['content'];
      return content?.trim() ?? 'No se pudo analizar la imagen.';
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _analysisResult = ''; // Limpiar resultado anterior
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  void _showImageSourceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar imagen'),
          content: const Text('¿De dónde quieres obtener la imagen?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
              child: const Text('Cámara'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
              child: const Text('Galería'),
            ),
          ],
        );
      },
    );
  }

  void _handleAnalyze() async {
    if (_selectedImage != null) {
      String result = await analyzeImage(_selectedImage!);
      setState(() {
        _analysisResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Análisis de Imágenes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Botón para seleccionar imagen
              ElevatedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Seleccionar Imagen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 16.0),

              // Mostrar imagen seleccionada
              if (_selectedImage != null) ...[
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Botón de análisis
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleAnalyze,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Analizar Imagen'),
                ),
                const SizedBox(height: 24.0),
              ],

              // Sección de resultado del análisis
              if (_selectedImage != null) ...[
                const Text(
                  'Análisis de la imagen:',
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
                        _analysisResult.isEmpty
                            ? 'El análisis aparecerá aquí'
                            : _analysisResult,
                        style: TextStyle(
                          color: _analysisResult.isEmpty
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // Mensaje cuando no hay imagen seleccionada
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Selecciona una imagen para comenzar el análisis',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}