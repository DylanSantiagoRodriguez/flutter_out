import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';
import '../models/detection_result.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;
  final DetectionResult detectionResult;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.detectionResult,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
        return Colors.green;
      case 'intermedio':
        return Colors.orange;
      case 'difícil':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'fácil':
        return Icons.sentiment_very_satisfied;
      case 'intermedio':
        return Icons.sentiment_neutral;
      case 'difícil':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Información'),
            Tab(icon: Icon(Icons.list), text: 'Ingredientes'),
            Tab(icon: Icon(Icons.play_arrow), text: 'Pasos'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Guardar receta',
            onPressed: _saveRecipe,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInfoTab(),
          _buildIngredientsTab(),
          _buildStepsTab(),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la receta (placeholder)
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Imagen de la receta'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Título y descripción
          Text(
            widget.recipe.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.recipe.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),

          // Información básica
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          Icons.access_time,
                          'Tiempo total',
                          '${widget.recipe.totalTime} min',
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.people,
                          'Porciones',
                          '${widget.recipe.servings}',
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          _getDifficultyIcon(widget.recipe.difficulty),
                          'Dificultad',
                          widget.recipe.difficulty,
                          _getDifficultyColor(widget.recipe.difficulty),
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          Icons.public,
                          'Cocina',
                          widget.recipe.cuisine,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tiempos detallados
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tiempos de preparación',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeItem(
                          'Preparación',
                          '${widget.recipe.preparationTime} min',
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildTimeItem(
                          'Cocción',
                          '${widget.recipe.cookingTime} min',
                          Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Tags
          if (widget.recipe.tags.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Etiquetas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.recipe.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: Colors.blue[100],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Utensilios necesarios
          if (widget.recipe.requiredUtensils.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Utensilios necesarios',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...widget.recipe.requiredUtensils.map((utensil) {
                      final isAvailable = widget.detectionResult.utensils
                          .any((detected) => detected.name.toLowerCase()
                              .contains(utensil.toLowerCase()));
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              isAvailable ? Icons.check_circle : Icons.help_outline,
                              color: isAvailable ? Colors.green : Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                utensil,
                                style: TextStyle(
                                  color: isAvailable ? Colors.black : Colors.orange[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeItem(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
          child: Icon(Icons.timer, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ingredientes (${widget.recipe.ingredients.length})',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.recipe.ingredients.asMap().entries.map((entry) {
            final index = entry.key;
            final ingredient = entry.value;
            final isAvailable = widget.detectionResult.ingredients
                .any((detected) => detected.name.toLowerCase()
                    .contains(ingredient.toLowerCase().split(' ').last));

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isAvailable ? Colors.green : Colors.orange,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(ingredient),
                trailing: Icon(
                  isAvailable ? Icons.check_circle : Icons.help_outline,
                  color: isAvailable ? Colors.green : Colors.orange,
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Los ingredientes marcados con ✓ fueron detectados en tu cocina',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepsTab() {
    return Column(
      children: [
        // Progreso
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Column(
            children: [
              Text(
                'Paso ${_currentStepIndex + 1} de ${widget.recipe.steps.length}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_currentStepIndex + 1) / widget.recipe.steps.length,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
              ),
            ],
          ),
        ),
        
        // Pasos
        Expanded(
          child: PageView.builder(
            itemCount: widget.recipe.steps.length,
            onPageChanged: (index) {
              setState(() {
                _currentStepIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final step = widget.recipe.steps[index];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Número del paso
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green[600],
                            child: Text(
                              '${step.stepNumber}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Paso ${step.stepNumber}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (step.duration != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.timer, size: 16, color: Colors.green[700]),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${step.duration} min',
                                        style: TextStyle(
                                          color: Colors.green[700],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Instrucción
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Instrucciones:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              step.instruction,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Ingredientes específicos del paso
                    if (step.requiredIngredients.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ingredientes para este paso:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...step.requiredIngredients.map((ingredient) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.fiber_manual_record, size: 8),
                                      const SizedBox(width: 8),
                                      Text(ingredient),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Utensilios específicos del paso
                    if (step.requiredUtensils.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Utensilios necesarios:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...step.requiredUtensils.map((utensil) {
                                final isAvailable = widget.detectionResult.utensils
                                    .any((detected) => detected.name.toLowerCase()
                                        .contains(utensil.toLowerCase()));
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isAvailable ? Icons.check_circle : Icons.help_outline,
                                        size: 16,
                                        color: isAvailable ? Colors.green : Colors.orange,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        utensil,
                                        style: TextStyle(
                                          color: isAvailable ? Colors.black : Colors.orange[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        ),
                      ),
                    ],

                    // Consejo
                    if (step.tip != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber[200]!),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.lightbulb, color: Colors.amber[700]),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Consejo:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step.tip!,
                                    style: TextStyle(color: Colors.amber[700]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        // Navegación
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.3),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentStepIndex > 0
                      ? () {
                          setState(() {
                            _currentStepIndex--;
                          });
                        }
                      : null,
                  child: const Text('Anterior'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentStepIndex < widget.recipe.steps.length - 1
                      ? () {
                          setState(() {
                            _currentStepIndex++;
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _currentStepIndex < widget.recipe.steps.length - 1
                        ? 'Siguiente'
                        : '¡Terminado!',
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _saveRecipe() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inicia sesión para guardar recetas')),
      );
      return;
    }
    try {
      // Crear un registro de upload asociado al usuario para cumplir RLS
      final uploadInsert = await client
          .from('uploads')
          .insert({
            'user_id': user.id,
            'text_input': widget.detectionResult.additionalText ?? 'Guardado desde detalle',
            'image_url': null,
          })
          .select('id')
          .limit(1);

      final uploadId = (uploadInsert as List).first['id'] as String;

      // Asegurar existencia de receta en tabla public.recipes asociada al upload
      final existing = await client
          .from('recipes')
          .select('id')
          .eq('title', widget.recipe.name)
          .eq('upload_id', uploadId)
          .limit(1);

      String recipeId;
      if (existing is List && existing.isNotEmpty && existing.first['id'] != null) {
        recipeId = existing.first['id'] as String;
      } else {
        final insert = await client
            .from('recipes')
            .insert({
              'title': widget.recipe.name,
              'description': widget.recipe.description,
              'ingredients_list': widget.recipe.ingredients,
              'steps': widget.recipe.steps.map((s) => s.toJson()).toList(),
              'image_url': widget.recipe.imageUrl,
              'upload_id': uploadId,
            })
            .select('id')
            .limit(1);
        recipeId = (insert as List).first['id'] as String;
      }

      // Insertar en saved_recipes con restricción única (user_id, recipe_id)
      await client
          .from('saved_recipes')
          .upsert(
            {
              'user_id': user.id,
              'recipe_id': recipeId,
            },
            onConflict: 'user_id,recipe_id',
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Receta guardada')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: ${e.toString()}')),
      );
    }
  }
}