class RankingUserModel {
  final String id;
  final String fullName;
  final int coinBalance;
  final ProfilePic profilePic;

  RankingUserModel({
    required this.id,
    required this.fullName,
    required this.coinBalance,
    required this.profilePic,
  });

  factory RankingUserModel.fromJson(Map<String, dynamic> json) =>
      RankingUserModel(
        id: json["id"] as String? ?? "",
        fullName: json["fullName"] as String? ?? "",
        coinBalance: json["coinBalance"] as int? ?? 0,
        profilePic: ProfilePic.fromJson(
          json["profilePic"] as Map<String, dynamic>? ?? {},
        ),
      );
}

class ProfilePic {
  final String uuid;
  final String contentType;
  final String path;
  final String name;

  ProfilePic({
    required this.uuid,
    required this.contentType,
    required this.path,
    required this.name,
  });

  factory ProfilePic.fromJson(Map<String, dynamic> json) => ProfilePic(
    uuid: json["uuid"] as String? ?? "",
    contentType: json["contentType"] as String? ?? "",
    path: json["path"] as String? ?? "",
    name: json["name"] as String? ?? "",
  );
}
