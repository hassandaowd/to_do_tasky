import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/modules/sign_in/states.dart';
import 'package:to_do_app/shared/constants.dart';

import '../../models/login_model.dart';
import '../../shared/network/dio_helper.dart';


import 'package:connectivity_plus/connectivity_plus.dart';

Future<bool> checkInternetConnection() async {
  var connectivityResult = await Connectivity().checkConnectivity();
  //print(connectivityResult.toString());
  return connectivityResult.toString() != '[ConnectivityResult.none]';
}

class LoginCubit extends Cubit<LoginStates>{
  LoginCubit(): super(LoginInitialState());

  late LoginModel loginModel ;
  late LoginErrorModel loginErrorModel ;

  static LoginCubit get(context) => BlocProvider.of(context);

  void userLogin({
    required String phoneNum,
    required String password,
  }) async {
    emit(LoginLoadingState());
    print(phoneNum);

    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      print('No internet connection.');
      emit(LoginErrorState('No internet connection.'));
      return;
    }

    DioHelper.postData(
      formData: {
        "phone": phoneNum,
        "password": password,
      },
      endPoint: EndPoints.login,
    ).then((response) {
      final status = response['status'];
      print(status);
      if (status == 'success') {
        loginModel = LoginModel.fromJson(response['data']);
        if (kDebugMode) {
          print(response['data']);
          print(loginModel.accessToken);
        }
        emit(LoginSuccessState(loginModel,'Login Successfully'));
      } else {
        final errorMessage = response['message'];
        loginErrorModel = LoginErrorModel.fromJson(response['message']);
        if (kDebugMode) {

          print('login error #######################');
          print(errorMessage);
          print(loginErrorModel.message);
        }
        emit(LoginErrorState(errorMessage));
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('login error error #######################');
        print(loginErrorModel.message);
      }

      emit(LoginErrorState(loginErrorModel.message!));
    });
  }

  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;

  void changePasswordVisibility(){
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined :Icons.visibility_off_outlined ;
    emit(LoginChangePasswordVisibilityState());
  }
}