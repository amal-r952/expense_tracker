
import 'dart:convert';

SummaryResponseModel summaryResponseModelFromJson(String str) => SummaryResponseModel.fromJson(json.decode(str));

String summaryResponseModelToJson(SummaryResponseModel data) => json.encode(data.toJson());

class SummaryResponseModel {
    final String category;
    final double budget;
    final double currentStatus;

    SummaryResponseModel({
        required this.category,
        required this.budget,
        required this.currentStatus,
    });

    factory SummaryResponseModel.fromJson(Map<String, dynamic> json) => SummaryResponseModel(
        category: json["category"],
        budget: json["budget"],
        currentStatus: json["currentStatus"],
    );

    Map<String, dynamic> toJson() => {
        "category": category,
        "budget": budget,
        "currentStatus": currentStatus,
    };
}
