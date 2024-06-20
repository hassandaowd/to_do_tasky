import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:to_do_app/cubit/cubit.dart';
import 'package:to_do_app/modules/home/home_screen.dart';
import 'package:to_do_app/shared/component.dart';

import '../../cubit/states.dart';
import '../../models/list_model.dart';
import '../../shared/constants.dart';

class EditTaskScreen extends StatefulWidget {
  EditTaskScreen({super.key, required this.model});

  final ListModel? model;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  var title = TextEditingController();

  var description = TextEditingController();

  var date = TextEditingController();

  //var priority = TextEditingController();
  var status = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;
  String priorityState = 'medium';
  String statusState = 'waiting';

  double h = 15;

  @override
  void initState() {
    // TODO: implement initState
    title.text = widget.model!.title!;
    description.text = widget.model!.desc!;
    statusState = widget.model!.status!;
    priorityState = widget.model!.priority!;
    date.text = DateFormat('yyyy-MM-dd').format(widget.model!.createdAt!);
    AppCubit.get(context).setPath(widget.model!.image!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, States state) {
        if (state is EditSuccessState) {
          AppCubit.get(context).getRefreshToken();
          navigateToFinish(context, HomeScreen());
          AppCubit.get(context).removeImage();
        }

        if (state is EditErrorState) {
          toast(msg: 'Error when updating this task', state: ToastState.error);
          AppCubit.get(context).getRefreshToken();
          navigateToFinish(context, HomeScreen());
        }
        if (state is RefreshSuccessState) {
          // AppCubit.get(context).updateTask(
          //   title: title.text,
          //   date: date.text,
          //   priority: priorityState,
          //   desc: description.text,
          //   status: statusState,
          //   path: AppCubit.get(context).path != '' ?  AppCubit.get(context).path : widget.model!.image!,
          // );
        }
        if (state is RefreshErrorState) {
          toast(msg: 'Expired token', state: ToastState.error);
          logout(context);
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
                AppCubit.get(context).removeImage();
                Navigator.pop(context);
              },
              icon: SvgPicture.asset('assets/images/blackArrow.svg'),
            ),
            title: Text(
              'Edit Task',
              style: TextStyle(
                color: DefaultColor.title,
                fontWeight: FontWeight.w700,
                fontFamily: "DMSans",
              ),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    AppCubit.get(context).pickedImage == null && AppCubit.get(context).path == ''
                        ? Container(
                            height: 50,
                            decoration: BoxDecoration(
                                border: DashedBorder.fromBorderSide(
                                    dashLength: 2,
                                    side: BorderSide(
                                        color: DefaultColor.purple, width: 1)),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Center(
                                child: InkWell(
                              onTap: () {
                                AppCubit.get(context).getImage();
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('assets/images/gallary.svg'),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    'Add Img',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'DMSans',
                                      color: DefaultColor.purple,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          )
                        : ConditionalBuilder(
                            condition: state is! ImageLoadingState,
                            builder: (BuildContext context) => Stack(
                              alignment: AlignmentDirectional.topEnd,
                              children: [
                                Container(
                                  height: 140,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      topRight: Radius.circular(4),
                                    ),
                                  ),
                                  child: AppCubit.get(context).pickedImage != null ? Image.file(
                                      AppCubit.get(context).pickedImage!) : image(path: EndPoints.imageUrl+AppCubit.get(context).path),
                                ),
                                IconButton(
                                  onPressed: () {
                                    AppCubit.get(context).removeImage();
                                  },
                                  icon: const CircleAvatar(
                                    radius: 20,
                                    child: Icon(
                                      Icons.close,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            fallback: (BuildContext context) => Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(
                                    color: DefaultColor.purple,
                                  ),
                                  Text('Uploading Image'),
                                ],
                              ),
                            ),
                          ),
                    SizedBox(height: h),
                    Text(
                      'Task Title',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: DefaultColor.subTitle,
                      ),
                    ),
                    SizedBox(height: h),
                    defaultFormField(
                        controller: title,
                        validate: (value) {
                          if (value.isEmpty) {
                            return 'This field can not be empty';
                          }
                          return null;
                        },
                        label: 'Title'),
                    SizedBox(height: h),
                    Text(
                      'Task Description',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: DefaultColor.subTitle,
                      ),
                    ),
                    SizedBox(height: h),
                    defaultFormField(
                        controller: description,
                        validate: (value) {
                          if (value.isEmpty) {
                            return 'This field can not be empty';
                          }
                          return null;
                        },
                        label: 'Description',
                        height: 140,
                        maxLines: 8),
                    SizedBox(height: h),
                    DefaultContainer(
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            SvgPicture.asset('assets/images/purpleFlag.svg'),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              '$priorityState Priority',
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
                          child:
                              SvgPicture.asset('assets/images/arrowDown.svg'),
                        ),
                        onSelected: (String result) {
                          setState(() {
                            priorityState = result;
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
                      ),
                    ),
                    SizedBox(height: h),
                    DefaultContainer(
                      leading: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            // SvgPicture.asset('assets/images/purpleFlag.svg'),
                            // SizedBox(
                            //   width: 10,
                            // ),
                            Text(
                              '$statusState state',
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
                          child:
                              SvgPicture.asset('assets/images/arrowDown.svg'),
                        ),
                        onSelected: (String result) {
                          setState(() {
                            statusState = result;
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
                      ),
                    ),
                    SizedBox(height: h),
                    Text(
                      'Due Date',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: DefaultColor.subTitle,
                      ),
                    ),
                    SizedBox(height: h),
                    defaultFormField(
                      enable: true,
                      controller: date,
                      validate: (value) {
                        if (value.isEmpty) {
                          return 'This field can not be empty';
                        }
                        return null;
                      },
                      label: 'Date',
                      suffix: Icons.calendar_month_rounded,
                      suffixPressed: () => _selectDate(context),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ConditionalBuilder(
                        condition: state is! EditLoadingState,
                        builder: (BuildContext context) => ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              AppCubit.get(context).fastRefresh().then((value){
                                AppCubit.get(context).updateTask(
                                  id: widget.model!.id!,
                                  title: title.text,
                                  date: date.text,
                                  priority: priorityState,
                                  desc: description.text,
                                  status: statusState,
                                  path: AppCubit.get(context).path != '' ?  AppCubit.get(context).path : widget.model!.image!,
                                );
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: DefaultColor.purple,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              "Edit Task",
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontFamily: 'DMSans',
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        fallback: (BuildContext context) => Center(
                          child: CircularProgressIndicator(
                            color: DefaultColor.purple,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    )
                  ],
                ),
              ),
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
      date.text = DateFormat('yyyy-MM-dd').format(selectedDate!);
    }
  }
}
