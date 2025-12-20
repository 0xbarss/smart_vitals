import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../../domain/entities/recipe.dart';

class RecipeDetailPage extends StatelessWidget {
  final Recipe recipe;
  final String? imageURL;

  const RecipeDetailPage({super.key, required this.recipe, this.imageURL});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isHighContrast = settings.highContrast;

        final bgColor = isHighContrast ? Colors.black : Colors.white;
        final textColor = isHighContrast
            ? Colors.yellowAccent
            : const Color(0xFF1F2937);
        final sectionHeaderColor = isHighContrast
            ? Colors.white
            : const Color(0xFF111827);
        final subTextColor = isHighContrast ? Colors.white70 : Colors.grey[600];

        return Scaffold(
          backgroundColor: bgColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: isHighContrast
                    ? Colors.grey[900]
                    : Colors.white,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: imageURL != null
                      ? Image.network(
                    imageURL!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      );
                    },
                  )
                      : Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        children: recipe.tags
                            .map(
                              (tag) => Chip(
                            label: Text(tag),
                            backgroundColor: isHighContrast
                                ? Colors.grey[800]
                                : const Color(0xFFECFDF5),
                            labelStyle: TextStyle(
                              color: isHighContrast
                                  ? Colors.white
                                  : const Color(0xFF059669),
                              fontWeight: FontWeight.bold,
                            ),
                            side: BorderSide.none,
                          ),
                        )
                            .toList(),
                      ),
                      const SizedBox(height: 20),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isHighContrast
                              ? Colors.grey[900]
                              : Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: isHighContrast
                              ? Border.all(color: Colors.white24)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              Icons.access_time,
                              "${recipe.timeMins} min",
                              "Cook Time",
                              isHighContrast,
                            ),
                            _buildStat(
                              Icons.local_fire_department,
                              "${recipe.calories}",
                              "Calories",
                              isHighContrast,
                            ),
                            _buildStat(
                              Icons.restaurant_menu,
                              "2",
                              "Servings",
                              isHighContrast,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Text(
                        "Ingredients",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: sectionHeaderColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...recipe.ingredients.map(
                            (ing) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 20,
                                color: isHighContrast
                                    ? Colors.greenAccent
                                    : Colors.green,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  ing,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: subTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      Text(
                        "Instructions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: sectionHeaderColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...recipe.instructions.asMap().entries.map(
                            (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 24.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isHighContrast
                                      ? Colors.yellowAccent
                                      : Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "${entry.key + 1}",
                                  style: TextStyle(
                                    color: isHighContrast
                                        ? Colors.black
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: 16,
                                    height: 1.5,
                                    color: subTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStat(
      IconData icon,
      String value,
      String label,
      bool isHighContrast,
      ) {
    return Column(
      children: [
        Icon(
          icon,
          color: isHighContrast ? Colors.yellowAccent : const Color(0xFF10B981),
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isHighContrast ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isHighContrast ? Colors.white70 : Colors.grey,
          ),
        ),
      ],
    );
  }
}