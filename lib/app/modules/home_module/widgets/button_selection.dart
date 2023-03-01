import 'package:flutter/material.dart';
import '../home_controller.dart';

class ButtonSelection extends StatelessWidget {
  final double textSize;
  final double iconSize;
  final String menuText;
  final VoidCallback fncMenu;
  final IconData iconData;
  final bool selected;
  final Color colorInactive;
  ButtonSelection({Key? key,required this.textSize, required this.iconSize, required this.menuText, required this.fncMenu,required this.iconData, required this.selected, required this.colorInactive}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Color> fondo=[];
    if(selected)fondo=[Colors.green,Colors.green,Colors.black];
    else fondo=[colorInactive,colorInactive,Colors.black];
    return Container(
      padding: EdgeInsets.all(2),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            flex: 3,
            child: IconButton(
              onPressed: ()  {
                fncMenu();
              },
              icon: Icon(iconData),
              color: Colors.white,
              iconSize: iconSize,
            ),
          ),
          Flexible(
              child: Text(
                menuText,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: textSize),
              ))
        ],
      ),
      decoration: BoxDecoration(
          borderRadius:
          BorderRadius.all(Radius.circular(10)),
          gradient: LinearGradient(
              colors: [...fondo
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
    );
  }
}
