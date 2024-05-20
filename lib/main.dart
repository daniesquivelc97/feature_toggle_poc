import 'package:feature_flags_poc/pages/mobile_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var _currentPage = 0;
  final _pages = [
    const MobilePage(),
    const Text('Page 2'),
    const Text('Page 3'),
  ];
  final _colors = [
    Colors.white,
    Colors.yellow,
    Colors.blue[200],
  ];
  var _color = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feature Toggle POC',
      home: Scaffold(
        backgroundColor: _colors[_color],
        appBar: AppBar(
          title: const Text('Feature Toggle POC'),
        ),
        body: Center(
          child: _pages.elementAt(_currentPage),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.mobile_friendly_outlined),
              label: 'Mobile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.connected_tv_sharp),
              label: 'Web',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud),
              label: 'Data',
            ),
          ],
          currentIndex: _currentPage,
          fixedColor: Colors.red,
          onTap: (int index) {
            setState(() {
              _currentPage = index;
              _color = index;
            });
          },
        ),
      ),
    );
  }
}
