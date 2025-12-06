import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category.dart';
import '../services/local_db.dart';

class CategoryRepository {
  final String endpoint = 'https://fakestoreapi.com/products/categories';

  Future<void> init() async {
    await LocalDB.instance;
  }

  Future<List<Category>> fetchCategories() async {
    try {
      final res = await http
          .get(Uri.parse(endpoint))
          .timeout(Duration(seconds: 5));

      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List;

        // Convert List<String> → List<Category>
        final cats = List<Category>.generate(
          list.length,
          (i) => Category(id: i + 1, name: list[i]),
        );

        // Cache into DB (convert to List<Map<String, dynamic>>)
        final cacheList = cats
            .map((c) => {'id': c.id, 'name': c.name})
            .toList();
        await LocalDB.cacheCategories(cacheList);

        return cats;
      } else {
        return await _loadFromCache();
      }
    } catch (e) {
      return await _loadFromCache();
    }
  }

  Future<List<Category>> _loadFromCache() async {
    final rows = await LocalDB.getCachedCategories();

    // If DB empty → return fallback categories
    if (rows.isEmpty) {
      return _fallbackCategories();
    }

    return rows.map((r) => Category.fromMap(r)).toList();
  }

  // fallback categories used if:
  // - no internet
  // - no cache yet
  List<Category> _fallbackCategories() {
    return [
      Category(id: 1, name: "Mobile Development"),
      Category(id: 2, name: "Web Development"),
      Category(id: 3, name: "Data Science"),
      Category(id: 4, name: "DevOps"),
    ];
  }
}
