import 'package:ant_icons/ant_icons.dart';
import 'package:flutter/material.dart';
import 'package:git_cleaner/api/git_api.dart';
import 'package:git_cleaner/login/loginService.dart';
import 'package:git_cleaner/providers/repo_delete_provider.dart';
import 'package:git_cleaner/style/const.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

DateFormat date = new DateFormat('dd-MM-yyyy');

class RepositoryListView extends StatefulWidget {
  @override
  _RepositoryListViewState createState() => _RepositoryListViewState();
}

class _RepositoryListViewState extends State<RepositoryListView>
    with AutomaticKeepAliveClientMixin<RepositoryListView> {
  GitApi gitApi = new GitApi();
  bool isSelected = false;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Consumer<LoginService>(
      builder: (context, _loginService, child) => FutureBuilder(
        future: gitApi.getUserRepository(_loginService.getUsername, _loginService.getToken),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ChangeNotifierProvider(
            create: (_) => RepositoryDeleteProvider(),
            child: ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, pos) {
                return RepositoryCard(
                  data: snapshot.data[pos],
                );
              },
              physics: BouncingScrollPhysics(),
              //children: _repoList,
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RepositoryCard extends StatefulWidget {
  final dynamic data;

  const RepositoryCard({Key key, this.data}) : super(key: key);
  @override
  _RepositoryCardState createState() => _RepositoryCardState();
}

class _RepositoryCardState extends State<RepositoryCard> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    RepositoryDeleteProvider provider = Provider.of<RepositoryDeleteProvider>(context, listen: false);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: ColorSchemes().lightDark,
          borderRadius: BorderRadius.circular(10),
          child: ExpansionTile(
            maintainState: true,
            title: Row(children: [
              Checkbox(
                  value: isSelected,
                  onChanged: (val) {
                    val ? print("true") : print("false");
                    setState(() {
                      isSelected = val;
                    });
                    val ? provider.addRepo(widget.data["url"]) : provider.deleteRepo(widget.data["url"]);
                  }),
              Flexible(
                  child: Text(
                widget.data["name"],
                style: TextStyle(fontSize: 18),
              )),
            ]),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            tilePadding: EdgeInsets.all(8.0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Chip(
                    avatar: Icon(Icons.star_border),
                    label: Text(widget.data["stargazers_count"].toString()),
                  ),
                  Chip(
                    avatar: Icon(Icons.remove_red_eye),
                    label: Text(widget.data["watchers"].toString()),
                  ),
                  Chip(
                    avatar: Icon(AntIcons.fork),
                    label: Text(widget.data["forks"].toString()),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Last Updated: " + date.format(DateTime.parse(widget.data["updated_at"]))),
                    Text("Created On: " + date.format(DateTime.parse(widget.data["created_at"]))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
