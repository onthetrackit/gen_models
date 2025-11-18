import 'package:gen_models/annotations.dart';
import 'package:json_annotation/json_annotation.dart';


//
// @GenModels()
// // class AgeResponse extends BaseResponse {
// class AgeResponse1  {
//   List<Age>? data;
//   AgeResponse1({this.data});
//
//   // factory AgeResponse1.fromJson(Map<String, dynamic> json) => _$AgeResponseFromJson(json);
//   //
//   // Map<String, dynamic> toJson() => _$AgeResponseToJson(this);
// }
@GenModels()

class Age {
  Parent<Child?>? model;
  double? ageFrom;

  double? ageTo;

  String? displayName;

  bool? isSelect;

  // Age({this.ageFrom, this.ageTo, this.displayName, this.isSelect = false,this.model});


  // factory Age.fromJson(Map<String, dynamic> json) => _$AgeFromJson(json);
  //
  // Map<String, dynamic> toJson() => _$AgeToJson(this);
  Parent<Child?>? getModel(){
    return null;
  }
  // Map<String,dynamic>? getMap(){
  //   return null;
  // }

  // int? getInt(){
  //   return null;
  // }
  // String? getString(){
  //   return null;
  // }
  // bool? getBool(){
  //   return null;
  // }
  // double? getdouble(){
  //   return null;
  // }

  // List<Map<String,dynamic>>? getMapList(){
  //   return null;
  // }
  // int? getAge(){
  //   return null;
  // }
}
class Parent<T>{
  T? child;
  Parent({this.child});
}
class Child{
  String? name;
  Child({this.name});
}