import 'package:carl_touch_api/screens/box_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/actiontypes.dart';
import '../providers/boxes.dart';
import '../providers/work_orders.dart';
import '../providers/auth.dart';

import '../screens/auth_screen.dart';
import '../screens/wo_list_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/wo_detail_screen.dart';
import '../screens/actiontype_list_screen.dart';
import '../screens/box_list_screen.dart';

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
        ChangeNotifierProxyProvider<Auth, WorkOrders>(
          //create: (context) => WorkOrders(),
          update: (ctx, auth, previousWorkOrders) => WorkOrders(
            auth.urlAmbiente,
            auth.token,
            auth.userId,
            previousWorkOrders == null ? [] : previousWorkOrders.wo,
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
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Better Touch',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            accentColor: Colors.orange,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black87,
            ),
          ),
          home: auth.isAuth
              ? WOListScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            WoDetailScreen.routeName: (ctx) => WoDetailScreen(),
            ActionTypeListScreen.routeName: (ctx) => ActionTypeListScreen(),
            BoxListScreen.routeName: (ctx) => BoxListScreen(),
            BoxDetailScreen.routeName: (ctx) => BoxDetailScreen(),
          },
        ),
      ),
    );
  }
}
