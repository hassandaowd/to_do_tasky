import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:to_do_app/cubit/cubit.dart';
import 'package:to_do_app/modules/sign_in/sign_in_screen.dart';
import 'package:to_do_app/shared/component.dart';
import 'package:to_do_app/shared/network/cache_helper.dart';

String accessToken =  '';
String refreshToken =  '';
String userPhone =  '';

void logout(context){
   CacheHelper.removeAll().then((value){
     navigateToFinish(context, SignInScreen());
   });
   AppCubit.get(context).emptyItem();
   accessToken =  '';
   refreshToken =  '';
   userPhone =  '';
}




abstract class DefaultColor{
  static Color purple =  const Color.fromRGBO(95, 51, 225, 1.0);
  static Color subTitle =  const Color.fromRGBO(36, 37, 44, 0.6); //#24252C99 #24252C99 #24252C99
  static Color title =  const Color.fromRGBO(36, 37, 44, 1); //#24252C99 //#24252C
  static Color white =  const Color.fromARGB(255, 255, 255, 255); //#24252C99
  static Color emptyField =  HexColor('BABABA');
  static Color unSelectedColor =  const Color.fromRGBO(240, 236, 255, 1.0);

  static Color unSelectedFontColor =  const Color.fromRGBO(124, 124, 128, 1.0);//##7C7C80
}

abstract class EndPoints{
  static String login = 'auth/login';
  static String register = 'auth/register';
  static String logout = 'auth/logout';
  static String refreshToken = 'auth/refresh-token';
  static String profile = 'auth/profile';
  static String list = 'todos';
  static String uploadImage = 'upload/image';
  static String imageUrl = 'https://todo.iraqsapp.com/images/';
  // static String uploadImage = 'todos';
}



class TooltipShape extends ShapeBorder {
  const TooltipShape();

  final BorderSide _side = BorderSide.none;
  final BorderRadiusGeometry _borderRadius = BorderRadius.zero;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(_side.width);

  @override
  Path getInnerPath(
      Rect rect, {
        TextDirection? textDirection,
      }) {
    final Path path = Path();

    path.addRRect(
      _borderRadius.resolve(textDirection).toRRect(rect).deflate(_side.width),
    );

    return path;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final Path path = Path();
    final RRect rrect = _borderRadius.resolve(textDirection).toRRect(rect);

    path.moveTo(0, 10);
    path.quadraticBezierTo(0, 0, 10, 0);
    path.lineTo(rrect.width - 30, 0);
    path.lineTo(rrect.width - 20, -10);
    path.lineTo(rrect.width - 10, 0);
    path.quadraticBezierTo(rrect.width, 0, rrect.width, 10);
    path.lineTo(rrect.width, rrect.height - 10);
    path.quadraticBezierTo(
        rrect.width, rrect.height, rrect.width - 10, rrect.height);
    path.lineTo(10, rrect.height);
    path.quadraticBezierTo(0, rrect.height, 0, rrect.height - 10);

    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => RoundedRectangleBorder(
    side: _side.scale(t),
    borderRadius: _borderRadius * t,
  );
}