import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/plugin/ZIMPlugin.dart';

enum LoginState {
  loginStateLoggedOut,
  loginStateLoggingIn,
  loginStateLoggedIn,
  loginStateLoginFailed,
}

typedef LoginCallback = Function(int);

class ZegoUserService extends ChangeNotifier {
  // TODO@oliver update userList on SDK callback and notify changed
  late List<ZegoUserInfo> userList = [
    ZegoUserInfo("111", "Host Name", ZegoRoomUserRole.roomUserRoleHost),
    ZegoUserInfo("222", "Speaker Name", ZegoRoomUserRole.roomUserRoleHost),
  ]; // Init list for UI test
  late Map<String, ZegoUserInfo> userDic = {
    userList[0].userID: userList[0],
    userList[1].userID: userList[1],
  };

  late ZegoUserInfo localUserInfo;
  late String token;
  int totalUsersNum = 0;
  LoginState loginState = LoginState.loginStateLoggedOut;

  ZegoUserService() {
    ZIMPlugin.onRoomMemberJoined = onRoomMemberJoined;
    ZIMPlugin.onRoomMemberLeave = onRoomMemberLeave;
  }

  void fetchOnlineRoomUsersWithPage(int page) {
    // TODO@oliver fetch users info and update userList
  }

  Future<int> fetchOnlineRoomUsersNum(String roomID) async {
    var result = await ZIMPlugin.queryRoomOnlineMemberCount(roomID);
    int code = result['errorCode'];
    if (code == 0) {
      totalUsersNum = result['count'];
      notifyListeners();
    }
    return code;
  }

  Future<int> login(ZegoUserInfo info, String token) async {
    localUserInfo = info;
    if (info.userName.isEmpty) {
      localUserInfo.userName = info.userID;
    }
    loginState = LoginState.loginStateLoggingIn;
    notifyListeners();

    // Note: token is generate in native code
    var result = await ZIMPlugin.login(info.userID, info.userName, "");
    int code = result['errorCode'];

    loginState = code != 0
        ? LoginState.loginStateLoginFailed
        : LoginState.loginStateLoggedIn;
    notifyListeners();

    return code;
  }

  Future<int> logout() async {
    var result = await ZIMPlugin.logout();
    return result['errorCode'];
  }

  Future<int> sendInvitation(String userID) async {
    var result = await ZIMPlugin.sendPeerMessage(userID, "", 1);
    return result['errorCode'];
  }

  // TODO@oliveryang
  void setUserRoleForUITest(ZegoRoomUserRole role) {
    localUserInfo.userRole = role;
    notifyListeners();
  }

  void onRoomMemberJoined(
      String roomID, List<Map<String, dynamic>> memberList) {
    for (final item in memberList) {
      var member = new ZegoUserInfo.formJson(item);
      userList.add(member);
      userDic[member.userID] = member;
    }
    notifyListeners();
  }

  void onRoomMemberLeave(String roomID, List<Map<String, dynamic>> memberList) {
    for (final item in memberList) {
      var member = new ZegoUserInfo.formJson(item);
      userList.removeWhere((element) => element.userID == member.userID);
      userDic.removeWhere((key, value) => key == member.userID);
    }
    notifyListeners();
  }

  void onReceivePeerMessage() {
    // userList.addAll(memberList);
    notifyListeners();
  }
}
