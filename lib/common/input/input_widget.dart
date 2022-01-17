import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:live_audio_room_flutter/common/style/styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InputWidget extends StatefulWidget {
  const InputWidget({Key? key}) : super(key: key);

  @override
  _InputWidgetState createState() => _InputWidgetState();
}

class _InputWidgetState extends State<InputWidget> {
  @override
  Widget build(BuildContext context) {
    TextEditingController editingController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.transparent,
//      resizeToAvoidBottomInset: false,
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
                onTapDown: (_) => Navigator.of(context).pop(),
                child: Container(
                  color: Colors.transparent,
                )),
          ),
          SafeArea(
            child: Container(
              color: Colors.white,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 36.w,
                  ),
                  Expanded(
                    child: Container(
                      margin:
                          EdgeInsets.only(top: 15.h, right: 22.w, bottom: 15.h),
                      decoration: const BoxDecoration(
                          color: StyleColors.roomMessageInputBgColor,
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      alignment: Alignment.center,
                      child: TextField(
                        autofocus: true,
                        inputFormatters: <TextInputFormatter>[
                          LengthLimitingTextInputFormatter(200)
                        ],
                        controller: editingController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 30.w, right: 30.w, top: 20.h, bottom: 20.h),
                          border: InputBorder.none,
                          //hintStyle: TextStyle(color: Color(0xffcccccc)),
                          //hintText: ""
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: (() {
                      var text = editingController.text.trim();
                      if (text.isNotEmpty) {
                        Navigator.pop(context, text);
                      }
                    }),
                    child: Container(
                      decoration: const BoxDecoration(
                          color: StyleColors.roomMessageSendButtonBgColor,
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, top: 10, bottom: 10),
                      alignment: Alignment.center,
                      child: const Text(
                        "发送",
                        style: StyleConstant.roomMessageSendButtonText,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36.w,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
