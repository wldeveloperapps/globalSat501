

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restart_app/restart_app.dart';

class Tools {



  //***************************************************************************
  static void reboot(){
    Restart.restartApp();
  }
  //***************************************************************************
  static Future  delay(int msec) async{
    await Future.delayed(Duration(milliseconds: msec));
  }
  //***************************************************************************
  static void snackBar(String text,{Duration duration:const Duration(milliseconds: 3000)}) {
    final context=Get.context;
    if(context==null)return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        content: Text(text),

              ),
    );
  }

  //***************************************************************************
  static Future<bool> askQuestion(String tittle,String ok,String cancel,String str) async {
    final context=Get.context!;
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius:
          BorderRadius.all(Radius.circular(15))),
          title: Text(tittle),
          content: Text(str),
          actions: <Widget>[
            cancel.isNotEmpty?ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
              child: Text(cancel,style:TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ):Container(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlueAccent),
              child: Text(ok,style:TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }


}
