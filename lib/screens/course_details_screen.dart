
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../models/course.dart';
import 'add_edit_course_screen.dart';
import 'package:provider/provider.dart';
import '../providers/course_provider.dart';

class CourseDetailsScreen extends StatelessWidget {
  final Course course;
  const CourseDetailsScreen({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CourseProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(course.title), actions: [
        IconButton(icon: Icon(Icons.edit), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditCourseScreen(course: course))).then((_) => provider.loadCourses())),
        IconButton(icon: Icon(Icons.delete), onPressed: () async {
          final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: Text('Delete?'), content: Text('Delete this course?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')), TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Delete'))]));
          if (ok == true) {
            await provider.deleteCourse(course.id!);
            Navigator.pop(context);
          }
        })
      ]),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(course.title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Category: ${course.categoryName}'),
          SizedBox(height: 8),
          Text('Lessons: ${course.lessons}'),
          SizedBox(height: 8),
          Text('Score: ${course.score}', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 16),
          Text('Description', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text(course.description),
        ]),
      ),
    );
  }
}
