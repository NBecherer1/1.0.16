import 'dart:convert';


MessageNotifyModel messageNotifyModelFromJson(String str) => MessageNotifyModel.fromJson(json.decode(str));
String messageNotifyModelToJson(MessageNotifyModel data) => json.encode(data.toJsonModel());

class MessageNotifyModel {
  MessageNotifyModel({
    required this.title,
    required this.body,
    required this.action,
    required this.id,
  });

  String title;
  String body;
  String action;
  String id;

  factory MessageNotifyModel.fromJson(Map<String, dynamic> json) => MessageNotifyModel(
    title: json["title"],
    body: json["body"],
    action: json["action"],
    id: json["id"],
  );

  Map<String, dynamic> toJsonModel() => {
    "title": title,
    "body": body,
    "action": action,
    "id": id,
  };
}
