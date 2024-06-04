import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/m_user.dart';
import '../services/firestore_service.dart';
import '../services/shared_pref_service.dart';
import '../view_model/general_page_view_model.dart';
import '../view_model/profile_tab_page_view_model.dart';
import 'Occupation_page.dart';
import 'profile_setting_page.dart';
import 'chat_screen/style.dart';

class ProfilePage extends StatelessWidget {
  final MUser SessionOwner;

  ProfilePage({required this.SessionOwner, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ProfileDetails(
      SessionOwner: SessionOwner,
    );
  }
}

class ProfileDetails extends StatefulWidget {
  final MUser SessionOwner;

  ProfileDetails({required this.SessionOwner});

  @override
  State<ProfileDetails> createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  late Future<List<Map<String, dynamic>>> _occupationsFuture;

  FutureOr onGoBack(dynamic value) {
    if (value != null) {
      setState(() {
        _occupationsFuture = _fetchOccupations();
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOccupations() async {
    return await FirestoreService().getOccupations(widget.SessionOwner.userId!);
  }

  @override
  void initState() {
    super.initState();
    _occupationsFuture = _fetchOccupations();
  }

  Future<void> deleteOccupation(
      String userId, Map<String, dynamic> occupationId) async {
    try {
      await FirestoreService().deleteOccupation(userId, occupationId);
      setState(() {
        _occupationsFuture = _fetchOccupations();
      });
    } catch (e) {
      print('Error deleting occupation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MUser>(
      future: Provider.of<ProfileTabPageViewModel>(context, listen: false)
          .getNewSessionOwner(widget.SessionOwner.userId!),
      builder: (BuildContext context, AsyncSnapshot<MUser> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        } else if (snapshot.hasData) {
          MUser newSessionOwner = snapshot.data!;
          return Scaffold(
            backgroundColor: const Color(0xff5b61b9),
            body: ListView(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        child: const PrimaryText(
                            text: 'Settings', color: Colors.black87),
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true)
                              .push(
                                MaterialPageRoute(
                                  builder: (context) => ChangeNotifierProvider(
                                    create: (context) =>
                                        ProfileTabPageViewModel(),
                                    child: ProfileSettingPage(
                                      gelenSessionOwner: newSessionOwner,
                                    ),
                                  ),
                                ),
                              )
                              .then((value) => onGoBack(value));
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 30, left: 40),
                  height: 200,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PrimaryText(
                        text: 'Profile \nInformation',
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 30, left: 20, right: 20),
                  height: MediaQuery.of(context).size.height - 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(100)),
                          child: Provider.of<ProfileTabPageViewModel>(context)
                                      .image ==
                                  null
                              ? Image.network(
                                  height: 200.0,
                                  width: 200.0,
                                  fit: BoxFit.cover,
                                  "${newSessionOwner.photoUrl}")
                              : Image.file(
                                  height: 150.0,
                                  width: 150.0,
                                  fit: BoxFit.cover,
                                  File(Provider.of<ProfileTabPageViewModel>(
                                              context)
                                          .image!
                                          .path)
                                      .absolute,
                                ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      ListTile(
                        title: const Text(
                          "Full Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        subtitle: Text(
                          "${newSessionOwner.displayName}",
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      ListTile(
                        title: const Text(
                          "Email ",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 24),
                        ),
                        subtitle: Text(
                          "${newSessionOwner.email}",
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Occupation',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OccupationPage(
                                      userId: widget.SessionOwner.userId!,
                                    ),
                                  ),
                                ).then((value) => onGoBack(value));
                              },
                              child: const Icon(Icons.add),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _occupationsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return const Text('Error fetching occupations');
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Text('No occupations found');
                          } else {
                            return Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  var occupation = snapshot.data![index];
                                  var fromDate = occupation['fromDate'] != null
                                      ? occupation['fromDate']
                                          .toDate()
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0]
                                      : 'N/A';
                                  var toDate = occupation['toDate'] != null
                                      ? occupation['toDate']
                                          .toDate()
                                          .toLocal()
                                          .toString()
                                          .split(' ')[0]
                                      : 'N/A';

                                  return ListTile(
                                    title: Text(occupation['occupation']),
                                    trailing: GestureDetector(
                                      onTap: () async {
                                        await deleteOccupation(
                                            widget.SessionOwner.userId!,
                                            occupation['id']);
                                      },
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                    subtitle:
                                        Text('From: $fromDate To: $toDate'),
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(
                        height: 18,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 70, vertical: 20),
                          textStyle: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          await Provider.of<GeneralPageViewModel>(context,
                                  listen: false)
                              .signOut();
                          await CacheManager2.signOut.write("log out");
                          Navigator.of(context, rootNavigator: true)
                              .popUntil(ModalRoute.withName("/"));
                        },
                        child: const Text(
                          "Log Out",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
