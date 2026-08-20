class CourseModel {
  final String id;
  final String courseName;
  final String schoolName;
  final String mentorName;
  final List<BookModel> books;
  final String moderatorName;
  final String description;
  final int numberOfLessons;
  final int courseProgress;
  final String currentUnitOutOf;
  final ResGroup resGroup;
  final num unitProgresses;

  CourseModel({
    required this.id,
    required this.courseName,
    required this.schoolName,
    required this.mentorName,
    required this.books,
    required this.moderatorName,
    required this.description,
    required this.numberOfLessons,
    required this.courseProgress,
    required this.currentUnitOutOf,
    required this.resGroup,
    required this.unitProgresses,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) => CourseModel(
    id: json["id"] as String? ?? "",
    courseName: json["courseName"] as String? ?? "",
    schoolName: json["schoolName"] as String? ?? "",
    mentorName: json["mentorName"] as String? ?? "",
    books: (json["books"] as List? ?? [])
        .map((x) => BookModel.fromJson(x))
        .toList(),
    moderatorName: json["moderatorName"] as String? ?? "",
    description: json["description"] as String? ?? "",
    numberOfLessons: json["numberOfLessons"] as int? ?? 0,
    courseProgress: json["courseProgress"] as int? ?? 0,
    currentUnitOutOf: json["currentUnitOutOf"] as String? ?? "",
    unitProgresses: json["unitProgresses"] as num? ?? 0,
    resGroup: ResGroup.fromJson(
      json["resGroup"] as Map<String, dynamic>? ?? {},
    ),
  );
}

class BookModel {
  final String bookUuid;
  final String bookName;
  final bool isGlobal;

  BookModel({
    required this.bookUuid,
    required this.bookName,
    required this.isGlobal,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
    bookUuid: json["bookUuid"] as String? ?? "",
    bookName: json["bookName"] as String? ?? "",
    isGlobal: json["isGlobal"] as bool? ?? false,
  );
}

class ResGroup {
  final String id;
  final String name;
  final String branchName;
  final String teacherFullName;
  final String teacherId;
  final BranchId branchId;
  final SchoolInfo schoolInfo;
  final Level level;

  ResGroup({
    required this.id,
    required this.name,
    required this.branchName,
    required this.teacherFullName,
    required this.teacherId,
    required this.branchId,
    required this.schoolInfo,
    required this.level,
  });

  factory ResGroup.fromJson(Map<String, dynamic> json) => ResGroup(
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

class Level {
  final String level;
  final String uuid;
  final String subjectName;

  Level({required this.level, required this.uuid, required this.subjectName});

  factory Level.fromJson(Map<String, dynamic> json) => Level(
    level: json["level"] as String? ?? "",
    uuid: json["uuid"] as String? ?? "",
    subjectName: json["subjectName"] as String? ?? "",
  );
}

class SchoolInfo {
  final String uuid;
  final String name;
  final String address;
  final int studentCount;
  final int classCount;
  final String phoneNumber;
  final int teacherCount;
  final String telegramLink;

  SchoolInfo({
    required this.uuid,
    required this.name,
    required this.address,
    required this.studentCount,
    required this.classCount,
    required this.phoneNumber,
    required this.teacherCount,
    required this.telegramLink,
  });

  factory SchoolInfo.fromJson(Map<String, dynamic> json) => SchoolInfo(
    uuid: json["uuid"] as String? ?? "",
    name: json["name"] as String? ?? "",
    address: json["address"] as String? ?? "",
    studentCount: json["studentCount"] as int? ?? 0,
    classCount: json["classCount"] as int? ?? 0,
    phoneNumber: json["phoneNumber"] as String? ?? "",
    teacherCount: json["teacherCount"] as int? ?? 0,
    telegramLink: json["telegramLink"] as String? ?? "",
  );
}
