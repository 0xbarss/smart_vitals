import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../core/services/recipes_data_helper.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../../domain/entities/recipe.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final RecipeDatabaseHelper _dbHelper = RecipeDatabaseHelper();

  List<Recipe> _recipes = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snacks',
  ];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes({String query = ""}) async {
    setState(() => _isLoading = true);

    try {
      final List<Map<String, dynamic>> results = await _dbHelper.searchRecipes(
        query,
      );

      List<Recipe> mappedRecipes = results.map((row) {
        return Recipe(
          id: row['recipe_title'] ?? '0',
          title: row['recipe_title'] ?? 'Unknown Recipe',
          calories: row['Energy (KCAL)'] != null ? row['Energy (KCAL)'].round(): 0,
          timeMins: row['est_cook_time_min'] ?? 60,
          category: 'Dinner',
          tags: [
            row['health_level'] == 'healthy' ? 'Healthy':
            row['health_level'] == 'moderate' ? 'Moderate': 'Unhealthy'
          ],
          ingredients: List<String>.from(jsonDecode(row['ingredients'])),
          instructions: List<String>.from(jsonDecode(row['directions'])),
        );
      }).toList();

      if (_selectedCategory != 'All') {
        mappedRecipes = mappedRecipes.where((r) {
          return r.title.contains(_selectedCategory) ||
              r.category == _selectedCategory;
        }).toList();
      }

      if (mounted) {
        setState(() {
          _recipes = mappedRecipes;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading recipes: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _loadRecipes(query: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, settings) {
        final isHighContrast = settings.highContrast;

        return Scaffold(
          backgroundColor: isHighContrast
              ? Colors.black
              : const Color(0xFFF9FAFB),
          body: Column(
            children: [
              _buildHeader(isHighContrast),

              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          _buildSearchBar(isHighContrast),
                          const SizedBox(height: 24),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _categories
                                  .map(
                                    (cat) =>
                                        _buildCategoryChip(cat, isHighContrast),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: isHighContrast
                                    ? Colors.yellowAccent
                                    : const Color(0xFFEA580C),
                              ),
                            )
                          : _recipes.isEmpty
                          ? Center(
                              child: Text(
                                "No recipes found.",
                                style: TextStyle(
                                  color: isHighContrast
                                      ? Colors.white54
                                      : Colors.grey,
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    childAspectRatio: 0.72,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                              itemCount: _recipes.length,
                              itemBuilder: (context, index) {
                                return _buildRecipeCard(
                                  _recipes[index],
                                  isHighContrast,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isHighContrast) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.black : null,
        gradient: isHighContrast
            ? null
            : const LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFEA580C)],
              ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        border: isHighContrast
            ? const Border(bottom: BorderSide(color: Colors.white, width: 2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Healthy Recipes",
            style: TextStyle(
              color: isHighContrast ? Colors.yellowAccent : Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Discover nutritious meals for you",
            style: TextStyle(
              color: isHighContrast
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isHighContrast) {
    return Container(
      decoration: BoxDecoration(
        color: isHighContrast ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isHighContrast
            ? Border.all(color: Colors.white)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: isHighContrast
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: "Search recipes...",
          hintStyle: TextStyle(
            color: isHighContrast ? Colors.white54 : Colors.grey,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isHighContrast ? Colors.yellowAccent : Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: TextStyle(color: isHighContrast ? Colors.white : Colors.black),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isHighContrast) {
    final isSelected = _selectedCategory == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _selectedCategory = label;
            });

            _loadRecipes(query: _searchController.text);
          }
        },
        selectedColor: isHighContrast
            ? Colors.yellowAccent
            : const Color(0xFFEA580C),
        backgroundColor: isHighContrast ? Colors.black : Colors.white,
        labelStyle: TextStyle(
          color: isSelected
              ? (isHighContrast ? Colors.black : Colors.white)
              : (isHighContrast ? Colors.white : Colors.black),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected
                ? Colors.transparent
                : (isHighContrast ? Colors.white : Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _buildRecipeCard(Recipe recipe, bool isHighContrast) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(RouteNames.recipeDetail, extra: recipe);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isHighContrast ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isHighContrast ? Border.all(color: Colors.white) : null,
          boxShadow: isHighContrast
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  color: Colors.grey.shade200,
                  width: double.infinity,
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isHighContrast
                          ? Colors.yellowAccent
                          : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isHighContrast ? Colors.white70 : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          "${recipe.timeMins} min",
                          style: TextStyle(
                            fontSize: 12,
                            color: isHighContrast ? Colors.white70 : Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          "${recipe.calories} kcal",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isHighContrast
                                ? Colors.greenAccent
                                : Colors.orange,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
