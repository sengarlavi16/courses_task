
class Category {
  final int id;
  final String name;
  Category({required this.id, required this.name});

  factory Category.fromMap(Map<String, dynamic> m) => Category(id: m['id'], name: m['name']);

  Map<String, dynamic> toMap() => {'id': id, 'name': name};
}
