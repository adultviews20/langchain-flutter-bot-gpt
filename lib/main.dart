import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:langchan/screens/chat_screen.dart';

import 'assets/constvar.dart';


void main() {
  runApp(const ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: scafoldBGcolor,
        appBarTheme: const AppBarTheme(color: chatCard),
      ),
      home: const ChatScreen(),
    );
  }
}
