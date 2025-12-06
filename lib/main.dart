
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/course_list_screen.dart';
import 'providers/course_provider.dart';
import 'repositories/category_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final categoryRepo = CategoryRepository();
  await categoryRepo.init();

  runApp(MyApp(categoryRepo: categoryRepo));
}

class MyApp extends StatelessWidget {
  final CategoryRepository categoryRepo;
  const MyApp({super.key, required this.categoryRepo});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CourseProvider()),
        Provider<CategoryRepository>.value(value: categoryRepo),
      ],
      child: MaterialApp(
        title: 'Courses Manager',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
        ),
        home: CourseListScreen(),
      ),
    );
  }
}
