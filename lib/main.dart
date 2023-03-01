import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:flutter/services.dart';

import 'app/routes/app_pages.dart';
import 'app/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app/utils/tools.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp],
  ); // To turn off landscape mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      enableLog: true,
      debugShowCheckedModeBanner: false,
      title: 'LT-501',
      theme: appThemeData,
      home: Container(),
      getPages: AppPages.pages,
      initialRoute: Routes.HOME,
      onReady: () async{
        Map<Permission, PermissionStatus> statuses = await [
          Permission.manageExternalStorage,
          //Permission.accessMediaLocation,
          Permission.storage,
        ].request();

      },
      onDispose: ()async {

      },
    );
  }
}