import 'package:flutter/material.dart';
import 'package:luxury_guide_project/pages/shimmer.dart';
import 'package:provider/provider.dart';
import '../model/m_user.dart';
import '../view_model/general_page_view_model.dart';
import 'home_page.dart';

class GetSessionOwnerPage extends StatefulWidget {
  const GetSessionOwnerPage({Key? key}) : super(key: key);

  @override
  State<GetSessionOwnerPage> createState() => _GetSessionOwnerPageState();
}

class _GetSessionOwnerPageState extends State<GetSessionOwnerPage> {
  late Future<MUser> myFuture;
  @override
  void initState() {
    myFuture = Provider.of<GeneralPageViewModel>(context, listen: false)
        .getSessionOwner();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MUser>(
        future: myFuture,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            MUser sessionOwner = snapshot.data;
            print("session owner id: ${sessionOwner.userId}");
            if(sessionOwner.userId!=null){
              return HomePage(sessionOwner: sessionOwner);
            }else{
              return Scaffold(body: Center(child: Text("Hata Olustu"),));
          }
          } else if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text("Hata Olustu: ${snapshot.error}"),));
          }
          return Center(
            child: LoadingListPage(),
          );

          return Container();
        });
  }
}
