class Recipe {
  final String id;
  final String title;
  final int calories;
  final int timeMins;
  final String category;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> instructions;
  final double carbs;
  final double protein;
  final double fat;
  final double water;
  final double sodium;

  Recipe({
    required this.id,
    required this.title,
    required this.calories,
    required this.timeMins,
    required this.category,
    required this.tags,
    required this.ingredients,
    required this.instructions,
    this.carbs = 0,
    this.protein = 0,
    this.fat = 0,
    this.water = 0,
    this.sodium = 0,
  });
}