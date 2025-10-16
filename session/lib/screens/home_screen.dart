import 'package:flutter/material.dart';
import 'kitchen_detection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente de Cocina IA'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo o icono principal
              Icon(
                Icons.restaurant_menu,
                size: 80,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),

              // Título de bienvenida
              const Text(
                '¡Bienvenido a tu Asistente de Cocina!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              // Subtítulo
              Text(
                'Descubre recetas increíbles con los ingredientes que tienes',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 48),

              // Botón principal de detección de cocina
              _buildMenuCard(
                context: context,
                title: 'Detectar Ingredientes',
                subtitle: 'Toma una foto o describe lo que tienes disponible',
                icon: Icons.camera_alt,
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KitchenDetectionScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Información sobre la funcionalidad
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.1),
                      Colors.deepOrange.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.orange, size: 24),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Cómo funciona:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      icon: Icons.photo_camera,
                      text: 'Toma una foto de tus ingredientes y utensilios',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      icon: Icons.text_fields,
                      text: 'O describe lo que tienes disponible',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      icon: Icons.restaurant,
                      text: 'Recibe recetas personalizadas con pasos detallados',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Información adicional
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Powered by GPT-4.1 mini',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
