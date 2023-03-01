

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_sat_501/app/modules/home_module/home_controller.dart';
import 'package:global_sat_501/app/modules/home_module/widgets/button_selection.dart';
import 'package:global_sat_501/app/utils/constants.dart';
import 'package:usb_serial/usb_serial.dart';

import '../../data/provider/local_file_provider.dart';
import '../../utils/tools.dart';
import '../../utils/usb_serial.dart';

class homePage extends GetView<homeController> {
  TextEditingController filterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery
        .of(context)
        .size
        .width;
    final double h = MediaQuery
        .of(context)
        .size
        .height;
    final _iconSize = w * .16;
    final _textSize = w * .04;


    return Scaffold(
      backgroundColor: Colors.white70,
      body: Obx(() {
        if(!controller.portOpened) {
          print("scaffold");
          return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/wiloclogoTrasparent.png')),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: h * .7,),
                  SizedBox(height: h * .1,
                      width: w * .2,
                      child: CircularProgressIndicator(color: Colors.green,)),
                  SizedBox(
                    height: 20,
                  ),
                  Text('Wait for CONNECTION'),
                  Text('Plugin the usb and press help button'),
                  Text(controller.info),
                  //controller.info.isNotEmpty?Text(controller.info):Container()
                ],
              ));
        }
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                '${UsbSerialPort.currentDevice?.productName}',
                style: TextStyle(fontSize: 15),
              ),
              Obx(() {
                final debug = controller.indebugMode;
                return Container(
                  height: h * .20,
                  padding: EdgeInsets.symmetric(
                      horizontal: w * .03, vertical: h * .009),
                  alignment: Alignment.center,
                  child: GridView.count(
                    scrollDirection: Axis.vertical,
                    primary: false,
                    padding: EdgeInsets.all(6),
                    crossAxisSpacing: 5,
                    //mainAxisSpacing: 6,
                    crossAxisCount: 3,
                    children: [
                      ButtonSelection(
                        iconData: Icons.router_outlined,
                        textSize: _textSize,
                        iconSize: _iconSize,
                        menuText: 'ABP Mode',
                        fncMenu: () async {
                          if (!controller.portOpened || controller.abpModeActive) return;
                          if (await Tools.askQuestion(
                              'Attention', 'YES', 'NO', "Activate ABP mode?")) {
                            if ((await controller.sendCommand(
                                Constants.CMD_ABP_MODE, 'ok')) &&
                                (await controller.sendCommand(
                                    Constants.CMD_GSS, Constants.RESP_GSS))) {
                              if (await controller.sendCommand(
                                  Constants.CMD_SAVE, 'ok')) {
                                if (await controller.sendCommand(
                                    Constants.CMD_RESET, 'ok')) {

                                      await controller.rebootSystem();
                                } else {
                                  Tools.snackBar('Updated FAIL in CMD_RESET');
                                }
                              } else {
                                Tools.snackBar('Updated FAIL in CMD_SAVE');
                              }
                            } else {
                              Tools.snackBar('Updated FAIL in Config');
                            }
                          }
                        },
                        selected: !controller.abpModeActive,
                        colorInactive: Colors.grey,
                      ),
                      ButtonSelection(
                        iconData: Icons.lock_reset_outlined,
                        textSize: _textSize,
                        iconSize: _iconSize,
                        menuText: 'Reset',
                        fncMenu: () async {
                          if (!controller.portOpened) return;
                          if ((await controller.sendCommand(
                              Constants.CMD_RESET, 'ok'))) {
                            await UsbSerialPort.dispose();
                            await controller.rebootSystem();

                          } else {
                            Tools.snackBar('Reset FAIL');
                          }
                        },
                        selected: true,
                        colorInactive: Colors.grey,
                      ),
                      ButtonSelection(
                        iconData: Icons.bug_report_outlined,
                        textSize: _textSize,
                        iconSize: _iconSize,
                        menuText: 'Debug',
                        fncMenu: () {
                          controller.indebugMode = !debug;
                        },
                        selected: debug,
                        colorInactive: Colors.grey,
                      ),
                    ],
                  ),
                );
              }),
              Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 5),
                  child: TextField(
                      controller: filterController,
                      onSubmitted: (str) {
                        controller.filterStr = str.trim();
                        controller.clearDebug();
                      },
                      decoration: InputDecoration(
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(
                                6.0))),
                        hintText: 'Enter a search filter...',
                      ))),
              Container(
                width: w * .98,
                height: h * .53,
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(),
                ),
                child: Obx(() {
                  final lines = controller.debugFilter
                      .map((e) =>
                      Text(
                        e,
                        style: TextStyle(fontSize: 9),
                      ))
                      .toList();
                  return SingleChildScrollView(
                      reverse: true,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...lines,
                          ]));
                }),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                IconButton(
                  iconSize: w * .14,
                  onPressed: () async {
                    if (!controller.portOpened || controller.existsInExported) return;
                    final info = await controller.getNetworkDeviceInfo();
                    String result = '';
                    if (info.isNotEmpty) {
                      result = (await LocalFileProvider.saveFile(
                          controller.nameFileExported, [info]));
                    }
                    if (result.isEmpty) {
                      Tools.snackBar('Updated OK');
                    } else {
                      Tools.snackBar('Updated FAIL.. $result');
                    }
                  },
                  icon: Icon(Icons.cloud_sync_outlined),
                ),
                IconButton(
                    iconSize: w * .14,
                    onPressed: () async {
                      if (!controller.portOpened) return;
                      if (controller.debug.isNotEmpty) {
                        if (!controller.indebugMode) {
                          final name =
                              'log${DateTime
                              .now()
                              .millisecondsSinceEpoch
                              .toString()}.txt';
                          final result = (await LocalFileProvider.saveFile(
                              name, controller.debug));
                          if (result.isEmpty) {
                            print('ok');
                            Tools.snackBar('Saved $name OK...');
                          } else {
                            print('ko');
                            Tools.snackBar('Saved $name FAIL <$result>');
                          }
                        } else
                          Tools.snackBar('Please Stop de Debug Mode');
                      }
                    },
                    icon: Icon(Icons.save)),
              ]),
            ],
          ),
        );
      }),
/*              */
    );
  }
}
