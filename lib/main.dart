import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/cubit/cubit.dart';
import 'package:to_do_app/modules/home/home_screen.dart';
import 'package:to_do_app/shared/bloc_observer.dart';
import 'package:to_do_app/shared/constants.dart';
import 'package:to_do_app/shared/network/cache_helper.dart';
import 'package:to_do_app/shared/network/dio_helper.dart';

import 'cubit/states.dart';
import 'modules/start_screen/start_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = MyBlocObserver();
  DioHelper.init();
  await CacheHelper.init();
  Widget? widget;

  //accessToken = CacheHelper.getData(key: 'accessToken') ?? '';
  refreshToken = CacheHelper.getData(key: 'refreshToken') ?? '';
  if(refreshToken != '') {

    widget = HomeScreen();
  }
  else {
    widget = StartScreen();
  }
  runApp( MyApp(startWidget: widget,));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key,required this.startWidget});
  final Widget startWidget ;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AppCubit()..getRefreshToken()),
      ],
      child: BlocConsumer<AppCubit , States>(
        listener: (context , states)  {},
        builder: (context , states)  {

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromRGBO(95, 51, 225, 1)),
              useMaterial3: true,
            ),
            home: startWidget,
          );
        },
      ),
    );
  }
}
