import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';
import 'add_edit_course_screen.dart';
import 'course_details_screen.dart';
import '../repositories/category_repository.dart';

class CourseListScreen extends StatefulWidget {
  const CourseListScreen({super.key});

  @override
  State<CourseListScreen> createState() => _CourseListScreenState();
}

class _CourseListScreenState extends State<CourseListScreen> {
  late CourseProvider provider;
  String query = '';
  int? filterCategoryId;

  @override
  void initState() {
    super.initState();

    provider = Provider.of<CourseProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryRepo = Provider.of<CategoryRepository>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Courses'),
        actions: [
          IconButton(onPressed: () => _openAdd(), icon: Icon(Icons.add)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by title...',
                    ),
                    onChanged: (v) => setState(() => query = v),
                  ),
                ),
                SizedBox(width: 8),
                FutureBuilder(
                  future: categoryRepo.fetchCategories(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      );
                    }
                    final cats = snapshot.data ?? [];
                    return DropdownButton<int?>(
                      hint: Text('Category'),
                      value: filterCategoryId,
                      items:
                          [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text('All'),
                            ),
                          ] +
                          (cats as List)
                              .map<DropdownMenuItem<int?>>(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => filterCategoryId = v),
                    );
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: Consumer<CourseProvider>(
              builder: (context, prov, _) {
                if (prov.loading) {
                  return Center(child: CircularProgressIndicator());
                }
                if (prov.error != null) {
                  return Center(child: Text('Error: ${prov.error}'));
                }
                final list = prov.courses.where((c) {
                  final matchesQuery = c.title.toLowerCase().contains(
                    query.toLowerCase(),
                  );
                  final matchesCategory = filterCategoryId == null
                      ? true
                      : c.categoryId == filterCategoryId;
                  return matchesQuery && matchesCategory;
                }).toList();

                if (list.isEmpty) return _emptyState();

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Divider(height: 1),
                  itemBuilder: (context, i) => ListTile(
                    title: Text(list[i].title),
                    subtitle: Text(
                      list[i].description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Score'),
                        Text(
                          list[i].score.toString(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailsScreen(course: list[i]),
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

  Widget _emptyState() => Center(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No courses yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Tap + to add your first course.', textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  void _openAdd() => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AddEditCourseScreen()),
  ).then((_) => provider.loadCourses());
}
