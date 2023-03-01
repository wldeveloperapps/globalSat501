import 'dart:ffi';

import 'package:get/get.dart';
import 'package:global_sat_501/app/utils/usb_serial.dart';
import 'package:usb_serial/usb_serial.dart';

import '../../data/provider/local_file_provider.dart';
import '../../utils/constants.dart';
import '../../utils/tools.dart';


//**************************************************************************

class homeController extends GetxController {

  static const int msec = 1000;


  RxBool _indebugMode = true.obs;

  bool get indebugMode => _indebugMode.value;

  set indebugMode(bool value) {
    _indebugMode.value = value;
    if (value) debug.clear();
  }

  RxList<String> _debug = <String>[].obs;

  List<String> get debug => _debug;

  set debug(List<String> value) {
    _debug.value = value;
  }

  RxList<String> _debugFilter = <String>[].obs;

  List<String> get debugFilter => _debugFilter;

  set debugFilter(List<String> value) {
    _debugFilter.value = value;
  }

  RxBool _portOpened=false.obs;

  bool get portOpened => _portOpened.value;

  set portOpened(bool value) {
    _portOpened.value = value;
  }

  RxString _info="".obs;

  String get info => _info.value;

  set info(String value) {
    _info.value = value;
  }

  RxBool _abpModeActive=false.obs;

  bool get abpModeActive => _abpModeActive.value;

  set abpModeActive(bool value) {
    _abpModeActive.value = value;
  }

  late String filterStr;
  late String nameFileExported;
  bool existsInExported=false;

  //**************************************************************************
  void clearDebug() {
    debug.clear();
    debugFilter.clear();
  }


//**************************************************************************
  Future newUsbDevice() async {
     await Future.doWhile(() async {
/*       await Future.delayed(const Duration(milliseconds: 1500));
       portOpened=true;
       return false;*/
      final dev = await UsbSerialPort.getDevices();
      try {
        if (dev.isNotEmpty) {
          for (final d in dev) {

            if(d==null)continue;
            info=d.deviceName;
            final opened = await UsbSerialPort.getUsbPort(d, (data) {
              if (!indebugMode) return;
              debug.add(data);
              if (filterStr.isNotEmpty) {
                final f = filterStr.split(',');
                for (final ll in f) {
                  if (ll.isNotEmpty)
                    if (data.toUpperCase().contains(ll.toUpperCase())) {
                      debugFilter.add(data);
                      break;
                    }
                }
              } else
                debugFilter.add(data);
            });
            if (opened) {
              clearDebug();
              portOpened = true;
              await chkABPMode();
              return false;
            }
          }
        }

      }catch(e){
       info=e.toString();
      }
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    });
  }

//**************************************************************************
  Future<String> getCommand(String cmd, {int w: 1000}) async {
    var cont = w / 100;
    String result = '';
    final index = debug.length;
    await UsbSerialPort.sendCommand(cmd);
    debugFilter.add('-----------------------------BEGIN CMD');
    debugFilter.add(cmd);
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      for (var i = index; i < debug.length; i++) {
        final l=debug.elementAt(i);
        if (!l.contains(' ')) {
          result = l;
          return false;
        }
      }
      cont--;
      if (cont == 0) return false;
      return true;
    });
    debugFilter.add('-----------------------------END CMD->${result}');
  return result;
}
//**************************************************************************
  Future rebootSystem() async{
    await UsbSerialPort.dispose();
    Tools.reboot();
  }

//**************************************************************************
void pDebug(String str){
  if (indebugMode) {
    debugFilter.add(str);
  }
}
//**************************************************************************
  Future<bool> isInABPMode() async{
    if(portOpened) {
      final mode = await getCommand(
          Constants.CMD_GET_MODE);
      return mode.trim()=="0";
    }
    return false;
  }
//**************************************************************************
  Future<String> getNetworkDeviceInfo() async{
    final devAddr = await getCommand(
        Constants.CMD_GET_DEV_ADDR);
    final appEUI = await getCommand(
        Constants.CMD_GET_APP_EUI);
    final devEUI = await getCommand(
        Constants.CMD_GET_DEV_EUI);
    final appKey = await getCommand(
        Constants.CMD_GET_APP_KEY);
    final appSKey = await getCommand(
        Constants.CMD_GET_APP_SKEY);
    final NwkSKey = await getCommand(
        Constants.CMD_GET_NWK_SKEY);
    debugFilter.add(
        '********************************************');
    debugFilter.add(
        'devAddr:$devAddr');
    debugFilter.add(
        'appEUI:$appEUI');
    debugFilter.add(
        'devEUI:$devEUI');
    debugFilter.add(
        'appKey:$appKey');
    debugFilter.add(
        'appSKey:$appSKey');
    debugFilter.add(
        'NwkSKey:$NwkSKey');
   debugFilter.add(
        '********************************************');
   return '$devEUI,$devAddr,$appEUI,$appKey,$appSKey,$NwkSKey';
  }

//**************************************************************************
Future<bool> sendCommand(String cmd, String patternOk, {int w: 1000}) async {
  var cont = w / 100;
  bool result = false;
  final index = debug.length;
  await UsbSerialPort.sendCommand(cmd);
  if (indebugMode) {
    debugFilter.add('-----------------------------BEGIN');
    debugFilter.add(cmd);
  }
  if (patternOk.isNotEmpty) {
    await Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      for (var i = index; i < debug.length; i++) {
        if (debug.elementAt(i).toUpperCase() == patternOk.toUpperCase()) {
          result = true;
          return false;
        }
      }
      cont--;
      if (cont == 0) return false;
      return true;
    });
  } else {
    await Tools.delay(w);
    result = true;
  }
  if(indebugMode) {
    debugFilter.add('-----------------------------END');
  }
  return result;
}


//**************************************************************************
@override
void onClose()  {
  if(portOpened){
    portOpened=false;
    UsbSerialPort.dispose();
  }
}
//**************************************************************************
  Future chkABPMode() async{
      String error='';
      final existsFileExported=await LocalFileProvider.existsFile(nameFileExported);
      abpModeActive=await isInABPMode();
      if(abpModeActive){
        final info = await getNetworkDeviceInfo();
        existsInExported=await LocalFileProvider.existsValue(nameFileExported,info.split(',')[0]);
        if(info.isNotEmpty && !existsInExported) {
          error = await LocalFileProvider.saveFile(
              nameFileExported, [
            existsFileExported
                ? ''
                : 'devEUI,devAddr,appEUI,appKey,appSKey,NwkSKey',
            info
          ]);
          if(error.isEmpty)existsInExported=true;
        }
      }else{
        error=await LocalFileProvider.saveFile(
            nameFileExported, [existsFileExported?'':'devEUI,devAddr,appEUI,appKey,appSKey,NwkSKey']);
      }
      if(error.isEmpty)debugFilter.add("SAVED DATA OK");
      else debugFilter.add("SAVED DATA ERROR:${error}");
  }

//**************************************************************************
@override
void onInit() {
  super.onInit();
  filterStr = '';
  portOpened = false;
  nameFileExported ='exported.txt';
  UsbSerialPort.setEvents((ev) async{
    if(ev==UsbEvent.ACTION_USB_ATTACHED){
      //Tools.reboot();
      debugFilter.add("ATTACHED");
    }else{
      await rebootSystem();
    }
  });
  newUsbDevice();
}


//**************************************************************************

}
