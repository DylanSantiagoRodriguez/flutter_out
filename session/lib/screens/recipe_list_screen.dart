import 'package:flutter/material.dart';
import '../models/recipe.dart';
import '../models/detection_result.dart';
import 'recipe_detail_screen.dart';

class RecipeListScreen extends StatefulWidget {
  final List<Recipe> recipes;
  final DetectionResult detectionResult;

  const RecipeListScreen({
    super.key,
    required this.recipes,
    required this.detectionResult,
  });

  @override
  State<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends State<RecipeListScreen> {
  String _selectedDifficulty = '';
  String _selectedCuisine = '';
  List<Recipe> _filteredRecipes = [];

  @override
  void initState() {
    super.initState();
    _filteredRecipes = widget.recipes;
  }

  void _filterRecipes() {
    setState(() {
      _filteredRecipes = widget.recipes.where((recipe) {
        bool matchesDifficulty = _selectedDifficulty.isEmpty || 
            recipe.difficulty == _selectedDifficulty;
        bool matchesCuisine = _selectedCuisine.isEmpty || 
            recipe.cuisine == _selectedCuisine;
        return matchesDifficulty && matchesCuisine;
      }).toList();
    });
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
        title: Text('Recetas Recomendadas (${_filteredRecipes.length})'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen de ingredientes detectados
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.green[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ingredientes detectados:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: widget.detectionResult.ingredients.map((ingredient) {
                    return Chip(
                      label: Text(
                        ingredient.name,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: Colors.green[100],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          
          // Lista de recetas
          Expanded(
            child: _filteredRecipes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No se encontraron recetas con los filtros aplicados',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: _filteredRecipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _filteredRecipes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        elevation: 4,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailScreen(
                                  recipe: recipe,
                                  detectionResult: widget.detectionResult,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Título y tiempo
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        recipe.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.access_time, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${recipe.totalTime} min',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                
                                // Descripción
                                Text(
                                  recipe.description,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                
                                // Información adicional
                                Row(
                                  children: [
                                    // Dificultad
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getDifficultyColor(recipe.difficulty).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _getDifficultyColor(recipe.difficulty),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getDifficultyIcon(recipe.difficulty),
                                            size: 16,
                                            color: _getDifficultyColor(recipe.difficulty),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            recipe.difficulty,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: _getDifficultyColor(recipe.difficulty),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    // Cocina
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        recipe.cuisine,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    
                                    // Porciones
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.people, size: 16),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${recipe.servings}',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Ingredientes principales
                                Text(
                                  'Ingredientes principales: ${recipe.ingredients.take(3).join(", ")}${recipe.ingredients.length > 3 ? "..." : ""}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filtrar Recetas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDifficulty.isEmpty ? null : _selectedDifficulty,
                    decoration: const InputDecoration(
                      labelText: 'Dificultad',
                      border: OutlineInputBorder(),
                    ),
                    items: ['', ...RecipeDifficulty.allLevels].map((difficulty) {
                      return DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty.isEmpty ? 'Todas' : difficulty),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedDifficulty = value ?? '';
                      });
                    },
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
                        child: Text(cuisine.isEmpty ? 'Todas' : cuisine),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedCuisine = value ?? '';
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      _selectedDifficulty = '';
                      _selectedCuisine = '';
                    });
                  },
                  child: const Text('Limpiar'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _filterRecipes();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Aplicar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}