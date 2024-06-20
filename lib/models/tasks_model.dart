// To parse this JSON data, do
//
//     final shopLoginModel = shopLoginModelFromJson(jsonString);

import 'dart:convert';

TasksModel tasksModelFromJson(String str) => TasksModel.fromJson(json.decode(str));


class TasksModel {
  String? title;
  String? description;
  String? imagePath;

  String? status;
  String? priority;
  String? date;



  TasksModel({
   this.title,
   this.date,
   this.description,
   this.imagePath,
   this.status,
   this.priority,
  });

  factory TasksModel.fromJson(Map<String, dynamic> json) => TasksModel(
    title: json["success"],
    date: json["userID"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "date": date,
    "description": description,
    "imagePath": imagePath,
    "status": status,
    "priority": priority,
  };

}
