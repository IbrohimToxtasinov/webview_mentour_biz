class ProfileModel {
  final String firstName;
  final String lastName;
  final String fullName;
  final String schoolName;
  final LevelModel level;
  final int coins;
  final int score;
  final int rankingPosition;
  final String rankingLabel;
  final LogoModel profilePhoto;
  final SchoolInfo schoolInfo;
  final int balance;

  ProfileModel({
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.schoolName,
    required this.level,
    required this.coins,
    required this.score,
    required this.rankingPosition,
    required this.rankingLabel,
    required this.profilePhoto,
    required this.schoolInfo,
    required this.balance,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    firstName: json['firstName'] as String? ?? "",
    lastName: json['lastName'] as String? ?? "",
    fullName: json['fullName'] as String? ?? "",
    schoolName: json['schoolName'] as String? ?? "",
    level: LevelModel.fromJson(
      (json["level"] is Map<String, dynamic>)
          ? json["level"] as Map<String, dynamic>
          : {},
    ),
    coins: (json['coins'] as num?)?.toInt() ?? 0,
    score: (json['score'] as num?)?.toInt() ?? 0,
    rankingPosition: (json['rankingPosition'] as num?)?.toInt() ?? 0,
    rankingLabel: json['rankingLabel'] as String? ?? "",
    profilePhoto: LogoModel.fromJson(
      (json["profilePhoto"] is Map<String, dynamic>)
          ? json["profilePhoto"] as Map<String, dynamic>
          : {},
    ),
    schoolInfo: SchoolInfo.fromJson(
      (json["schoolInfo"] is Map<String, dynamic>)
          ? json["schoolInfo"] as Map<String, dynamic>
          : {},
    ),
    balance: (json['balance'] as num?)?.toInt() ?? 0,
  );
}

class LevelModel {
  final String uuid;
  final String name;

  LevelModel({required this.uuid, required this.name});

  factory LevelModel.fromJson(Map<String, dynamic> json) => LevelModel(
    uuid: json["uuid"] as String? ?? "",
    name: json["name"] as String? ?? "",
  );
}

class SchoolInfo {
  final String uuid;
  final LogoModel logo;
  final String name;
  final String address;
  final int studentCount;
  final int classCount;
  final String phoneNumber;
  final int teacherCount;
  final String telegramLink;
  final ResRegion region;

  SchoolInfo({
    required this.uuid,
    required this.logo,
    required this.name,
    required this.address,
    required this.studentCount,
    required this.classCount,
    required this.phoneNumber,
    required this.teacherCount,
    required this.telegramLink,
    required this.region,
  });

  factory SchoolInfo.fromJson(Map<String, dynamic> json) => SchoolInfo(
    uuid: json["uuid"] as String? ?? "",
    logo: LogoModel.fromJson(
      (json["logo"] is Map<String, dynamic>)
          ? json["logo"] as Map<String, dynamic>
          : {},
    ),
    name: json["name"] as String? ?? "",
    address: json["address"] as String? ?? "",
    studentCount: (json["studentCount"] as num?)?.toInt() ?? 0,
    classCount: (json["classCount"] as num?)?.toInt() ?? 0,
    phoneNumber: json["phoneNumber"] as String? ?? "",
    teacherCount: (json["teacherCount"] as num?)?.toInt() ?? 0,
    telegramLink: json["telegramLink"] as String? ?? "",
    region: ResRegion.fromJson(
      (json["resRegion"] is Map<String, dynamic>)
          ? json["resRegion"] as Map<String, dynamic>
          : (json["region"] is Map<String, dynamic>)
              ? json["region"] as Map<String, dynamic>
              : {},
    ),
  );
}

class ResRegion {
  final String name;
  final String country;
  final String phoneCode;
  final String currency;
  final String lang;

  ResRegion({
    required this.name,
    required this.country,
    required this.phoneCode,
    required this.currency,
    required this.lang,
  });

  factory ResRegion.fromJson(Map<String, dynamic> json) {
    return ResRegion(
      name: json["name"] as String? ?? "",
      country: json["country"] as String? ?? "",
      phoneCode: json["phoneCode"] as String? ?? "",
      currency: json["currency"] as String? ?? "",
      lang: json["lang"] as String? ?? "",
    );
  }
}

class LogoModel {
  final String uuid;
  final String contentType;
  final String path;
  final String name;

  LogoModel({
    required this.uuid,
    required this.contentType,
    required this.path,
    required this.name,
  });

  factory LogoModel.fromJson(Map<String, dynamic> json) => LogoModel(
    uuid: json["uuid"] as String? ?? "",
    contentType: json["contentType"] as String? ?? "",
    path: json["path"] as String? ?? "",
    name: json["name"] as String? ?? "",
  );
}
