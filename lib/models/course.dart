
class Course {
  int? id;
  String title;
  String description;
  int categoryId;
  String categoryName;
  int lessons;
  int score;

  Course({this.id, required this.title, required this.description, required this.categoryId, required this.categoryName, required this.lessons, required this.score});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'lessons': lessons,
      'score': score,
    };
  }

  factory Course.fromMap(Map<String, dynamic> m) => Course(
    id: m['id'] as int?,
    title: m['title'] as String,
    description: m['description'] as String,
    categoryId: m['categoryId'] as int,
    categoryName: m['categoryName'] as String,
    lessons: m['lessons'] as int,
    score: m['score'] as int,
  );
}
