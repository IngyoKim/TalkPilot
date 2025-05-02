import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:talk_pilot/src/pages/base_page.dart';
import 'package:talk_pilot/src/provider/login_provider.dart';
import 'package:talk_pilot/src/provider/project_provider.dart';
import 'package:talk_pilot/src/provider/user_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint(context.toString());
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
      ],
      child: MaterialApp(
        /// App title.
        title: 'Talk Pilot',
        theme: ThemeData(
          /// Default theme color
          /// 추후 변경 예정
          primarySwatch: Colors.blue,
        ),

        /// debug banner 삭제
        debugShowCheckedModeBanner: false,

        /// default home screen
        home: const BasePage(),
      ),
    );
  }
}
