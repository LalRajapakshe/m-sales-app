import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:m_sales/screens/splash_screen.dart';
import 'package:m_sales/services/auth_service.dart';
import 'package:m_sales/services/cart_service.dart';
import 'package:m_sales/services/customer_service.dart';
import 'package:millimeters/millimeters.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(Millimeters.fromView(
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        title: 'Sales App',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
