
import '../models/course.dart';
import '../services/local_db.dart';

class CourseRepository {
  Future<List<Course>> getCourses() async {
    return await LocalDB.getAllCourses();
  }

  Future<int> addCourse(Course c) async {
    return await LocalDB.insertCourse(c);
  }

  Future<int> updateCourse(Course c) async {
    return await LocalDB.updateCourse(c);
  }

  Future<int> deleteCourse(int id) async {
    return await LocalDB.deleteCourse(id);
  }
}
