import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/work_orders.dart';
import '../providers/auth.dart';

import '../screens/auth_screen.dart';
import '../screens/wo_list_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/wo_detail_screen.dart';

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
        )
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
          },
        ),
      ),
    );
  }
}
