

import 'dart:io';



class LocalFileProvider{

  /*****************************************************************************/
  static Future<bool> existsFile(String name) async{
    try {
      Directory dir = Directory('/storage/emulated/0/Download');
      final fname = '${dir.path}/$name';
      return File(fname).exists();
    }catch (e){

    }
    return false;
  }
  /*****************************************************************************/
  static Future<String> saveFile(String name,List<String> lines) async{
    try {
      if(lines.length>0) {
        Directory dir = Directory('/storage/emulated/0/Download');
        final fname = '${dir.path}/$name';
        final file = File(fname);
        for (final l in lines) {
          if(l.isNotEmpty)
           await file.writeAsString(
               l + '\r\n', mode: FileMode.append, flush: true);
        }
      }
      return '';
    }catch (e){
        return e.toString();
    }
  }
  /*****************************************************************************/
  static Future<bool> existsValue(String name,String value) async{
    try {
      Directory dir = Directory('/storage/emulated/0/Download');
      final fname = '${dir.path}/$name';
      final file = File(fname);
      if(await file.exists()){
        final lines=await file.readAsLines();
        for(final l in lines){
          if(l.contains(value))return true;
        }
      }
    }catch (e){

    }
    return false;
  }
}