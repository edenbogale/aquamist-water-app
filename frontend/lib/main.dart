// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/signin_page.dart';
import 'screens/signup_page.dart';
import 'screens/main_wrapper.dart';
import 'screens/cover_screen.dart'; // ✅
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final userProvider = UserProvider();
  final orderProvider = OrderProvider();

  await userProvider.loadUser();

  if (userProvider.user != null) {
    await orderProvider.fetchOrders(userId: userProvider.user!.email);
  }

  runApp(
    WaterDeliveryApp(
      userProvider: userProvider,
      orderProvider: orderProvider,
    ),
  );
}

class WaterDeliveryApp extends StatelessWidget {
  final UserProvider userProvider;
  final OrderProvider orderProvider;

  const WaterDeliveryApp({
    Key? key,
    required this.userProvider,
    required this.orderProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: userProvider),
        ChangeNotifierProvider.value(value: orderProvider),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Water Delivery App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Roboto',
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/cover', // ✅
        routes: {
          '/cover': (context) => CoverScreen(), // ✅
          '/': (context) => SignInPage(),
          '/signin': (context) => SignInPage(),
          '/signup': (context) => SignUpPage(),
          '/home': (context) => MainWrapper(),
        },
      ),
    );
  }
}
