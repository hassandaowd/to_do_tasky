import 'dart:io';

import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:to_do_app/cubit/cubit.dart';
import 'package:to_do_app/models/list_model.dart';
import 'package:to_do_app/modules/add_task/new_task_screen.dart';
import 'package:to_do_app/modules/profile/profile_screen.dart';
import 'package:to_do_app/modules/task_details/task_details_screen.dart';
import 'package:to_do_app/shared/component.dart';
import 'package:to_do_app/shared/constants.dart';
import '../../cubit/states.dart';
import '../qr/qr_generator.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit, States>(
      listener: (BuildContext context, States state) {
        if (state is LogoutSuccessState) {
          logout(context);
        }
        if (state is LogoutErrorState) {
          logout(context);
        }
        if (state is RefreshSuccessState) {
          //AppCubit.get(context).logOut();
        }
        if (state is RefreshErrorState) {
          AppCubit.get(context).logOut();
        }
        if (state is NoInternetState) {
          toast(msg: state.error, state: ToastState.error);
          logout(context);
        }
      },
      builder: (BuildContext context, States state) {
        Map<String, List<ListModel>> tasks = {
          'All': AppCubit.get(context).listModel!,
          'Waiting': AppCubit.get(context).waitingTasks!,
          'Finished': AppCubit.get(context).finishedTasks!,
          'Inprogress': AppCubit.get(context).inProgressTasks!,
        };
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            surfaceTintColor: Colors.white,
            backgroundColor: Colors.white,
            title: Text(
              'Logo',
              style: TextStyle(
                color: DefaultColor.title,
                fontWeight: FontWeight.w700,
                fontFamily: "DMSans",
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () {

                      navigateTo(context, ProfileScreen());
                      AppCubit.get(context).fastRefresh();

                    },
                    icon: SvgPicture.asset('assets/images/person.svg'),
                  ),
                  IconButton(
                    onPressed: () {
                      AppCubit.get(context).logOut();
                    },
                    icon: state is LogoutLoadingState
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: DefaultColor.purple,
                            ))
                        : SvgPicture.asset('assets/images/logout.svg'),
                  ),
                ],
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Tasks',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: DefaultColor.subTitle,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildTaskFilterButton(label: 'All'),
                      _buildTaskFilterButton(label: 'Inprogress'),
                      _buildTaskFilterButton(label: 'Waiting'),
                      _buildTaskFilterButton(label: 'Finished'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ConditionalBuilder(
                    condition:
                        (state is! ListLoadingState || state is! LoadingState) && (AppCubit.get(context).listModel!.isNotEmpty || state is ListSuccessState  ),
                    builder: (BuildContext context) => LiquidPullToRefresh(
                      animSpeedFactor: 4,
                      color: Colors.white,
                      backgroundColor: DefaultColor.purple,
                      onRefresh: ()async{
                        AppCubit.get(context).getRefreshToken();
                      },
                      child: ListView.separated(
                        itemBuilder: (BuildContext context, int index) =>
                            tasks[selectedFilter]!.isNotEmpty
                                ? _buildTaskCard(
                                    tasks[selectedFilter]![index], context, index)
                                : Center(child: Text('No Tasks to show')),
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(
                          height: 5,
                        ),
                        itemCount: tasks[selectedFilter]!.isNotEmpty
                            ? tasks[selectedFilter]!.length
                            : 1,
                      ),
                    ),
                    fallback: (BuildContext context) => Center(
                        child: CircularProgressIndicator(
                      color: DefaultColor.purple,
                    )),
                  ),
                ),
              ],
            ),
          ),
          floatingActionButton: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 50,
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  heroTag: 'qr',
                  onPressed: () async {
                    // Request camera permission if not already granted
                    var status = await Permission.camera.status;
                    if (!status.isGranted) {
                      await Permission.camera.request();
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReadQRCodePage()),
                    );
                    AppCubit.get(context).fastRefresh();

                  },
                  backgroundColor: Color.fromRGBO(235, 229, 255, 1.0),
                  child: SvgPicture.asset('assets/images/qr.svg'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 65,
                child: FloatingActionButton(
                  shape: const CircleBorder(),
                  heroTag: 'add',
                  onPressed: () {
                    navigateTo(context, NewTaskScreen());
                    AppCubit.get(context).fastRefresh();

                  },
                  backgroundColor: DefaultColor.purple,
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTaskFilterButton({String? label}) {
    bool isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedFilter = label;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSelected ? DefaultColor.purple : DefaultColor.unSelectedColor,
          foregroundColor:
              isSelected ? Colors.white : DefaultColor.unSelectedFontColor,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: Text(label!),
      ),
    );
  }

  // Widget _buildTaskFilterButton({String? label, bool? isSelected}) {

  Widget _buildTaskCard(ListModel model, context, index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: InkWell(
              splashColor: Colors.grey[100],
              onTap: () {
                navigateTo(
                    context,
                    TaskDetailsScreen(
                      model: model,
                    ));
                AppCubit.get(context).fastRefresh();
              },
              child: Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle),
                          clipBehavior: Clip.hardEdge,
                          width: 64,
                          height: 64,
                          child: Center(
                            child: image(
                              path:EndPoints.imageUrl+model!.image!,
                              width: 64,
                              height: 64,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                model.title!,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: DefaultColor.title),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: _getStatusColor(model.status!),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              child: Text(model.status!,
                                  style: TextStyle(
                                      color: _getFontColor(model.status!))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                model.desc!,
                                overflow: TextOverflow.ellipsis,
                                style:  TextStyle(
                                  fontFamily: 'DMSans',
                                  color: DefaultColor.subTitle,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            // Icon(
                            //   Icons.outlined_flag,
                            //   color: _getPriorityColor(model.priority!),
                            //   size: 20,
                            // ),
                            SvgPicture.asset(
                              _getPriorityFlag(model.priority!),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(model.priority!,
                                style: TextStyle(
                                    color: _getPriorityColor(model.priority!))),
                            const Spacer(),
                            Text(DateFormat('yyyy-MM-dd').format(model.createdAt!),
                                style:  TextStyle(
                                    color: DefaultColor.subTitle)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PopupMenuButton<String>(
                  child: Icon(
                    Icons.more_vert_outlined,
                  ),
                  color: Colors.white,
                  splashRadius: 10,
                  shape: const TooltipShape(),
                  offset: Offset(10, 30),
                  onSelected: (String result) {
                    if (result == 'Delete') {
                      AppCubit.get(context).deleteTask(id : model.id);
                      AppCubit.get(context).removeItem(model: model);
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<String>>[
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
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Waiting' || 'waiting':
        return const Color(0xFFFFE4F2);
      case 'inProgress' || 'InProgress':
        return const Color(0xFFF0ECFF);
      case 'Finished' || 'finished':
        return const Color(0xFFE3F2FF);
      default:
        return Colors.grey;
    }
  }

  Color _getFontColor(String status) {
    switch (status) {
      case 'Waiting' || 'waiting':
        return const Color(0xFFFF7D53);
      case 'inProgress' || 'InProgress':
        return const Color(0xFF5F33E1);
      case 'Finished' || 'finished':
        return const Color(0xFF0087FF);
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high' || 'High':
        return const Color(0xFFFF7D53);
      case 'medium' || 'Medium':
        return const Color(0xFF5F33E1);
      case 'low' || 'Low':
        return const Color(0xFF0087FF);
      default:
        return Colors.grey;
    }
  }

  String _getPriorityFlag(String priority) {
    switch (priority) {
      case 'high' || 'High':
        return 'assets/images/HighFlag.svg';
      case 'medium' || 'Medium':
        return 'assets/images/MediumFlag.svg';
      case 'low' || 'Low':
        return 'assets/images/LowFlag.svg';
      default:
        return 'assets/images/LowFlag.svg';
    }
  }
}

// List<TasksModel> tasksModel = [
//   TasksModel(
//     title: 'Grocery Shopping',
//     date: '1/12/2022',
//     description: 'This application is designed for shopping',
//     status: 'Waiting',
//     imagePath: 'assets/images/grocery.png',
//     priority: 'Medium',
//   ),
//   TasksModel(
//     title: 'Grocery Shopping',
//     date: '30/12/2022',
//     description: 'This application is designed for shopping',
//     status: 'Waiting',
//     imagePath: 'assets/images/grocery.png',
//     priority: 'Low',
//   ),
//   TasksModel(
//     title: 'Grocery Shopping',
//     date: '30/12/2022',
//     description: 'This application is designed for shopping',
//     status: 'Inprogress',
//     imagePath: 'assets/images/grocery.png',
//     priority: 'High',
//   ),
//   TasksModel(
//     title: 'Grocery Shopping',
//     date: '30/12/2022',
//     description: 'This application is designed for shopping',
//     status: 'Finished',
//     imagePath: 'assets/images/grocery.png',
//     priority: 'Medium',
//   ),
//   TasksModel(
//     title: 'Grocery Shopping',
//     date: '30/12/2022',
//     description: 'This application is designed for shopping',
//     status: 'Finished',
//     imagePath: 'assets/images/grocery.png',
//     priority: 'Medium',
//   ),
//   TasksModel(
//     title: 'Grocery Shopping',
//     date: '30/12/2022',
//     description: 'This application is designed for shopping',
//     status: 'Finished',
//     imagePath: 'assets/images/grocery.png',
//     priority: 'Medium',
//   ),
//   TasksModel(
//     title: 'Grocery Shopping',
//     date: '30/12/2022',
//     description: 'This application is designed for shopping',
//     status: 'Finished',
//     imagePath: 'assets/images/grocery.png',
//     priority: 'Medium',
//   ),
// ];
