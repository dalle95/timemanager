import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../providers/actiontypes.dart';
import '../providers/boxes.dart';
import '../providers/tasks.dart';
import '../providers/auth.dart';
import '../providers/worktimes.dart';
import '../providers/materials.dart';

import '../screens/detail/worktime_detail.dart';
import '../screens/list/worktime_list_screen.dart';
import '../screens/list/material_list_screen.dart';
import '../screens/tabs_screen.dart';
import '../screens/detail/box_detail_screen.dart';
import '../screens/auth_screen.dart';
import '../screens/list/task_list_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/detail/task_detail.dart';
import '../screens/list/actiontype_list_screen.dart';
import '../screens/list/box_list_screen.dart';

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
            auth.user.id,
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
        ChangeNotifierProxyProvider<Auth, Materials>(
          update: (ctx, auth, previousMaterials) => Materials(
            auth.urlAmbiente,
            auth.token,
            previousMaterials == null ? [] : previousMaterials.materials,
          ),
        ),
        ChangeNotifierProxyProvider<Auth, WorkTimes>(
          update: (ctx, auth, previousWorkTimes) => WorkTimes(
            auth.urlAmbiente,
            auth.token,
            auth.user,
            previousWorkTimes == null ? [] : previousWorkTimes.workTimes,
          ),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('it'),
          ],
          title: 'TimeManager',
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.blue,
            primaryColorDark: const Color.fromARGB(255, 11, 50, 113),
            colorScheme: ColorScheme.fromSwatch().copyWith(
              primary: Colors.blue,
              secondary: Colors.orange,
              background: Colors.white,
            ),
            backgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black87,
            ),
            textTheme: const TextTheme(
              headline1: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
              headline6: TextStyle(fontSize: 25, fontStyle: FontStyle.normal),
              bodyText1: TextStyle(
                  fontSize: 20.0, color: Colors.white, fontFamily: 'Hind'),
              bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
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
            MaterialListScreen.routeName: (ctx) => MaterialListScreen(),
            WorkTimeListScreen.routeName: (ctx) => WorkTimeListScreen(),
            WorkTimeDetailScreen.routeName: (ctx) => WorkTimeDetailScreen(),
          },
        ),
      ),
    );
  }
}
