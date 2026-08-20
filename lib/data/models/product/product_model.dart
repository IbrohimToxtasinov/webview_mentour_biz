class ProductModel {
  final String uuid;
  final Attachment attachment;
  final String name;
  final int price;
  final int quantity;

  ProductModel({
    required this.uuid,
    required this.attachment,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    uuid: json["uuid"] as String? ?? "",
    attachment: Attachment.fromJson(
      json["attachment"] as Map<String, dynamic>? ?? {},
    ),
    name: json["name"] as String? ?? "",
    price: json["price"] as int? ?? 0,
    quantity: json["quantity"] as int? ?? 0,
  );
}

class Attachment {
  final String uuid;
  final String contentType;
  final String path;
  final String name;

  Attachment({
    required this.uuid,
    required this.contentType,
    required this.path,
    required this.name,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    uuid: json["uuid"] as String? ?? "",
    contentType: json["contentType"] as String? ?? "",
    path: json["path"] as String? ?? "",
    name: json["name"] as String? ?? "",
  );

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "contentType": contentType,
    "path": path,
    "name": name,
  };
}
