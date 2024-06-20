import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:to_do_app/shared/constants.dart';

void navigateTo(context, widget) =>
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));

void navigateToFinish(context, widget) => Navigator.pushAndRemoveUntil(
    context, MaterialPageRoute(builder: (context) => widget), (route) => false);

class DefaultFormField extends StatelessWidget {
  DefaultFormField({
    super.key,
    this.suffixPressed,
    this.height,
    this.type,
    @required this.controller,
    this.suffix,
    this.validate,
    this.color,
    @required this.label,
  });

  TextEditingController? controller;
  Function? validate;
  TextInputType? type;
  Color? color;
  String? label;
  Function? suffixPressed;
  IconData? suffix;
  double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 50,
      child: TextFormField(
        controller: controller,
        validator: (value) => validate!(value),
        keyboardType: type ?? TextInputType.name,
        decoration: InputDecoration(
          prefixIconColor: color ?? DefaultColor.emptyField,
          labelText: label,
          labelStyle: TextStyle(color: color ?? DefaultColor.emptyField),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color ?? DefaultColor.emptyField),
            borderRadius: BorderRadius.circular(10),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: suffix != null
              ? IconButton(
                  onPressed: () => suffixPressed!(),
                  icon: Icon(
                    suffix,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

Widget defaultFormField({
  required TextEditingController controller,
  required Function validate,
  TextInputType? type,
  Color? color,
  bool isPassword = false,
  Function? onSubmit,
  required String? label,
  String? hintText,
  Function? suffixPressed,
  IconData? suffix,
  int? maxLines = 1,
  bool enable = true,
  double? height,
}) =>
    SizedBox(
      height: height ?? 55,
      child: TextFormField(

        enabled: enable,
        maxLines: maxLines,
        controller: controller,
        obscureText: isPassword,
        onFieldSubmitted: (value) => onSubmit != null ? onSubmit(value) : () {},
        validator: (value) => validate(value),
        keyboardType: type ?? TextInputType.name,
        decoration: InputDecoration(
          prefixIconColor: color ?? DefaultColor.emptyField,
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(color: color ?? DefaultColor.emptyField),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: color ?? DefaultColor.emptyField),
            borderRadius: BorderRadius.circular(10),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          suffixIcon: suffix != null
              ? IconButton(
                  onPressed: () => suffixPressed!(),
                  icon: (suffix != Icons.calendar_month_rounded)
                      ? Icon(
                          suffix,
                        )
                      : SvgPicture.asset('assets/images/calender.svg'),
                )
              : null,
        ),
      ),
    );

class DefaultContainer extends StatelessWidget {
  DefaultContainer({super.key, this.leading, this.tile});

  Widget? leading;
  Widget? tile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFFF0ECFF),
      ),
      width: double.infinity,
      height: 50,
      child: Row(
        children: [
          leading!,
          Spacer(),
          tile!,
        ],
      ),
    );
  }
}

Future<bool?> toast({required String msg, required ToastState state}) =>
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 5,
        backgroundColor: chooseToastColor(state),
        textColor: Colors.white,
        fontSize: 16.0);

enum ToastState { success, error, warning, grey }

Color chooseToastColor(ToastState state) {
  Color color;
  switch (state) {
    case ToastState.success:
      color = Colors.green;
      break;
    case ToastState.error:
      color = Colors.red;
      break;
    case ToastState.warning:
      color = Colors.amber;
      break;
    case ToastState.grey:
      color = Colors.grey;
      break;
  }
  return color;
}

Widget image({String? path, double height = 50, double width = 50}) => Image(
      image: NetworkImage(path!),
      width: height,
      height: width,
      fit: BoxFit.cover,
      errorBuilder:
          (BuildContext context, Object object, StackTrace? stackTrace) {
        return SizedBox(
          height: height,
          width: width,
          child: Center(
              child: Image.asset(
            'assets/images/default.png',
            width: width,
            height: height,
            fit: BoxFit.cover,
            color: Colors.white,
            colorBlendMode: BlendMode.darken,
            //height: 150,
          )),
        );
      },
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return SizedBox(
          height: height,
          width: width,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
