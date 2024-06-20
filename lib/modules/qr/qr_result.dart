import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:to_do_app/cubit/cubit.dart';
import 'package:to_do_app/models/list_model.dart';
import 'package:to_do_app/modules/home/home_screen.dart';
import 'package:to_do_app/shared/component.dart';

import '../../cubit/states.dart';
import '../../shared/constants.dart';

class QrResultScreen extends StatelessWidget {
  QrResultScreen({super.key, required this.model});

  ListModel? model;

  // bool isEdit = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, state) {
        if (state is TaskSuccessState) {
          navigateToFinish(context, HomeScreen());
          AppCubit.get(context).removeImage();
        }
        if (state is TaskErrorState) {
          toast(msg: 'Error when add this task', state: ToastState.error);
          AppCubit.get(context).getRefreshToken();
          navigateToFinish(context, HomeScreen());
        }
        if (state is RefreshSuccessState) {
          AppCubit.get(context).addNewTask(
            title: model!.title,
            desc: model!.desc,
            date: DateFormat('yyyy-MM-dd').format(model!.createdAt!),
            priority: model!.priority,
          );
        }
        if (state is RefreshErrorState) {
          logout(context);
        }

        if (state is NoInternetState) {
          toast(msg: state.error, state: ToastState.error);
          logout(context);
        }
      },
      builder: (BuildContext context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                navigateToFinish(context, HomeScreen());
              },
              icon: SvgPicture.asset('assets/images/blackArrow.svg'),
            ),
            title: Text(
              'QR Result',
              style: TextStyle(
                color: DefaultColor.title,
                fontWeight: FontWeight.w700,
                fontFamily: "DMSans",
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                color: Colors.white,
                splashRadius: 10,
                shape: const TooltipShape(),
                offset: Offset(20, 40),
                onSelected: (String result) {
                  if (result == 'Add') {
                    AppCubit.get(context).addNewTask(
                      title: model!.title,
                      desc: model!.desc,
                      date: DateFormat('yyyy-MM-dd').format(model!.createdAt!),
                      priority: model!.priority,
                    );
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Add',
                    child: Text(
                      'Add',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF00060D),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 3 / 5,
                  child: image(
                    path: EndPoints.imageUrl + model!.image!,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width * 3 / 5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        model!.title!,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                          color: DefaultColor.title,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        model!.desc!,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w400,
                          fontSize: 14,
                          color: DefaultColor.subTitle,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DefaultContainer(
                        leading: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'End Date',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 9,
                                  color: DefaultColor.subTitle,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                DateFormat('yyyy-MM-dd')
                                    .format(model!.createdAt!),
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: DefaultColor.title,
                                ),
                              ),
                            ],
                          ),
                        ),
                        tile:IconButton(
                          onPressed: () {

                            //_selectDate(context);
                          },
                          icon:
                          SvgPicture.asset('assets/images/calender.svg'),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      DefaultContainer(
                          leading: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              model!.status!,
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: DefaultColor.purple,
                              ),
                            ),
                          ),
                          tile: PopupMenuButton<String>(
                            color: Colors.white,
                            splashRadius: 10,
                            shape: const TooltipShape(),
                            offset: Offset(-10, 30),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: SvgPicture.asset(
                                  'assets/images/arrowDown.svg'),
                            ),
                            onSelected: (String result) {},
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'waiting',
                                child: Container(
                                  width: double.infinity,
                                  child: const Text(
                                    'Waiting',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFFFF7D53),
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'inProgress',
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    'InProgress',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF5F33E1),
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'finished',
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    'Finished',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF0087FF),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      DefaultContainer(
                          leading: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                    'assets/images/purpleFlag.svg'),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${model!.priority!} Priority',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    color: DefaultColor.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          tile: PopupMenuButton<String>(
                            color: Colors.white,
                            splashRadius: 10,
                            shape: const TooltipShape(),
                            offset: Offset(-10, 30),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 15.0),
                              child: SvgPicture.asset(
                                  'assets/images/arrowDown.svg'),
                            ),
                            onSelected: (String result) {},
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              PopupMenuItem<String>(
                                value: 'low',
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    'Low',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF0087FF),
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'medium',
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    'Medium',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFF5F33E1),
                                    ),
                                  ),
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'high',
                                child: Container(
                                  width: double.infinity,
                                  child: Text(
                                    'High',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: Color(0xFFFF7D53),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )),
                      QrImageView(
                        data: model!.id!,
                        version: QrVersions.auto,
                        size: MediaQuery.of(context).size.width,
                      ),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
/*
  {
  image: path.png,
  title: title,
  desc: desc,
  priority: low,
  status: waiting, }
   */
