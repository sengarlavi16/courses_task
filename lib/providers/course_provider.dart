
import 'package:flutter/material.dart';
import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository _repo = CourseRepository();
  List<Course> _courses = [];
  bool loading = false;
  String? error;

  List<Course> get courses => _courses;

  Future<void> loadCourses() async {
    loading = true; error = null; notifyListeners();
    try {
      _courses = await _repo.getCourses();
    } catch (e) {
      error = e.toString();
    }
    loading = false; notifyListeners();
  }

  Future<void> addCourse(Course c) async {
    await _repo.addCourse(c);
    await loadCourses();
  }

  Future<void> updateCourse(Course c) async {
    await _repo.updateCourse(c);
    await loadCourses();
  }

  Future<void> deleteCourse(int id) async {
    await _repo.deleteCourse(id);
    await loadCourses();
  }
}
