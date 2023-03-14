import 'dart:convert';
import 'package:mykao_talk_flutter/imports.dart';
import 'package:mykao_talk_flutter/model/member_model.dart';
import 'package:http/http.dart' as http;
import 'package:mykao_talk_flutter/model/room_model.dart';

class APIService {
  static const baseURL = 'http://10.0.2.2:5000';

  static Future<bool> registUser(ChattingAppUser user) async {
    final url = Uri.parse('$baseURL/signup');

    // 등록할 회원의 정보
    var userInfo = {
      "username": user.username,
      "userId": user.userId,
      "userPw": user.userPw,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(userInfo),
    );
    var result = jsonDecode(response.body);
    return result['redundancy'];
  }

  static Future<ChattingAppUser> getMemberById(String id) async {
    final url = Uri.parse('$baseURL/login');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'userId': id}),
    );
    print(response.body);
    var result = jsonDecode(response.body);
    print(result);
    return ChattingAppUser.fromJson(result);
  }

  static Future<List<RoomModel>> getUserRoomsById(String id) async {
    final url = Uri.parse('$baseURL/userChattingRooms');
    List<RoomModel> rooms = [];

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'roomId': id}),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final roomsFromFlask = jsonDecode(response.body);
      for (var room in roomsFromFlask) {
        rooms.add(RoomModel.fromJson(room));
        print(room);
      }
      return rooms;
    }
    throw Error();
  }

  static Future<void> deleteUserRoomsById({
    required String roomid,
    required String userid,
    required String username,
  }) async {
    final url = Uri.parse('$baseURL/userChattingRooms/delete');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'roomId': roomid,
        'userId': userid,
        'username': username,
      }),
    );
  }

  static Future<void> makeNewUserRooms({
    required String roomid,
    required String userid,
    required String username,
  }) async {
    final url = Uri.parse('$baseURL/userChattingRooms/create');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'roomId': roomid,
        'userId': userid,
        'username': username,
      }),
    );
    print(response.statusCode);
  }
}
