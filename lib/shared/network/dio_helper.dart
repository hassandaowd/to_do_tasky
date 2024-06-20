// import 'package:dio/dio.dart';
//
// class DioHelper {
//   static late Dio dio ;
//   static String url = 'https://todo.iraqsapp.com/';
//
//   static init()async{
//     dio = Dio(
//       BaseOptions(
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         receiveDataWhenStatusError: true,
//       ),
//     );
//   }
//
//   static Future<Response> getData({
//     required Map<String,dynamic>data ,
//     required endPoint,
//   })async {
//     return await dio.get('$url$endPoint' ,queryParameters: data);
//   }
//
//   static Future<Response> postData({
//     required Map<String,dynamic> formData,
//     required endPoint
//   })async{
//     return await dio.post('$url$endPoint',data: formData );
//   }
// }

import 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:mime/mime.dart';  // For getting MIME type
import 'package:path/path.dart';  // For getting file extension
import 'package:http_parser/http_parser.dart';

class DioHelper {
  static late Dio dio;
  static String url = 'https://todo.iraqsapp.com/';

  static init() async {
    dio = Dio(
      BaseOptions(
        headers: {
          'Content-Type': 'application/json',
        },
        receiveDataWhenStatusError: true,
      ),
    );
  }

  static Future<Map<String, dynamic>> getData({
    required Map<String, dynamic> data,
    required String endPoint,
    String? token,
  }) async {
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization':token != null ? 'Bearer $token' : '',
    };
    try {
      final response = await dio.get('$url$endPoint', queryParameters: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return _handleGenericError(e);
    }
  }

  static Future<Map<String, dynamic>> postData({
    required Map<String,dynamic> formData,
    required String endPoint,
    String? token,
  }) async {
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization':token != null ? 'Bearer $token' : '',
    };
    try {
      final response = await dio.post('$url$endPoint', data: formData);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return _handleGenericError(e);
    }
  }

  static Future<Map<String, dynamic>> putData({
    required Map<String,dynamic> formData,
    required String endPoint,
    String? token,
  }) async {
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization':token != null ? 'Bearer $token' : '',
    };
    try {
      final response = await dio.put('$url$endPoint', data: formData);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return _handleGenericError(e);
    }
  }

  static Future<Map<String, dynamic>> deleteData({
    required Map<String,dynamic> formData,
    required String endPoint,
    String? token,
  }) async {
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Authorization':token != null ? 'Bearer $token' : '',
    };
    try {
      final response = await dio.delete('$url$endPoint', queryParameters: formData);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return _handleGenericError(e);
    }
  }

  static Future<Map<String, dynamic>> postFile({
    required imagesPaths,
    required String endPoint,
    String? token,
  }) async {
    String? mimeType = lookupMimeType(imagesPaths);
    FormData formData = FormData();

    // Check if the file is indeed an image
    if (mimeType != null && mimeType.startsWith('image/')) {
      // Create a FormData object
      formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagesPaths , contentType: MediaType.parse(mimeType)),
      });}
    dio.options.headers = {
      'Authorization':token != null ? 'Bearer $token' : '',
      'Content-Type': 'multipart/form-data',
      'Accept': '*/*',

    };
    // FormData formData = FormData();
    // formData.files.add(MapEntry('image', await MultipartFile.fromFile(imagesPaths)));
    try {
      final response = await dio.post('$url$endPoint', data: formData);
      return _handleResponse(response);
    } on DioException catch (e) {
      return _handleDioError(e);
    } catch (e) {
      return _handleGenericError(e);
    }
  }

  static Map<String, dynamic> _handleResponse(Response response) {
    switch (response.statusCode) {
      case 200 || 201:
        return {'status': 'success', 'data': response.data};
      case 401:
        return {'status': 'error', 'message': response.data};
      case 404:
        return {'status': 'error', 'message': response.data};
        case 422:
        return {'status': 'error', 'message': response.data};
      default:
        return {
          'status': 'error',
          'message': 'Unexpected status code: ${response.statusCode}',
          'data': response.data,
        };
    }
  }

  static Map<String, dynamic> _handleDioError(DioException e) {
    if (e.response != null) {
      switch (e.response!.statusCode) {
        case 401:
          return {'status': 'error', 'message': e.response!.data};
        case 404:
          return {'status': 'error', 'message': e.response!.data};
          case 422:
          return {'status': 'error', 'message': e.response!.data};
        default:
          return {
            'status': 'error',
            'message': '${e.response!.statusCode} ${e.response!.data}',
          };
      }
    } else {
      return {'status': 'error', 'message': 'Network error: ${e.message}'};
    }
  }

  static Map<String, dynamic> _handleGenericError( e) {
    return {'status': 'error', 'message': 'An error occurred: $e'};
  }
}





