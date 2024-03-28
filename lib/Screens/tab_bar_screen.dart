/// Packages ///
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soaproject/Screens/Board/board_input_screen.dart';
import 'package:soaproject/Screens/Records/record_input_screen.dart';

/// Screens ///
import './HomeScreens/home_screen_1.dart';
import 'package:soaproject/Screens/HomeScreens/home_screen_2.dart';
import 'package:soaproject/Screens/HomeScreens/home_screen_3.dart';

class TabBarScreen extends StatefulWidget {
  static const routeName = '/TabBarScreen';
  const TabBarScreen({Key? key}) : super(key: key);

  @override
  State<TabBarScreen> createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarScreen> {
  int _currentPage = 0;
  final User? _user = FirebaseAuth.instance.currentUser;

  void _selectPage(val) {
    setState(() {
      _currentPage = val;
    });
  }

  Future<bool> onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('앱 종료'),
            content: const Text('앱을 종료하시겠습니까?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('아니요'),
              ),
              TextButton(
                onPressed: () =>
                    Platform.isAndroid ? SystemNavigator.pop() : exit(0),
                child: const Text('네'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    var _mediaquery = MediaQuery.of(context);
    double _deviceHeight = _mediaquery.size.height -
        _mediaquery.padding.top -
        _mediaquery.padding.bottom;
    double _deviceWidth = _mediaquery.size.width -
        _mediaquery.padding.right -
        _mediaquery.padding.left;
    print(_deviceHeight);
    print(_deviceWidth);
    print('page tab');
    final List<Widget> _pages = [
      HomeScreen1(
        user: _user,
        height: _deviceHeight,
        width: _deviceWidth,
      ),
      RecordCalendarScreen(
        user: _user,
        height: _deviceHeight,
        width: _deviceWidth,
      ),
      HomeScreen3(
        user: _user,
        height: _deviceHeight,
        width: _deviceWidth,
      ),
    ];

    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
        body: SafeArea(
          child: _pages[_currentPage],
        ),
        bottomNavigationBar: SizedBox(
          height: 72,
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            iconSize: 36,
            currentIndex: _currentPage,
            onTap: _selectPage,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.black26,
            showUnselectedLabels: false,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: '홈 화면',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: '기록하기',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: '커뮤니티',
              ),
            ],
          ),
        ),
        floatingActionButton: _currentPage == 1
            ? Page1Button(user: _user)
            : _currentPage == 2
                ? Page2Button(user: _user)
                : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }
}

class Page1Button extends StatelessWidget {
  const Page1Button({
    Key? key,
    required User? user,
  })  : _user = user,
        super(key: key);

  final User? _user;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () =>
          Navigator.of(context).pushNamed(RecordScreen.routeName, arguments: {
        'user': _user,
        'date': null,
        'title': null,
        'type': null,
        'key': null,
        'isEditMode': true,
      }),
      child: const Icon(Icons.add),
      backgroundColor: const Color(0xFF1568B3),
      mini: true,
    );
  }
}

class Page2Button extends StatelessWidget {
  const Page2Button({
    Key? key,
    required User? user,
  })  : _user = user,
        super(key: key);

  final User? _user;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (_user == null) {
          needLogin(context);
          return;
        }
        Navigator.of(context).pushNamed(
          BoardInputScreen.routeName,
          arguments: _user,
        );
      },
      child: const Icon(Icons.edit, size: 20),
      backgroundColor: const Color(0xFF1568B3),
      mini: true,
    );
  }
}

void needLogin(BuildContext context) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text(
        '로그인 이후에 가능해요.',
        style: TextStyle(
          fontSize: 14,
        ),
      ),
      duration: Duration(seconds: 2),
    ),
  );
}
