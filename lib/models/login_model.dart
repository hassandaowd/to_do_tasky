// To parse this JSON data, do
//
//     final loginModel = loginModelFromJson(jsonString);

import 'dart:convert';

LoginModel loginModelFromJson(String str) => LoginModel.fromJson(json.decode(str));

String loginModelToJson(LoginModel data) => json.encode(data.toJson());

class LoginModel {
  String? id;
  String? accessToken;
  String? refreshToken;
  String? displayName;

  LoginModel({
    this.id,
    this.accessToken,
    this.refreshToken,
    this.displayName,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) => LoginModel(
    id: json["_id"],
    accessToken: json["access_token"],
    refreshToken: json["refresh_token"],
    displayName: json["displayName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "access_token": accessToken,
    "refresh_token": refreshToken,
    "displayName": displayName,
  };
}




LoginErrorModel loginErrorModelFromJson(String str) => LoginErrorModel.fromJson(json.decode(str));

String loginErrorModelToJson(LoginErrorModel data) => json.encode(data.toJson());

class LoginErrorModel {
  String? message;
  String? error;
  int? statusCode;

  LoginErrorModel({
    this.message,
    this.error,
    this.statusCode,
  });

  factory LoginErrorModel.fromJson(Map<String, dynamic> json) => LoginErrorModel(
    message: json["message"],
    error: json["error"],
    statusCode: json["statusCode"],
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "error": error,
    "statusCode": statusCode,
  };
}
