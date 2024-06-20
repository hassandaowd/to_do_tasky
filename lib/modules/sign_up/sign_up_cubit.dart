import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/modules/sign_up/states.dart';
import 'package:to_do_app/shared/constants.dart';

import '../../models/login_model.dart';
import '../../shared/network/dio_helper.dart';
import '../sign_in/sign_in_cubit.dart';



class RegisterCubit extends Cubit<RegisterStates>{
  RegisterCubit(): super(RegisterInitialState());

  late LoginModel registerModel ;
  late LoginErrorModel registerErrorModel ;

  static RegisterCubit get(context) => BlocProvider.of(context);

  void userRegister({
    required String phoneNum,
    required String password,
    required String name,
    required String years,
    required String address,
    required String experience,
  }) async {
    emit(RegisterLoadingState());
    print(phoneNum);

    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      print('No internet connection.');
      emit(RegisterErrorState('No internet connection.'));
      return;
    }

    DioHelper.postData(
      formData: {
        "phone" : phoneNum,
        "password" : password,
        "displayName" : name,
        "experienceYears" : int.parse(years),
        "address" : address,
        "level" : experience //fresh , junior , midLevel , senior
      },
      endPoint: EndPoints.register,
    ).then((response) {
      final status = response['status'];
      print(status);
      if (status == 'success') {
        registerModel = LoginModel.fromJson(response['data']);
        if (kDebugMode) {
          print(response['data']);
          print(registerModel.accessToken);
        }
        emit(RegisterSuccessState(registerModel,'Register Successfully'));
      } else {
        final errorMessage = response['message'];
        registerErrorModel = LoginErrorModel.fromJson(response['message']);
        if (kDebugMode) {

          print('login error #######################');
          print(errorMessage);
          print(registerErrorModel.message);
        }
        emit(RegisterErrorState(errorMessage));
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('login error error #######################');
        print(registerErrorModel.message);
      }

      emit(RegisterErrorState(registerErrorModel.message!));
    });
  }

  IconData suffix = Icons.visibility_outlined;
  bool isPassword = true;

  void changePasswordVisibility(){
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined :Icons.visibility_off_outlined ;
    emit(RegisterChangePasswordVisibilityState());
  }
}