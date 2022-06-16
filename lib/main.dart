import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:testusdacc/screens/wallet_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        theme: ThemeData(scaffoldBackgroundColor: Colors.black),
        debugShowCheckedModeBanner: false,
        home: const WalletScreen(),
      ),
    );
  }
}
