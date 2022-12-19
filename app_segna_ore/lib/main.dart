import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/actiontypes.dart';
import '../providers/boxes.dart';
import '../providers/tasks.dart';
import '../providers/auth.dart';
import 'providers/worktimes.dart';

import '../screens/detail/worktime_detail.dart';
import 'screens/list/worktime_list_screen.dart';
import '../screens/tabs_screen.dart';
import '../screens/detail/box_detail_screen.dart';
import '../screens/auth_screen.dart';
import 'screens/list/task_list_screen.dart';
import '../screens/splash_screen.dart';
import 'screens/detail/task_detail.dart';
import 'screens/list/actiontype_list_screen.dart';
import 'screens/list/box_list_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Tasks>(
          //create: (context) => WorkOrders(),
          update: (ctx, auth, previousTasks) => Tasks(
            auth.urlAmbiente,
            auth.token,
            auth.userId,
            previousTasks == null ? [] : previousTasks.tasks,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, ActionTypes>(
          update: (ctx, auth, previousActionTypes) => ActionTypes(
            auth.urlAmbiente,
            auth.token,
            previousActionTypes == null ? [] : previousActionTypes.actionTypes,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, Boxes>(
          update: (ctx, auth, previousBoxes) => Boxes(
            auth.urlAmbiente,
            auth.token,
            previousBoxes == null ? [] : previousBoxes.boxes,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, WorkTimes>(
          update: (ctx, auth, previousWorkTimes) => WorkTimes(
            auth.urlAmbiente,
            auth.token,
            auth.userId,
            previousWorkTimes == null ? [] : previousWorkTimes.workTimes,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'TimeManager',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            accentColor: Colors.orange,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black87,
            ),
          ),
          home: auth.isAuth
              ? TabsScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            TabsScreen.routeName: (ctx) => TabsScreen(),
            TaskListScreen.routeName: (ctx) => TaskListScreen(),
            TaskDetailScreen.routeName: (ctx) => TaskDetailScreen(),
            ActionTypeListScreen.routeName: (ctx) => ActionTypeListScreen(),
            BoxListScreen.routeName: (ctx) => BoxListScreen(),
            BoxDetailScreen.routeName: (ctx) => BoxDetailScreen(),
            WorkTimeListScreen.routeName: (ctx) => WorkTimeListScreen(),
            WorkTimeDetailScreen.routeName: (ctx) => WorkTimeDetailScreen(),
          },
        ),
      ),
    );
  }
}
