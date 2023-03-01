
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'dart:async';
import 'dart:typed_data';


class UsbSerialPort{
  static UsbPort? currentPort;
  static UsbDevice? currentDevice;
  static  bool onLine=false;
  static late Transaction<String>? transaction;


  //********************************************************************************************************************
  static Future<List<UsbDevice>> getDevices() async {
    return  await UsbSerial.listDevices();
  }

//********************************************************************************************************************
  static void setEvents(void event(UsbEvent))  {
    UsbSerial.usbEventStream!.listen((UsbEvent ev) {
      event(ev);
    });

  }
  //********************************************************************************************************************
  static Future<bool> getUsbPort(UsbDevice device,void data(String )) async {
    onLine=false;
    currentDevice=device;
    currentPort = await device.create();
    final opened = await currentPort?.open();
    if (opened!) {
      transaction = Transaction.stringTerminated((currentPort?.inputStream)!, Uint8List.fromList([13,10]));
      await currentPort?.setDTR(true);
      await currentPort?.setRTS(true);
      await currentPort?.setPortParameters(115200, UsbPort.DATABITS_8, UsbPort.STOPBITS_1,UsbPort.PARITY_NONE);
      transaction!.stream.listen( (String str) {
        data(str);
      });
      onLine=true;
    }
    return opened;
  }

  //********************************************************************************************************************
  static Future<bool> sendCommand(String data) async{
    try{
      if(onLine){
        String at = data + "\r\n";
        await currentPort!.write(Uint8List.fromList(at.codeUnits));
        return true;
      }
    }catch(e){
      print(e.toString());
    }
    return false;

  }

  //********************************************************************************************************************
  static Future<void> dispose() async{
    try{
      if(onLine) {

        await currentPort?.close();
        if (transaction != null) transaction!.dispose();
        currentPort=null;
        currentDevice=null;
        onLine=false;
      }


    }catch(e){
      print(e.toString());
    }
  }




}