import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/kitchen_detection_service.dart';
import '../services/recipe_recommendation_service.dart';
import '../models/detection_result.dart';
import '../models/recipe.dart';
import 'recipe_list_screen.dart';

class KitchenDetectionScreen extends StatefulWidget {
  const KitchenDetectionScreen({super.key});

  @override
  State<KitchenDetectionScreen> createState() => _KitchenDetectionScreenState();
}

class _KitchenDetectionScreenState extends State<KitchenDetectionScreen> {
  final TextEditingController _textController = TextEditingController();
  final KitchenDetectionService _detectionService = KitchenDetectionService();
  final RecipeRecommendationService _recipeService = RecipeRecommendationService();
  final ImagePicker _picker = ImagePicker();
  
  File? _selectedImage;
  bool _isDetecting = false;
  bool _isGeneratingRecipes = false;
  DetectionResult? _detectionResult;
  String _selectedCuisine = '';
  String _selectedDifficulty = '';

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
          _detectionResult = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Error al seleccionar imagen: ${e.toString()}');
    }
  }

  Future<void> _detectFromImage() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Por favor selecciona una imagen primero');
      return;
    }

    setState(() {
      _isDetecting = true;
    });

    try {
      final result = await _detectionService.detectFromImage(
        _selectedImage!,
        additionalText: _textController.text.trim().isNotEmpty 
            ? _textController.text.trim() 
            : null,
      );

      setState(() {
        _detectionResult = result;
      });

      if (result.hasDetections) {
        _showSuccessSnackBar(
          'Detectados: ${result.ingredients.length} ingredientes, ${result.utensils.length} utensilios'
        );
      } else {
        _showErrorSnackBar('No se detectaron ingredientes ni utensilios');
      }
    } catch (e) {
      _showErrorSnackBar('Error en la detección: ${e.toString()}');
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  Future<void> _detectFromText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      _showErrorSnackBar('Por favor ingresa una descripción');
      return;
    }

    setState(() {
      _isDetecting = true;
    });

    try {
      final result = await _detectionService.detectFromText(text);

      setState(() {
        _detectionResult = result;
      });

      if (result.hasDetections) {
        _showSuccessSnackBar(
          'Detectados: ${result.ingredients.length} ingredientes, ${result.utensils.length} utensilios'
        );
      } else {
        _showErrorSnackBar('No se detectaron ingredientes ni utensilios en el texto');
      }
    } catch (e) {
      _showErrorSnackBar('Error en la detección: ${e.toString()}');
    } finally {
      setState(() {
        _isDetecting = false;
      });
    }
  }

  Future<void> _generateRecipes() async {
    if (_detectionResult == null || !_detectionResult!.hasDetections) {
      _showErrorSnackBar('Primero debes detectar ingredientes');
      return;
    }

    setState(() {
      _isGeneratingRecipes = true;
    });

    try {
      final recipes = await _recipeService.getRecipeRecommendations(
        _detectionResult!,
        cuisinePreference: _selectedCuisine.isNotEmpty ? _selectedCuisine : null,
        difficultyPreference: _selectedDifficulty.isNotEmpty ? _selectedDifficulty : null,
      );

      if (recipes.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeListScreen(
              recipes: recipes,
              detectionResult: _detectionResult!,
            ),
          ),
        );
      } else {
        _showErrorSnackBar('No se pudieron generar recetas con los ingredientes detectados');
      }
    } catch (e) {
      _showErrorSnackBar('Error al generar recetas: ${e.toString()}');
    } finally {
      setState(() {
        _isGeneratingRecipes = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detectar Ingredientes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sección de imagen
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Imagen de ingredientes',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (_selectedImage != null)
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image, size: 48, color: Colors.grey),
                              SizedBox(height: 8),
                              Text('No hay imagen seleccionada'),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Cámara'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _pickImage(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Galería'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sección de texto adicional
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Descripción adicional (opcional)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _textController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Describe los ingredientes que tienes disponibles...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Botones de detección
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isDetecting ? null : _detectFromImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isDetecting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Detectar desde Imagen'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isDetecting ? null : _detectFromText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isDetecting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Detectar desde Texto'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Resultados de detección
            if (_detectionResult != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resultados de detección',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      if (_detectionResult!.ingredients.isNotEmpty) ...[
                        const Text(
                          'Ingredientes detectados:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _detectionResult!.ingredients.map((ingredient) {
                            return Chip(
                              label: Text(ingredient.name),
                              backgroundColor: Colors.green[100],
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (_detectionResult!.utensils.isNotEmpty) ...[
                        const Text(
                          'Utensilios detectados:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: _detectionResult!.utensils.map((utensil) {
                            return Chip(
                              label: Text(utensil.name),
                              backgroundColor: Colors.blue[100],
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Preferencias para recetas
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Preferencias de recetas (opcional)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCuisine.isEmpty ? null : _selectedCuisine,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de cocina',
                          border: OutlineInputBorder(),
                        ),
                        items: ['', ...CuisineType.allTypes].map((cuisine) {
                          return DropdownMenuItem(
                            value: cuisine,
                            child: Text(cuisine.isEmpty ? 'Cualquiera' : cuisine),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCuisine = value ?? '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDifficulty.isEmpty ? null : _selectedDifficulty,
                        decoration: const InputDecoration(
                          labelText: 'Dificultad',
                          border: OutlineInputBorder(),
                        ),
                        items: ['', ...RecipeDifficulty.allLevels].map((difficulty) {
                          return DropdownMenuItem(
                            value: difficulty,
                            child: Text(difficulty.isEmpty ? 'Cualquiera' : difficulty),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDifficulty = value ?? '';
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botón para generar recetas
              ElevatedButton(
                onPressed: _isGeneratingRecipes ? null : _generateRecipes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isGeneratingRecipes
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Generando recetas...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant),
                          SizedBox(width: 8),
                          Text('Generar Recetas'),
                        ],
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}