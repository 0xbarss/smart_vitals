import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/route_names.dart';
import '../../../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../../../features/settings/presentation/bloc/settings_state.dart';
import '../../domain/entities/recipe.dart';

class RecipesPage extends StatefulWidget {
  const RecipesPage({super.key});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final List<Recipe> _allRecipes = [
    const Recipe(
      id: '1',
      title: 'Quinoa & Avocado Salad',
      imageUrl:
          'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=600&auto=format&fit=crop',
      calories: 320,
      timeMins: 15,
      category: 'Lunch',
      tags: ['Vegan', 'Gluten Free'],
      ingredients: [],
      instructions: [],
    ),
    const Recipe(
      id: '2',
      title: 'Grilled Salmon with Asparagus',
      imageUrl:
          'https://images.unsplash.com/photo-1467003909585-2f8a7270028d?q=80&w=600&auto=format&fit=crop',
      calories: 450,
      timeMins: 25,
      category: 'Dinner',
      tags: ['High Protein', 'Keto'],
      ingredients: [],
      instructions: [],
    ),
    const Recipe(
      id: '3',
      title: 'Berry Smoothie Bowl',
      imageUrl:
          'https://images.unsplash.com/photo-1577805947697-89e18249d767?q=80&w=600&auto=format&fit=crop',
      calories: 280,
      timeMins: 10,
      category: 'Breakfast',
      tags: ['Vegetarian', 'Low Carb'],
      ingredients: [],
      instructions: [],
    ),
    const Recipe(
      id: '4',
      title: 'Chicken Stir-Fry',
      imageUrl:
          'https://images.unsplash.com/photo-1603133872878-684f57143b33?q=80&w=600&auto=format&fit=crop',
      calories: 520,
      timeMins: 30,
      category: 'Dinner',
      tags: ['High Protein', 'Dairy Free'],
      ingredients: [],
      instructions: [],
    ),
    const Recipe(
      id: '5',
      title: 'Oatmeal with Blueberries',
      imageUrl:
          'https://images.unsplash.com/photo-1517673132405-a56a62b18caf?q=80&w=600&auto=format&fit=crop',
      calories: 350,
      timeMins: 10,
      category: 'Breakfast',
      tags: ['High Fiber', 'Vegan'],
      ingredients: [],
      instructions: [],
    ),
    const Recipe(
      id: '6',
      title: 'Avocado Toast & Egg',
      imageUrl:
          'https://images.unsplash.com/photo-1525351463974-b38319cd8785?q=80&w=600&auto=format&fit=crop',
      calories: 410,
      timeMins: 12,
      category: 'Breakfast',
      tags: ['Vegetarian', 'Healthy Fats'],
      ingredients: [],
      instructions: [],
    ),
    const Recipe(
      id: '7',
      title: 'Greek Yogurt Parfait',
      imageUrl:
          'https://images.unsplash.com/photo-1488477181946-6428a029177b?q=80&w=600&auto=format&fit=crop',
      calories: 220,
      timeMins: 5,
      category: 'Snacks',
      tags: ['Low Calorie', 'High Protein'],
      ingredients: [],
      instructions: [],
    ),
    const Recipe(
      id: '8',
      title: 'Lentil Soup',
      imageUrl:
          'https://images.unsplash.com/photo-1547592166-23ac45744acd?q=80&w=600&auto=format&fit=crop',
      calories: 290,
      timeMins: 40,
      category: 'Lunch',
      tags: ['Vegan', 'High Fiber'],
      ingredients: [],
      instructions: [],
    ),
    const Recipe(
      id: '9',
      title: 'Turkey Wrap',
      imageUrl:
          'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?q=80&w=600&auto=format&fit=crop',
      calories: 380,
      timeMins: 10,
      category: 'Lunch',
      tags: ['Balanced', 'Low Fat'],
      ingredients: [],
      instructions: [],
    ),
    const Recipe(
      id: '10',
      title: 'Almond Energy Balls',
      imageUrl:
          'https://images.unsplash.com/photo-1604329760661-e71dc831d65a?q=80&w=600&auto=format&fit=crop',
      calories: 150,
      timeMins: 20,
      category: 'Snacks',
      tags: ['Vegan', 'Gluten Free'],
      ingredients: [],
      instructions: [],
    ),
  ];

  late List<Recipe> _filteredRecipes;
  String _selectedCategory = 'All';
  String _searchQuery = '';
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
    _filteredRecipes = _allRecipes;
  }

  void _runFilter() {
    setState(() {
      _filteredRecipes = _allRecipes.where((recipe) {
        final matchesCategory =
            _selectedCategory == 'All' || recipe.category == _selectedCategory;

        final matchesSearch =
            recipe.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            recipe.tags.any(
              (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
            );

        return matchesCategory && matchesSearch;
      }).toList();
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
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _buildSearchBar(isHighContrast),
                    const SizedBox(height: 24),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _categories
                            .map(
                              (cat) => _buildCategoryChip(cat, isHighContrast),
                            )
                            .toList(),
                      ),
                    ),

                    if (_filteredRecipes.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            "No recipes found.",
                            style: TextStyle(
                              color: isHighContrast
                                  ? Colors.white54
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: _filteredRecipes.length,
                        itemBuilder: (context, index) {
                          return _buildRecipeCard(
                            _filteredRecipes[index],
                            isHighContrast,
                          );
                        },
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
        onChanged: (value) {
          _searchQuery = value;
          _runFilter();
        },
        decoration: InputDecoration(
          hintText: "Search for meals...",
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
              _runFilter();
            });
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
                child: CachedNetworkImage(
                  imageUrl: recipe.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey.shade200),
                  errorWidget: (context, url, error) =>
                      Container(color: Colors.grey.shade200),
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
                      Text(
                        "${recipe.timeMins} min",
                        style: TextStyle(
                          fontSize: 12,
                          color: isHighContrast ? Colors.white70 : Colors.grey,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "${recipe.calories} kcal",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isHighContrast
                              ? Colors.greenAccent
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
      
                  SizedBox(
                    height: 20,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: recipe.tags
                          .map(
                            (tag) => Container(
                              margin: const EdgeInsets.only(right: 4),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isHighContrast
                                    ? Colors.grey[800]
                                    : const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(4),
                                border: isHighContrast
                                    ? Border.all(color: Colors.white24)
                                    : null,
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isHighContrast
                                      ? Colors.white
                                      : const Color(0xFFEA580C),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
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
