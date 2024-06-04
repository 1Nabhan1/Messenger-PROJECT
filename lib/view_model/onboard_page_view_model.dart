import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class OnBoardPageViewModel with ChangeNotifier{
  AuthService _authService = AuthService.authService;
 User? currentUser;

  // OnBoardPageViewModel()

  User? getCurrentUser() {
    User? myCurrentUser = _authService.currentUser();
    currentUser=myCurrentUser;
    notifyListeners();
    return null;
  }


  Stream<User?> authStateChanges() {
    Stream<User?> authStream = _authService.authStateChanges();
    return authStream;
  }
}