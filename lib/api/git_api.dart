import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:git_cleaner/models/user_model.dart';
import 'package:http/http.dart' as http;

abstract class GitInterface {
  void getUserData(String token) async {}
  void getUserRepository(String username, String token) async {}
  void getUserFollowing(String token) async {}
}

class GitApi implements GitInterface {
  GitUserModel userModel;

  String tokenTemp = "44d29ba1d4cbc13f8d807f6a19659da02c7c5afe";

  @override
  Future<GitUserModel> getUserData(String token) async {
    String url = "https://api.github.com/user";

    try {
      Response response =
          await Dio(BaseOptions(headers: {"Authorization": "token $token", "Accept": "application/vnd.github.v3+json"}))
              .get(url);
      final resultReponse = json.decode(response.toString());
      userModel = GitUserModel.fromJson(resultReponse);
    } catch (e) {
      print(e);
    }
    return userModel;
  }

  @override
  Future<dynamic> getUserRepository(String username, String token) async {
    var decodedJson;
    try {
      http.Response response = await http.get("https://api.github.com/users/AjjuSingh/repos", headers: {
        "Authorization": "token $token",
        "Accept": "application/vnd.github.v3+json",
      });

      decodedJson = jsonDecode(response.body);
    } catch (e) {
      print(e);
    }
    return decodedJson;
  }

  @override
  Future<dynamic> getUserFollowing(String token) async {
    var decodedJson;
    try {
      http.Response response = await http.get("https://api.github.com/user/following",
          headers: {"Authorization": "token $token", "Accept": "application/vnd.github.v3+json"});

      decodedJson = jsonDecode(response.body);
      print(decodedJson.length);
    } catch (e) {
      print(e);
    }
    return decodedJson;
  }
}
