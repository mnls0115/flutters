/// Packeages ///
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:soaproject/Provider/board.dart';
import 'package:soaproject/Provider/page_animation.dart';
import 'package:soaproject/Screens/Auths/find_auth_screen.dart';
import 'package:soaproject/Screens/Board/board_detail_screen.dart';
import 'package:soaproject/Screens/Board/board_input_screen.dart';

/// Providers ///
import 'Provider/user_info.dart';
import 'Provider/eval_provider.dart';
import 'Provider/record.dart';

/// Screens ///
import 'Screens/Auths/signup_screen.dart';
import 'Screens/Evals/evaluation_screens.dart';
import 'Screens/Records/record_input_screen.dart';
import 'Screens/tab_bar_screen.dart';
import 'package:soaproject/Screens/Settings/re_signup_screen.dart';
import 'package:soaproject/Screens/Settings/setting_screen.dart';
import 'package:soaproject/Screens/Auths/login_screen.dart';
import 'package:soaproject/Screens/Evals/evaluation_before_screens.dart';
import 'package:soaproject/Screens/health_input_Screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<EvalProdiver>(
          create: (_) => EvalProdiver(),
        ),
        ChangeNotifierProvider<Record>(
          create: (_) => Record(),
        ),
        ChangeNotifierProvider<UserInfoprovider>(
          create: (_) => UserInfoprovider(),
        ),
        ChangeNotifierProvider<BoardProvider>(
          create: (_) => BoardProvider(),
        ),
      ],
      child: MaterialApp(
        title: '첫걸음',
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            toolbarHeight: 60,
            titleTextStyle: TextStyle(
              fontSize: 24,
            ),
            color: Color(0xFF1568B3),
            centerTitle: true,
          ),
          primaryColor: const Color(0xFF1568B3),
          errorColor: const Color(0xFFB31568),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(const Color(0xFF1568B3)),
            ),
          ),
        ).copyWith(
          pageTransitionsTheme: PageTransitionsTheme(
            builders: <TargetPlatform, PageTransitionsBuilder>{
              TargetPlatform.android: CustomTransitionsBuilder(),
              TargetPlatform.iOS: CustomTransitionsBuilder(),
            },
          ),
        ),
        home: const TabBarScreen(),
        routes: {
          TabBarScreen.routeName: (_) => const TabBarScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          RecordScreen.routeName: (_) => const RecordScreen(),
          EvaluationScreen.routeName: (_) => const EvaluationScreen(),
          SignUpScreen.routeName: (_) => const SignUpScreen(),
          ResignUpScreen.routeName: (_) => const ResignUpScreen(),
          HealthInputScreen.routeName: (_) => const HealthInputScreen(),
          SettingScreen.routeName: (_) => const SettingScreen(),
          BoardDetailScreen.routeName: (_) => const BoardDetailScreen(),
          BoardInputScreen.routeName: (_) => const BoardInputScreen(),
          FindAuthScreen.routeName: (_) => const FindAuthScreen(),
          EvaliationBeforeScreen.routeName: (_) =>
              const EvaliationBeforeScreen(),
        },
      ),
    );
  }
}
