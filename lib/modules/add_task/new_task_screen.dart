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
import '../../shared/constants.dart';

class NewTaskScreen extends StatefulWidget {
  NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  var title = TextEditingController();

  var description = TextEditingController();

  var date = TextEditingController();

  var priority = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? selectedDate;

  String priorityState = 'medium';

  double h = 15;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, States state) {
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
          // AppCubit.get(context).addNewTask(
          //   title: title.text,
          //   date: date.text,
          //   priority: priorityState,
          //   desc: description.text,
          // );
        }
        if (state is RefreshErrorState) {
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
              'New Task',
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
                    AppCubit.get(context).pickedImage == null
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
                                    image: DecorationImage(
                                      image: FileImage(
                                          AppCubit.get(context).pickedImage!),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
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
                            fallback: (BuildContext context) => Center(child: Column(
                              children: [
                                CircularProgressIndicator(color: DefaultColor.purple,),
                                Text('Uploading Image'),
                              ],
                            ),),
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
                        condition: state is! TaskLoadingState,
                        builder: (BuildContext context) => ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              AppCubit.get(context).addNewTask(
                                title: title.text,
                                date: date.text,
                                priority: priorityState,
                                desc: description.text,
                              );
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
                              "Add Task",
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
