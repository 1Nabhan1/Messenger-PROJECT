import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/alert_dialog_helper.dart';
import '../model/m_user.dart';
import '../view_model/sign_up_page_view_model.dart';
import 'login_page.dart';

class SignUpPage extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignUpPageViewModel>(
      create: (context) => SignUpPageViewModel(),
      builder: (BuildContext context, child) {
        return Scaffold(
          backgroundColor: Color(0xffe8ebed),
          body: ListView(reverse: true, children: [
            Container(
                padding: EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Form(
                      child: Column(
                        children: [
                          Stack(
                            //I added stack so that i can position it anywhere i want with the coordinates like left ,right,bottom.
                            children: <Widget>[
                              Positioned(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    "assets/images/talkingg.png",
                                  ),
                                ),
                              ),
                            ],
                          ),

                          //The Username,Email,Password Input fields.
                          SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Color(0xffe1e2e3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 5,
                                    blurRadius: 7,
                                    offset: Offset(0, 3),
                                  ),
                                ]),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: Color(0xfff5f8fd),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: TextFormField(
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your Name and Surname';
                                        }
                                        return null;
                                      },
                                      controller:
                                          Provider.of<SignUpPageViewModel>(
                                                  context)
                                              .displayNameController,
                                      decoration: InputDecoration(
                                          hintText: "Full Name",
                                          prefixIcon: Icon(Icons.person),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: Color(0xfff5f8fd),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: TextFormField(
                                      validator: (String? value) {
                                        if (value != null &&
                                            !value.endsWith("@gmail.com")) {
                                          return "Please enter a valid Gmail address";
                                        }
                                        return null; // Return null if validation succeeds
                                      },
                                      controller:
                                          Provider.of<SignUpPageViewModel>(
                                                  context)
                                              .emailController,
                                      decoration: InputDecoration(
                                          hintText: "E mail",
                                          prefixIcon: Icon(Icons.person),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: Color(0xfff5f8fd),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: TextFormField(
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter password';
                                        }
                                        return null;
                                      },
                                      controller:
                                          Provider.of<SignUpPageViewModel>(
                                                  context)
                                              .passwordController,
                                      decoration: InputDecoration(
                                          hintText: "Password",
                                          prefixIcon: Icon(Icons.lock),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 5),
                                    decoration: BoxDecoration(
                                        color: Color(0xfff5f8fd),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: TextFormField(
                                      obscureText: true,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter password';
                                        } else if (Provider.of<
                                                        SignUpPageViewModel>(
                                                    context,
                                                    listen: false)
                                                .passwordController
                                                .text !=
                                            Provider.of<SignUpPageViewModel>(
                                                    context,
                                                    listen: false)
                                                .againPasswordController
                                                .text) {
                                          return "Password do not match";
                                        }
                                        return null;
                                      },
                                      controller:
                                          Provider.of<SignUpPageViewModel>(
                                                  context)
                                              .againPasswordController,
                                      decoration: InputDecoration(
                                          hintText: "Password Again",
                                          prefixIcon: Icon(Icons.lock),
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff5b61b9),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 70, vertical: 20),
                              textStyle: TextStyle(
                                  fontSize: 30, fontWeight: FontWeight.bold)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              Provider.of<SignUpPageViewModel>(context,
                                      listen: false)
                                  .isLoading = true;
                              final MUser createdUser =
                                  await Provider.of<SignUpPageViewModel>(
                                          context,
                                          listen: false)
                                      .createAndSaveUserWithEmailAndPassword();
                              if (createdUser.authState ==
                                  AuthState.SUCCESFULL) {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => LoginPage()));
                                Provider.of<SignUpPageViewModel>(context,
                                        listen: false)
                                    .isLoading = false;
                              } else if (createdUser.authState ==
                                  AuthState.ERROR) {
                                AlertDialogHelper.showMyDialog(
                                    context: context,
                                    alertDialogTitle: "Warning",
                                    alertDialogContent: "An error occurred",
                                    onPressed: () {
                                      Navigator.pop(context);
                                    });
                                Provider.of<SignUpPageViewModel>(context,
                                        listen: false)
                                    .isLoading = false;
                              } else if (createdUser.authState ==
                                  AuthState.WEAKPASSWORD) {
                                AlertDialogHelper.showMyDialog(
                                    context: context,
                                    alertDialogTitle: "Warning",
                                    alertDialogContent: "Weak Password",
                                    onPressed: () {
                                      Navigator.pop(context);
                                    });
                                Provider.of<SignUpPageViewModel>(context,
                                        listen: false)
                                    .isLoading = false;
                              } else if (createdUser.authState ==
                                  AuthState.EMAILINUSE) {
                                AlertDialogHelper.showMyDialog(
                                    context: context,
                                    alertDialogTitle: "Warning",
                                    alertDialogContent: "E mail already in use",
                                    onPressed: () {
                                      Navigator.pop(context);
                                    });
                                Provider.of<SignUpPageViewModel>(context,
                                        listen: false)
                                    .isLoading = false;
                              } else {
                                AlertDialogHelper.showMyDialog(
                                    context: context,
                                    alertDialogTitle: "Warning",
                                    alertDialogContent:
                                        "Unexpected error occurred",
                                    onPressed: () {
                                      Navigator.pop(context);
                                    });
                                Provider.of<SignUpPageViewModel>(context,
                                        listen: false)
                                    .isLoading = false;
                              }
                            }
                          },
                          child: Provider.of<SignUpPageViewModel>(context)
                                      .getisLoading ==
                                  true
                              ? SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  "Sign Up",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700),
                                ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text("Already have an account?"),
                      SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          child: Text("Sign In",
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xff5b61b9),
                                  fontSize: 18)),
                        ),
                      ),
                    ]),
                  ],
                )),
          ]),
        );
      },
    );
  }
}
