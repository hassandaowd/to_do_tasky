import 'dart:io';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:to_do_app/cubit/cubit.dart';
import 'package:to_do_app/cubit/states.dart';
import 'package:to_do_app/models/list_model.dart';
import 'package:to_do_app/modules/home/home_screen.dart';
import 'package:to_do_app/shared/component.dart';

import '../../shared/constants.dart';
import '../edit_task/edit_task_Screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  TaskDetailsScreen({super.key, required this.model});

  ListModel? model;

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool isEdit = false;
  String date = '';
  String status = '';
  String priority = '';
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    date = DateFormat('yyyy-MM-dd').format(widget.model!.createdAt!);
    status = widget.model!.status!;
    priority = widget.model!.priority!;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, States state) {
        if (state is RemoveItemState) {
          //navigateToFinish(context, HomeScreen());
        }
        if (state is EditSuccessState) {
          setState(() {
            isEdit = false;
          });
          toast(
              msg: 'This task has been edited successfully',
              state: ToastState.success);
          AppCubit.get(context).getRefreshToken();
        }
        if (state is DeleteSuccessState) {
          AppCubit.get(context).getRefreshToken();
          navigateToFinish(context, HomeScreen());
          AppCubit.get(context).removeImage();
        }
        if (state is EditErrorState) {
          toast(msg: 'Error when updating this task', state: ToastState.error);
          AppCubit.get(context).getRefreshToken();
          navigateToFinish(context, HomeScreen());
        }
        if (state is RefreshSuccessState) {}
        if (state is RefreshErrorState) {
          toast(msg: 'Expired token', state: ToastState.error);
          logout(context);
        }
        if (state is DeleteErrorState) {
          AppCubit.get(context).fastRefresh();
          AppCubit.get(context).deleteTask(id: widget.model!.id!);
        }

        if (state is NoInternetState) {
          toast(msg: state.error, state: ToastState.error);
          logout(context);
        }
      },
      builder: (BuildContext context, States state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: SvgPicture.asset('assets/images/blackArrow.svg'),
            ),
            title: Text(
              widget.model!.title!,
              style: TextStyle(
                color: DefaultColor.title,
                fontWeight: FontWeight.w700,
                fontFamily: "DMSans",
              ),
            ),
            actions: [
              if (isEdit)
                ConditionalBuilder(
                  condition: state is! EditLoadingState,
                  builder: (BuildContext context) => TextButton(
                      onPressed: () {
                        AppCubit.get(context).fastRefresh().then((value) {
                          AppCubit.get(context).updateTask(
                            id: widget.model!.id,
                            title: widget.model!.title,
                            date: date,
                            priority: priority,
                            desc: widget.model!.desc,
                            status: status,
                            path: widget.model!.image,
                          );
                        });
                      },
                      child: Text('Done', style: TextStyle(color: DefaultColor.purple),)),
                  fallback: (BuildContext context) => SizedBox(width: 40,child: Center(child: Container(width: 16, height: 16,child: CircularProgressIndicator(color: DefaultColor.purple,),))),
                ),
              PopupMenuButton<String>(
                color: Colors.white,
                splashRadius: 10,
                shape: const TooltipShape(),
                offset: Offset(20, 40),
                onSelected: (String result) {
                  if (result == 'Delete') {
                    AppCubit.get(context).fastRefresh().then((value) {
                      AppCubit.get(context).deleteTask(id: widget.model!.id);
                      AppCubit.get(context).removeItem(model: widget.model);
                    });
                  }
                  if (result == 'Edit') {
                    // setState(() {
                    //   isEdit = true;
                    // });
                    navigateTo(
                        context,
                        EditTaskScreen(
                          model: widget.model,
                        ));
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'Edit',
                    child: Text(
                      'Edit',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFF00060D),
                      ),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'Delete',
                    child: Text(
                      'Delete',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Color(0xFFFF7D53),
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
                    path: EndPoints.imageUrl + widget.model!.image!,
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
                        widget.model!.title!,
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
                        widget.model!.desc!,
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
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
                                  date,
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
                          tile: IconButton(
                            onPressed: () {
                              setState(() {
                                isEdit = true;
                              });
                              _selectDate(context);
                            },
                            icon:
                                SvgPicture.asset('assets/images/calender.svg'),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      DefaultContainer(
                          leading: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Text(
                              status,
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
                            onSelected: (String result) {
                              setState(() {
                                isEdit = true;
                                status = result;
                              });
                            },
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
                                  '${priority} Priority',
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
                            onSelected: (String result) {
                              setState(() {
                                isEdit = true;
                                priority = result;
                              });
                            },
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

                      // if (isEdit) SizedBox(height: 20),
                      // if (isEdit)
                      //   SizedBox(
                      //     height: 50,
                      //     child: ConditionalBuilder(
                      //       condition: state is! EditLoadingState,
                      //       builder: (BuildContext context) => ElevatedButton(
                      //         onPressed: () {
                      //           // if (_formKey.currentState!.validate()) {
                      //           AppCubit.get(context).fastRefresh().then((value){
                      //             AppCubit.get(context).updateTask(
                      //               id: widget.model!.id,
                      //               title: widget.model!.title,
                      //               date: date,
                      //               priority: priority,
                      //               desc: widget.model!.desc,
                      //               status: status,
                      //               path: widget.model!.image,
                      //             );
                      //           });
                      //           // }
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //           backgroundColor: DefaultColor.purple,
                      //           padding:
                      //               const EdgeInsets.symmetric(vertical: 15),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10.0),
                      //           ),
                      //         ),
                      //         child: const Center(
                      //           child: Text(
                      //             "Edit Task",
                      //             style: TextStyle(
                      //                 fontSize: 16,
                      //                 color: Colors.white,
                      //                 fontFamily: 'DMSans',
                      //                 fontWeight: FontWeight.bold),
                      //           ),
                      //         ),
                      //       ),
                      //       fallback: (BuildContext context) => Center(
                      //         child: CircularProgressIndicator(
                      //           color: DefaultColor.purple,
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // if (isEdit) SizedBox(height: 20),
                      QrImageView(
                        data: widget.model!.id!,
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      setState(() {
        date = DateFormat('yyyy-MM-dd').format(selectedDate!);
      });
    }
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
