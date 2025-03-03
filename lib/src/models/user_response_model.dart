import 'dart:convert';

UserResponseModel userResponseModelFromJson(String str) => UserResponseModel.fromJson(json.decode(str));

String userResponseModelToJson(UserResponseModel data) => json.encode(data.toJson());

class UserResponseModel {
    DateTime? accountCreatedTime;
    String? userId;

    UserResponseModel({
        this.accountCreatedTime,
        this.userId,
    });

    factory UserResponseModel.fromJson(Map<String, dynamic> json) => UserResponseModel(
        accountCreatedTime: json["accountCreatedTime"] == null ? null : DateTime.parse(json["accountCreatedTime"]),
        userId: json["userId"],
    );

    Map<String, dynamic> toJson() => {
        "accountCreatedTime": accountCreatedTime?.toIso8601String(),
        "userId": userId,
    };
}