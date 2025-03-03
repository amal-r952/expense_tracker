import 'dart:convert';

ExpenseResponseModel expenseResponseModelFromJson(String str) => ExpenseResponseModel.fromJson(json.decode(str));

String expenseResponseModelToJson(ExpenseResponseModel data) => json.encode(data.toJson());

class ExpenseResponseModel {
    String? documentId;
    String? category;
    double? amount;
    String? notes;
    DateTime? createdAt;
    String? imageUrl;

    ExpenseResponseModel({
        this.documentId,
        this.category,
        this.amount,
        this.notes,
        this.createdAt,
        this.imageUrl,
    });

    factory ExpenseResponseModel.fromJson(Map<String, dynamic> json) => ExpenseResponseModel(
        documentId: json["documentId"],
        category: json["category"],
        amount: json["amount"]?.toDouble(),
        notes: json["notes"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        imageUrl: json["imageUrl"],
    );

    Map<String, dynamic> toJson() => {
        "documentId": documentId,
        "category": category,
        "amount": amount,
        "notes": notes,
        "createdAt": createdAt?.toIso8601String(),
        "imageUrl": imageUrl,
    };
}