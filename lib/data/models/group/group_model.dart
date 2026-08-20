import 'package:mentour_web_view/data/models/course/course_model.dart';

class GroupModel {
  final String id;
  final String name;
  final String branchName;
  final String teacherFullName;
  final String teacherId;
  final BranchId branchId;
  final SchoolInfo schoolInfo;
  final Level level;
  final int studentCount;
  final TeacherAttachment teacherAttachment;
  final int healthScore;
  final int attendanceScore;
  final int academicScore;
  final int attendancePercentage;
  final int averageScorePercentage;
  final int totalLessons;
  final int paymentsDueCount;
  final int paymentsDueAmount;

  GroupModel({
    required this.id,
    required this.name,
    required this.branchName,
    required this.teacherFullName,
    required this.teacherId,
    required this.branchId,
    required this.schoolInfo,
    required this.level,
    required this.studentCount,
    required this.teacherAttachment,
    required this.healthScore,
    required this.attendanceScore,
    required this.academicScore,
    required this.attendancePercentage,
    required this.averageScorePercentage,
    required this.totalLessons,
    required this.paymentsDueCount,
    required this.paymentsDueAmount,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) => GroupModel(
    id: json["id"] as String? ?? "",
    name: json["name"] as String? ?? "",
    branchName: json["branchName"] as String? ?? "",
    teacherFullName: json["teacherFullName"] as String? ?? "",
    teacherId: json["teacherId"] as String? ?? "",
    branchId: BranchId.fromJson(
      json["branchId"] as Map<String, dynamic>? ?? {},
    ),
    schoolInfo: SchoolInfo.fromJson(
      json["schoolInfo"] as Map<String, dynamic>? ?? {},
    ),
    level: Level.fromJson(json["level"] as Map<String, dynamic>? ?? {}),
    studentCount: json["studentCount"] as int? ?? 0,
    teacherAttachment: TeacherAttachment.fromJson(
      json["teacherAttachment"] as Map<String, dynamic>? ?? {},
    ),
    healthScore: json["healthScore"] as int? ?? 0,
    attendanceScore: json["attendanceScore"] as int? ?? 0,
    academicScore: json["academicScore"] as int? ?? 0,
    attendancePercentage: json["attendancePercentage"] as int? ?? 0,
    averageScorePercentage: json["averageScorePercentage"] as int? ?? 0,
    totalLessons: json["totalLessons"] as int? ?? 0,
    paymentsDueCount: json["paymentsDueCount"] as int? ?? 0,
    paymentsDueAmount: json["paymentsDueAmount"] as int? ?? 0,
  );
}

class BranchId {
  final String uuid;
  final String name;
  final String address;
  final String schoolName;

  BranchId({
    required this.uuid,
    required this.name,
    required this.address,
    required this.schoolName,
  });

  factory BranchId.fromJson(Map<String, dynamic> json) => BranchId(
    uuid: json["uuid"] as String? ?? "",
    name: json["name"] as String? ?? "",
    address: json["address"] as String? ?? "",
    schoolName: json["schoolName"] as String? ?? "",
  );
}

class SchoolInfo {
  final String uuid;
  final TeacherAttachment logo;
  final String name;
  final String address;
  final int studentCount;
  final int classCount;
  final String phoneNumber;
  final int teacherCount;
  final String telegramLink;
  final String status;
  final int maxStudents;
  final List<SchoolBookList> schoolBookList;
  final RegionDetails regionDetails;
  final bool isPaymentActive;
  final ResSubscriptionPlan? resSubscriptionPlan;
  final Subscription? subscription;
  final DateTime? lastLessonCreatedAt;
  final DateTime? latestDueDate;
  final bool linkedToOrganization;

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
    required this.status,
    required this.maxStudents,
    required this.schoolBookList,
    required this.regionDetails,
    required this.isPaymentActive,
    this.resSubscriptionPlan,
    this.subscription,
    this.lastLessonCreatedAt,
    this.latestDueDate,
    required this.linkedToOrganization,
  });

  factory SchoolInfo.fromJson(Map<String, dynamic> json) => SchoolInfo(
    uuid: json["uuid"] as String? ?? "",
    logo: TeacherAttachment.fromJson(
      json["logo"] as Map<String, dynamic>? ?? {},
    ),
    name: json["name"] as String? ?? "",
    address: json["address"] as String? ?? "",
    studentCount: json["studentCount"] as int? ?? 0,
    classCount: json["classCount"] as int? ?? 0,
    phoneNumber: json["phoneNumber"] as String? ?? "",
    teacherCount: json["teacherCount"] as int? ?? 0,
    telegramLink: json["telegramLink"] as String? ?? "",
    status: json["status"] as String? ?? "",
    maxStudents: json["maxStudents"] as int? ?? 0,
    schoolBookList: List<SchoolBookList>.from(
      (json["schoolBookList"] as List? ?? []).map(
        (x) => SchoolBookList.fromJson(x as Map<String, dynamic>),
      ),
    ),
    regionDetails: RegionDetails.fromJson(
      json["regionDetails"] as Map<String, dynamic>? ?? {},
    ),
    isPaymentActive: json["isPaymentActive"] as bool? ?? false,
    resSubscriptionPlan: json["resSubscriptionPlan"] == null
        ? null
        : ResSubscriptionPlan.fromJson(
            json["resSubscriptionPlan"] as Map<String, dynamic>,
          ),
    subscription: json["subscription"] == null
        ? null
        : Subscription.fromJson(json["subscription"] as Map<String, dynamic>),
    lastLessonCreatedAt: json["lastLessonCreatedAt"] == null
        ? null
        : DateTime.tryParse(json["lastLessonCreatedAt"] as String? ?? ""),
    latestDueDate: json["latestDueDate"] == null
        ? null
        : DateTime.tryParse(json["latestDueDate"] as String? ?? ""),
    linkedToOrganization: json["linkedToOrganization"] as bool? ?? false,
  );
}

class TeacherAttachment {
  final String uuid;
  final String contentType;
  final String path;
  final String name;

  TeacherAttachment({
    required this.uuid,
    required this.contentType,
    required this.path,
    required this.name,
  });

  factory TeacherAttachment.fromJson(Map<String, dynamic> json) =>
      TeacherAttachment(
        uuid: json["uuid"] as String? ?? "",
        contentType: json["contentType"] as String? ?? "",
        path: json["path"] as String? ?? "",
        name: json["name"] as String? ?? "",
      );
}

class RegionDetails {
  final String uuid;
  final String name;
  final String country;
  final String phoneCode;
  final String currency;
  final String lang;

  RegionDetails({
    required this.uuid,
    required this.name,
    required this.country,
    required this.phoneCode,
    required this.currency,
    required this.lang,
  });

  factory RegionDetails.fromJson(Map<String, dynamic> json) => RegionDetails(
    uuid: json["uuid"] as String? ?? "",
    name: json["name"] as String? ?? "",
    country: json["country"] as String? ?? "",
    phoneCode: json["phoneCode"] as String? ?? "",
    currency: json["currency"] as String? ?? "",
    lang: json["lang"] as String? ?? "",
  );
}

class ResSubscriptionPlan {
  final String uuid;
  final String planName;
  final int price;
  final String currency;
  final int maxStudents;

  ResSubscriptionPlan({
    required this.uuid,
    required this.planName,
    required this.price,
    required this.currency,
    required this.maxStudents,
  });

  factory ResSubscriptionPlan.fromJson(Map<String, dynamic> json) =>
      ResSubscriptionPlan(
        uuid: json["uuid"] as String? ?? "",
        planName: json["planName"] as String? ?? "",
        price: json["price"] as int? ?? 0,
        currency: json["currency"] as String? ?? "",
        maxStudents: json["maxStudents"] as int? ?? 0,
      );
}

class SchoolBookList {
  final String bookUuid;
  final String bookName;
  final bool isGlobal;
  final SchoolBookListLevel level;

  SchoolBookList({
    required this.bookUuid,
    required this.bookName,
    required this.isGlobal,
    required this.level,
  });

  factory SchoolBookList.fromJson(Map<String, dynamic> json) => SchoolBookList(
    bookUuid: json["bookUuid"] as String? ?? "",
    bookName: json["bookName"] as String? ?? "",
    isGlobal: json["isGlobal"] as bool? ?? false,
    level: SchoolBookListLevel.fromJson(
      json["level"] as Map<String, dynamic>? ?? {},
    ),
  );
}

class SchoolBookListLevel {
  final String uuid;
  final String name;
  final int subjectId;

  SchoolBookListLevel({
    required this.uuid,
    required this.name,
    required this.subjectId,
  });

  factory SchoolBookListLevel.fromJson(Map<String, dynamic> json) =>
      SchoolBookListLevel(
        uuid: json["uuid"] as String? ?? "",
        name: json["name"] as String? ?? "",
        subjectId: json["subjectId"] as int? ?? 0,
      );
}

class Subscription {
  final String status;
  final ResSubscriptionPlan? resSubscriptionPlan;
  final int daysRemaining;
  final DateTime? expiresAt;
  final bool aiExerciseEnabled;
  final bool aiWritingEnabled;
  final bool aiSpeakingEnabled;
  final int tokenLimit;
  final int tokensUsed;
  final bool autoFreezeEnabled;
  final int overdueDaysToFreeze;
  final bool linkedToOrganization;

  Subscription({
    required this.status,
    this.resSubscriptionPlan,
    required this.daysRemaining,
    this.expiresAt,
    required this.aiExerciseEnabled,
    required this.aiWritingEnabled,
    required this.aiSpeakingEnabled,
    required this.tokenLimit,
    required this.tokensUsed,
    required this.autoFreezeEnabled,
    required this.overdueDaysToFreeze,
    required this.linkedToOrganization,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    status: json["status"] as String? ?? "",
    resSubscriptionPlan: json["resSubscriptionPlan"] == null
        ? null
        : ResSubscriptionPlan.fromJson(
            json["resSubscriptionPlan"] as Map<String, dynamic>,
          ),
    daysRemaining: json["daysRemaining"] as int? ?? 0,
    expiresAt: json["expiresAt"] == null
        ? null
        : DateTime.tryParse(json["expiresAt"] as String? ?? ""),
    aiExerciseEnabled: json["aiExerciseEnabled"] as bool? ?? false,
    aiWritingEnabled: json["aiWritingEnabled"] as bool? ?? false,
    aiSpeakingEnabled: json["aiSpeakingEnabled"] as bool? ?? false,
    tokenLimit: json["tokenLimit"] as int? ?? 0,
    tokensUsed: json["tokensUsed"] as int? ?? 0,
    autoFreezeEnabled: json["autoFreezeEnabled"] as bool? ?? false,
    overdueDaysToFreeze: json["overdueDaysToFreeze"] as int? ?? 0,
    linkedToOrganization: json["linkedToOrganization"] as bool? ?? false,
  );
}

class Pageable {
  final bool unpaged;
  final bool paged;
  final int pageNumber;
  final int pageSize;
  final int offset;
  final List<Sort> sort;

  Pageable({
    required this.unpaged,
    required this.paged,
    required this.pageNumber,
    required this.pageSize,
    required this.offset,
    required this.sort,
  });

  factory Pageable.fromJson(Map<String, dynamic> json) => Pageable(
    unpaged: json["unpaged"] as bool? ?? false,
    paged: json["paged"] as bool? ?? false,
    pageNumber: json["pageNumber"] as int? ?? 0,
    pageSize: json["pageSize"] as int? ?? 0,
    offset: json["offset"] as int? ?? 0,
    sort: List<Sort>.from(json["sort"].map((x) => Sort.fromJson(x))),
  );
}

class Sort {
  final String direction;
  final String nullHandling;
  final bool ascending;
  final String property;
  final bool ignoreCase;

  Sort({
    required this.direction,
    required this.nullHandling,
    required this.ascending,
    required this.property,
    required this.ignoreCase,
  });

  factory Sort.fromJson(Map<String, dynamic> json) => Sort(
    direction: json["direction"] as String? ?? "",
    nullHandling: json["nullHandling"] as String? ?? "",
    ascending: json["ascending"] as bool? ?? false,
    property: json["property"] as String? ?? "",
    ignoreCase: json["ignoreCase"] as bool? ?? false,
  );
}
