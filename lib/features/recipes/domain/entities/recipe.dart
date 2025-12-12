class Recipe {
  final String id;
  final String title;
  final String imageUrl;
  final int calories;
  final int timeMins;
  final String category;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> instructions;

  const Recipe({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.calories,
    required this.timeMins,
    required this.category,
    required this.tags,
    required this.ingredients,
    required this.instructions,
  });
}