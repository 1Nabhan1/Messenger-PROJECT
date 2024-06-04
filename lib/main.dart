import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:luxury_guide_project/pages/on_board_page.dart';
import 'package:luxury_guide_project/services/notification_service.dart';
import 'package:luxury_guide_project/services/shared_pref_service.dart';
import 'package:luxury_guide_project/view_model/general_page_view_model.dart';
import 'package:luxury_guide_project/view_model/onboard_page_view_model.dart';
import 'package:provider/provider.dart';

// Firebase options, usually extracted to a separate file
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyDdfCe3xT6atUEj0Q5C_IemKqSE4c83S0M",
  appId: "1:923096105637:android:2bdc58ce87054bbf6d834c",
  messagingSenderId: "923096105637",
  projectId: "messenger-app-75ded",
);

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: firebaseOptions);

  print("Background Message received in Data section: ${message.data}");
  print(
      "Background Message received in Notification section: ${message.notification}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await NotificationService().setUpFlutterNotifications();
  await SharedPref.instance.setup();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GeneralPageViewModel()),
        ChangeNotifierProvider(create: (context) => OnBoardPageViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OnBoardPage(),
    );
  }
}
