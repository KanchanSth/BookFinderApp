import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/favorite_screen.dart';
import 'controllers/theme_controller.dart';
import 'controllers/book_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialize Hive for Flutter
  await Hive.initFlutter();

//container
  await Hive.openBox('book_data');
  await Hive.openBox('favorite_book_data');
  await Hive.openBox('popular_book_data');

//controllers initialize
  Get.put(ThemeController());
  Get.put(BookController());

  //to restrict the screen orientation to only portrait mode
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: controller.lightTheme,
          darkTheme: controller.darkTheme,
          themeMode: controller.themeMode,
          home: const MainScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const FavoriteScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Favorites"),
        ],
      ),
    );
  }
}
