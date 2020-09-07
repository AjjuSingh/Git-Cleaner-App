import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:git_cleaner/api/git_api.dart';
import 'package:git_cleaner/components/repo_list_view.dart';
import 'package:git_cleaner/login/loginService.dart';
import 'package:git_cleaner/models/user_model.dart';
import 'package:git_cleaner/style/const.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  @override
  Widget build(BuildContext context) {
    String token = "44d29ba1d4cbc13f8d807f6a19659da02c7c5afe";
    GitApi gitApi = new GitApi();

    // TabController to check on which tab is currently switched
    TabController _tabController = new TabController(length: 2, vsync: this);


    @override
    void dispose() {
      super.dispose();
      _tabController.dispose();
    }

    return Consumer<LoginService>(
      builder: (context, loginService, widget) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: ColorSchemes().bitDark,
            appBar: AppBar(title: new Text(loginService.getUsername),
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                Tab(icon: Icon(Icons.library_books), child: Text("Repositories"),),
                Tab(icon: Icon(Icons.people_outline), child: Text("Following"),),
              ],
            ),),
            // ignore: missing_required_param
            drawer: Drawer(

              elevation: 5,
                child: FutureBuilder(
                  future: gitApi.getUserData(token),
                  builder: (context, snapshot){
                      if(snapshot.connectionState == ConnectionState.waiting){
                        return Center(child: CircularProgressIndicator());
                      }

                      GitUserModel model = snapshot.data;
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Padding(
                              padding: const EdgeInsets.only(top:24.0),
                              child: UserAccountsDrawerHeader(
                                decoration: BoxDecoration(
                                  color: ColorSchemes().lightDark,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                accountName: Text(model.login),
                                accountEmail: Text(model.email),
                                currentAccountPicture: CircleAvatar(
                                  backgroundImage: NetworkImage(model.avatarUrl),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center,
                            child: Text(model.bio, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: getDrawerItems(model),
                            ),
                          ),
                        ],
                      );
                },),
            ),
            body: TabBarView(
              controller: _tabController,
              physics: BouncingScrollPhysics(),
              children: [
                RepositoryListView(),
                RepositoryListView()
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                // Befire deleting ask for confirmation
                try {
                  var client = await http.delete("https://api.github.com/repos/AjjuSingh/test",headers: {
                    "Authorization" : "token 773cf8d2c72bd8061435188da90f761cfffba097",
                    "Accept": "application/vnd.github.v3+json"
                  });
                } catch(e){
                  print(e);
                }
              },
              child: new Icon(Icons.delete),
            ),
          ),
        );
      },
    );
  }


  List<Widget> getDrawerItems(GitUserModel model){
    TextStyle titleStyle = TextStyle(fontSize: 16);
    TextStyle valueStyle = TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
    DateFormat date = new DateFormat('yyyy-MM-dd');
    String getCreationDate = date.format(DateTime.parse(model.createdAt));

    return [
        Card(
          color: ColorSchemes().bitDark,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Account Stats\n", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Text("Followers", style: titleStyle),
                    new Text(model.followers.toString(), style: valueStyle,)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Text("Following", style: titleStyle),
                    new Text(model.following.toString(), style: valueStyle,)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Text("Public repos", style: titleStyle),
                    new Text(model.publicRepos.toString(), style: valueStyle,)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    new Text("Public repos", style: titleStyle),
                    new Text(model.publicGists.toString(), style: valueStyle,)
                  ],
                )
              ],
            ),
          ),
        ),
    ];
  }
}

launchUrl(String s) async{
  String url = s;
  if (await canLaunch(url)) {
  await launch(url);
  } else {
  throw 'Could not launch $url';
  }
}
