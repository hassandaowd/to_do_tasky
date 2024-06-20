import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:to_do_app/models/user_model.dart';
import 'package:to_do_app/shared/network/cache_helper.dart';
import '../models/list_model.dart';
import '../modules/sign_in/sign_in_cubit.dart';
import '../shared/constants.dart';
import '../shared/network/dio_helper.dart';
import 'states.dart';

class AppCubit extends Cubit<States> {
  AppCubit() : super(InitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  UserModel? userModel;

  void getUserData() async {
    emit(LoadingState());
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      print('No internet connection.');
      emit(NoInternetState('No internet connection.'));
      return;
    }
    userModel = UserModel(
      displayName: "",
      username: '',
      address: '',
      level: '',
    );
    DioHelper.getData(
      token: accessToken,
      data: {},
      endPoint: EndPoints.profile,
    ).then((response) {
      final status = response['status'];
      // print(status);
      if (status == 'success') {
        userModel = UserModel.fromJson(response['data']);
        // if (kDebugMode) {
        //   print(response['data']);
        //   // print(userModel!.id!+'##################################');
        //   // print(userModel!.toJson().toString());
        // }
        emit(SuccessState());
      } else {
        final errorMessage = response['message'];
        //loginErrorModel = LoginErrorModel.fromJson(response['message']);
        // if (kDebugMode) {
        //   print('user data error #######################');
        //   print(errorMessage);
        //   //print(loginErrorModel.message);
        // }
        emit(ErrorState(errorMessage));
      }
    }).catchError((error) {
      // if (kDebugMode) {
      //   print('user data error error #######################');
      //   //print(ErrorModel.message);
      // }

      emit(ErrorState(''));
    });
  }

  Future<void> fastRefresh ()async{
    emit(RefreshLoadingState());
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      print('No internet connection.');
      emit(NoInternetState('No internet connection.'));
      return;
    }
    DioHelper.getData(
      data: {'token': refreshToken},
      endPoint: EndPoints.refreshToken,
    ).then((response) {
      final status = response['status'];
      //print(status);
      if (status == 'success') {
        accessToken = response['data']['access_token'];
        CacheHelper.saveData(key: 'accessToken', value: accessToken)
            .then((value) {});

        emit(
            RefreshSuccessState(response['data']['access_token'].toString()));

      } else {
        final errorMessage = response['message'];
        //loginErrorModel = LoginErrorModel.fromJson(response['message']);
        if (kDebugMode) {
          print('refresh error #######################');
          print(errorMessage);
          //print(loginErrorModel.message);
        }
        emit(RefreshErrorState(errorMessage));
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('refresh error error #######################');
        //print(ErrorModel.message);
      }

      emit(ErrorState(''));
    });
  }

  void getRefreshToken({bool get = true}) async {
    emptyItem();
    if (refreshToken != '') {
      emit(RefreshLoadingState());
      bool isConnected = await checkInternetConnection();
      if (!isConnected) {
        print('No internet connection.');
        emit(NoInternetState('No internet connection.'));
        return;
      }
      DioHelper.getData(
        data: {'token': refreshToken},
        endPoint: EndPoints.refreshToken,
      ).then((response) {
        final status = response['status'];
        //print(status);
        if (status == 'success') {
          accessToken = response['data']['access_token'];
          CacheHelper.saveData(key: 'accessToken', value: accessToken)
              .then((value) {
            //accessToken = state.loginModel.accessToken!;
          });
          // if (kDebugMode) {
          //   print(response['data']);
          //   print(response['data']['access_token']);
          // }
          emit(
              RefreshSuccessState(response['data']['access_token'].toString()));
          if (get) {
            getUserData();
            getList();
          }
        } else {
          final errorMessage = response['message'];
          //loginErrorModel = LoginErrorModel.fromJson(response['message']);
          if (kDebugMode) {
            print('refresh error #######################');
            print(errorMessage);
            //print(loginErrorModel.message);
          }
          emit(RefreshErrorState(errorMessage));
        }
      }).catchError((error) {
        if (kDebugMode) {
          print('refresh error error #######################');
          //print(ErrorModel.message);
        }

        emit(ErrorState(''));
      });
    }
  }

  List<ListModel>? listModel = [];
  List<ListModel>? inProgressTasks = [];
  List<ListModel>? waitingTasks = [];
  List<ListModel>? finishedTasks = [];

  void getList() async {
    emit(ListLoadingState());
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      print('No internet connection.');
      emit(NoInternetState('No internet connection.'));
      return;
    }
    DioHelper.getData(
      token: accessToken,
      data: {'page': 1},
      endPoint: EndPoints.list,
    ).then((response) {
      listModel = [];
      inProgressTasks = [];
      waitingTasks = [];
      finishedTasks = [];

      final status = response['status'];
      //print(status);
      if (status == 'success') {
        listModel = List<ListModel>.from(
            response['data'].map((x) => ListModel.fromJson(x)));
        for (ListModel element in listModel!) {
          if (element.status == 'Waiting' || element.status == 'waiting') {
            waitingTasks!.add(element);
          } else if (element.status == 'InProgress' ||
              element.status == 'inProgress') {
            inProgressTasks!.add(element);
          } else if (element.status == 'Finished' ||
              element.status == 'finished') {
            finishedTasks!.add(element);
          }
        }
        // if (kDebugMode) {
        //   print(response['data']);
        //   print(listModel![0].image);
        // }
        emit(ListSuccessState());
      } else {
        final errorMessage = response['message'];
        //loginErrorModel = LoginErrorModel.fromJson(response['message']);
        // if (kDebugMode) {
        //   print('List error #######################');
        //   print(errorMessage);
        //   //print(loginErrorModel.message);
        // }
        emit(ListErrorState(errorMessage));
      }
    }).catchError((error) {
      // if (kDebugMode) {
      //   print('List error error #######################');
      //   //print(ErrorModel.message);
      // }

      emit(ErrorState(''));
    });
  }

  ListModel? oneModel ;

  void getOne({String? id}) async {
    emit(OneLoadingState());
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      print('No internet connection.');
      emit(NoInternetState('No internet connection.'));
      return;
    }
    DioHelper.getData(
      token: accessToken,
      data: {},
      endPoint: '${EndPoints.list}/$id',
    ).then((response) {


      final status = response['status'];
      print(status);
      if (status == 'success') {
        oneModel = ListModel.fromJson(response['data']);
        if (kDebugMode) {
          print(response['data']);
        }
        emit(OneSuccessState());
      } else {
        final errorMessage = response['message'];
        //loginErrorModel = LoginErrorModel.fromJson(response['message']);
        if (kDebugMode) {
          print('List error #######################');
          print(errorMessage);
          //print(loginErrorModel.message);
        }
        emit(OneErrorState(errorMessage));
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('List error error #######################');
        //print(ErrorModel.message);
      }

      emit(ErrorState(''));
    });
  }

  void deleteTask({String? id}) async {
    emit(DeleteLoadingState());
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      print('No internet connection.');
      emit(NoInternetState('No internet connection.'));
      return;
    }
    DioHelper.deleteData(
      token: accessToken,
      formData: {},
      endPoint: '${EndPoints.list}/$id',
    ).then((response) {

      final status = response['status'];
      print(status);
      if (status == 'success') {
        if (kDebugMode) {
          print(response['data']);
        }
        emit(DeleteSuccessState());
      } else {
        final errorMessage = response['message'];
        //loginErrorModel = LoginErrorModel.fromJson(response['message']);
        if (kDebugMode) {
          print('List error #######################');
          print(errorMessage);
          //print(loginErrorModel.message);
        }
        emit(DeleteErrorState(errorMessage));
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('List error error #######################');
        //print(ErrorModel.message);
      }

      emit(ErrorState(''));
    });
  }

  void updateTask({
    String? id,
    String? title,
    String? path,
    String? desc,
    String? priority,
    String? date,
    String? status,
  }) async {
    emit(EditLoadingState());

    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      // print('No internet connection.');
      emit(NoInternetState('No internet connection.'));
      return;
    }

    DioHelper.putData(
      token: accessToken,
      formData: {
        "image": path ,
        "title": title,
        "desc": desc,
        "priority": priority, //low , medium , high
        "status": status,
        "dueDate": date
      },
      endPoint: '${EndPoints.list}/$id',
    ).then((response) {
      final status = response['status'];
      print(path);
      if (status == 'success') {
        if (kDebugMode) {
          print(response['data']);
        }
        emit(EditSuccessState());
        //getList();
      } else {
        final errorMessage = response['message'];
        if (kDebugMode) {
          print('image error #######################');
          print(errorMessage);
        }
        if (errorMessage['message'] == 'Unauthorized') {
          getRefreshToken();
          return;
        }
        emit(EditErrorState(''));
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('image error error #######################');
      }

      emit(EditErrorState(''));
    });
  }

  void logOut() async {
    emit(LogoutLoadingState());
    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      print('No internet connection.');
      emit(NoInternetState('No internet connection.'));
      return;
    }

    DioHelper.postData(
      token: accessToken,
      formData: {
        "token": accessToken,
      },
      endPoint: EndPoints.logout,
    ).then((response) {
      final status = response['status'];
      print(status);
      if (status == 'success') {
        if (kDebugMode) {
          print(response['data']);
        }
        emit(LogoutSuccessState());
      } else {
        final errorMessage = response['message'];

        emit(LogoutErrorState(errorMessage));
      }
    }).catchError((error) {
      emit(LogoutErrorState(''));
    });
  }

  var picker = ImagePicker();

  File? pickedImage;

  Future<void> getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      pickedImage = File(pickedFile.path);
      path = pickedImage!.path;
      emit(ImageSuccessState());
      uploadImage();
    } else {
      emit(ImageErrorState());
    }
  }

  void setPath(String pathUrl){
    path = pathUrl;
    print(path);
  }

  void addNewTask({
    String? title,
    String? desc,
    String? priority,
    String? date,
  }) async {
    emit(TaskLoadingState());

    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      print('No internet connection.');
      emit(NoInternetState('No internet connection.'));
      return;
    }
    DioHelper.postData(
      token: accessToken,
      formData: {
        "image": path != '' ? path : '1718723434858-30310-default.png',
        "title": title,
        "desc": desc,
        "priority": priority, //low , medium , high
        "dueDate": date
      },
      endPoint: EndPoints.list,
    ).then((response) {
      final status = response['status'];
      print(status);
      if (status == 'success') {
        if (kDebugMode) {
          print(response['data']);
        }
        emit(TaskSuccessState());
        getList();
      } else {
        final errorMessage = response['message'];
        if (kDebugMode) {
          print('image error #######################');
          print(errorMessage);
        }
        if (errorMessage['message'] == 'Unauthorized') {
          getRefreshToken();
          return;
        }
        emit(TaskErrorState());
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('image error error #######################');
      }

      emit(TaskErrorState());
    });
  }

  String path ='' ;

  void uploadImage() async {
    emit(ImageLoadingState());

    bool isConnected = await checkInternetConnection();
    if (!isConnected) {
      print('No internet connection.');
      emit(ImageErrorState());
      return;
    }

    DioHelper.postFile(
      token: accessToken,
      imagesPaths: pickedImage!.path,
      endPoint: EndPoints.uploadImage,
    ).then((response) {
      final status = response['status'];
      print(status);
      if (status == 'success') {
        if (kDebugMode) {
          print(response['data']);
        }
        path = response['data']['image'];
        emit(ImageSuccessState());
      } else {
        final errorMessage = response['message'];
        if (kDebugMode) {

          print('image error #######################');
          print(errorMessage);
          removeImage();
        }
        if(errorMessage['message'] == 'Unauthorized'){
          getRefreshToken();
          return;
        }
        emit(ImageErrorState());
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('image error error #######################');
      }

      emit(ImageErrorState());
    });
  }

  void removeImage() {
    pickedImage = null;
    path = '' ;
    emit(RemoveImageState());
  }

  void removeItem({ListModel? model}) {
    listModel!.remove(model!);
    waitingTasks!.remove(model);
    finishedTasks!.remove(model);
    inProgressTasks!.remove(model);
    emit(RemoveItemState());
  }

  void emptyItem() {
    listModel = [];
    waitingTasks = [];
    finishedTasks = [];
    inProgressTasks = [];
    emit(RemoveItemState());
  }

  void addItem(ListModel model) {
    listModel!.add(model);
    if (model.status == 'Waiting' || model.status == 'waiting') {
      waitingTasks!.add(model);
    } else if (model.status == 'Inprogress' || model.status == 'inprogress') {
      inProgressTasks!.add(model);
    } else if (model.status == 'Finished' || model.status == 'finished') {
      finishedTasks!.add(model);
    }
  }
}
