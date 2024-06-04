import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../view_model/onboard_page_view_model.dart';
import 'get_session_owner_page.dart';
import 'onboding/onboding_screen.dart';

class OnBoardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? currentUser = Provider.of<OnBoardPageViewModel>(context).currentUser;
    if (currentUser != null) {
      // User is logged in, navigate to GetSessionOwnerPage
      return GetSessionOwnerPage();
    } else {
      // User is not logged in, navigate to OnboardingScreen
      return OnbodingScreen();
    }
  }
}
