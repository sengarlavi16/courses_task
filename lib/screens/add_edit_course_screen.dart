// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';
import '../repositories/category_repository.dart';
import '../models/category.dart';

class AddEditCourseScreen extends StatefulWidget {
  final Course? course;
  const AddEditCourseScreen({super.key, this.course});

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleC;
  late TextEditingController _descC;
  late TextEditingController _lessonsC;

  Category? _selectedCategory;
  String? _initialCategoryName;

  bool saving = false;

  late Future<List<Category>> _categoryFuture;

  int get computedScore =>
      _titleC.text.trim().length * (int.tryParse(_lessonsC.text) ?? 0);

  @override
  void initState() {
    super.initState();

    _titleC = TextEditingController(text: widget.course?.title ?? '');
    _descC = TextEditingController(text: widget.course?.description ?? '');
    _lessonsC = TextEditingController(
      text: widget.course?.lessons.toString() ?? '1',
    );

    // Update score live
    _titleC.addListener(_refresh);
    _lessonsC.addListener(_refresh);

    // Store original category name for matching later
    if (widget.course != null) {
      _initialCategoryName = widget.course!.categoryName;
    }

    // Load categories ONCE (fixes FutureBuilder loop)
    final catRepo = Provider.of<CategoryRepository>(context, listen: false);
    _categoryFuture = catRepo.fetchCategories();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _titleC.dispose();
    _descC.dispose();
    _lessonsC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = CourseRepository();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course == null ? 'Add Course' : 'Edit Course'),
      ),
      body: FutureBuilder<List<Category>>(
        future: _categoryFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final cats = snap.data ?? [];

          // First time matching selected category
          if (_selectedCategory == null && _initialCategoryName != null) {
            final found = cats.firstWhere(
              (c) => c.name == _initialCategoryName,
              orElse: () => cats.first,
            );
            _selectedCategory = found;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleC,
                    decoration: InputDecoration(labelText: 'Title'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _descC,
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<Category>(
                    initialValue: _selectedCategory,
                    items: cats
                        .map(
                          (c) =>
                              DropdownMenuItem(value: c, child: Text(c.name)),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v),
                    validator: (v) => v == null ? 'Select a category' : null,
                    decoration: InputDecoration(labelText: 'Category'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _lessonsC,
                    decoration: InputDecoration(labelText: 'Number of lessons'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || int.tryParse(v) == null) {
                        return 'Enter a valid number';
                      }
                      if (int.parse(v) <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // LIVE SCORE DISPLAY
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Score:",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        computedScore.toString(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  saving
                      ? Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => saving = true);

                            final title = _titleC.text.trim();
                            final desc = _descC.text.trim();
                            final lessons = int.parse(_lessonsC.text.trim());
                            final score = computedScore;

                            if (widget.course == null) {
                              final course = Course(
                                title: title,
                                description: desc,
                                categoryId: _selectedCategory!.id,
                                categoryName: _selectedCategory!.name,
                                lessons: lessons,
                                score: score,
                              );
                              await repo.addCourse(course);
                            } else {
                              final course = Course(
                                id: widget.course!.id,
                                title: title,
                                description: desc,
                                categoryId: _selectedCategory!.id,
                                categoryName: _selectedCategory!.name,
                                lessons: lessons,
                                score: score,
                              );
                              await repo.updateCourse(course);
                            }

                            setState(() => saving = false);
                            Navigator.pop(context);
                          },
                          child: const Text('Save'),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
