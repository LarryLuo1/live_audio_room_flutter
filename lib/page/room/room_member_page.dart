import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:live_audio_room_flutter/service/zego_room_service.dart';
import 'package:live_audio_room_flutter/service/zego_speaker_seat_service.dart';
import 'package:provider/provider.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:live_audio_room_flutter/service/zego_user_service.dart';

import 'package:live_audio_room_flutter/model/zego_room_user_role.dart';
import 'package:live_audio_room_flutter/model/zego_user_info.dart';
import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_gen/gen_l10n/live_audio_room_localizations.dart';

class RoomMemberListItem extends StatelessWidget {
  const RoomMemberListItem({Key? key, required this.userInfo})
      : super(key: key);
  final ZegoUserInfo userInfo;

  @override
  Widget build(BuildContext context) {
    var userService = context.read<ZegoUserService>();
    var avatarIndex = userService.getUserAvatarIndex(userInfo.userID);
    return Row(
      children: [
        SizedBox(
          width: 68.w,
          height: 68.h,
          child: CircleAvatar(
            foregroundImage: AssetImage("images/seat_$avatarIndex.png"),
          ),
        ),
        const SizedBox(width: 24),
        Text(userInfo.userName, style: StyleConstant.roomMemberListNameText),
        const Expanded(child: Text('')),
        getRightWidgetByUserRole(context)
      ],
    );
  }

  Widget getRightWidgetByUserRole(BuildContext context) {
    switch (userInfo.userRole) {
      case ZegoRoomUserRole.roomUserRoleHost:
        return Text(AppLocalizations.of(context)!.roomPageRoleOwner,
            textDirection: TextDirection.rtl,
            style: StyleConstant.roomMemberListRoleText);
      case ZegoRoomUserRole.roomUserRoleSpeaker:
        return Text(AppLocalizations.of(context)!.roomPageRoleSpeaker,
            textDirection: TextDirection.rtl,
            style: StyleConstant.roomMemberListRoleText);
      case ZegoRoomUserRole.roomUserRoleListener:
        return SizedBox(
            width: 60.w,
            height: 60.h,
            child: IconButton(
              icon: Image.asset(StyleIconUrls.roomMemberMore),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    isDismissible: true,
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return SizedBox(
                          height: 60.h + 98.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 98.h,
                                width: 630.w,
                                child: CupertinoButton(
                                    color: Colors.white,
                                    onPressed: () {
                                      Navigator.pop(context);

                                      var roomService =
                                          context.read<ZegoRoomService>();
                                      var seatService = context
                                          .read<ZegoSpeakerSeatService>();
                                      // Speaker ID Set not include host id
                                      if (seatService.speakerIDSet.length >=
                                              7 ||
                                          roomService.roomInfo.isSeatClosed) {
                                        Fluttertoast.showToast(
                                            msg: AppLocalizations.of(context)!
                                                .roomPageNoMoreSeatAvailable,
                                            backgroundColor: Colors.grey);
                                        return;
                                      }

                                      // Call SDK to send invitation
                                      var userService =
                                          context.read<ZegoUserService>();
                                      userService
                                          .sendInvitation(userInfo.userID);
                                    },
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .roomPageInviteTakeSeat,
                                      style: TextStyle(
                                          color: const Color(0xFF1B1B1B),
                                          fontSize: 28.sp),
                                    )),
                              ),
                            ],
                          ));
                    });
              },
            ));
    }
  }
}

class RoomMemberPage extends HookWidget {
  const RoomMemberPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration:
          const BoxDecoration(color: StyleColors.roomPopUpPageBackgroundColor),
      padding: EdgeInsets.only(left: 0, top: 20.h, right: 0, bottom: 0),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
            height: 72.h,
            width: double.infinity,
            child: Consumer<ZegoUserService>(
                builder: (_, userService, child) => Center(
                    child: Text(
                        AppLocalizations.of(context)!
                            .roomPageUserList(userService.userList.length),
                        style: StyleConstant.roomBottomPopUpTitle)))),
        Consumer<ZegoUserService>(
            builder: (_, userService, child) => SizedBox(
                  width: double.infinity,
                  height: 658.h,
                  child: ListView.builder(
                    itemExtent: 108.h,
                    padding: EdgeInsets.only(
                        left: 36.w, top: 20.h, right: 46.w, bottom: 20.h),
                    itemCount: userService.userList.length,
                    itemBuilder: (_, i) {
                      ZegoUserInfo user = userService.userList[i];
                      return RoomMemberListItem(userInfo: user);
                    },
                  ),
                )),
      ]),
    ));
  }
}
