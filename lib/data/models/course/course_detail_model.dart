import 'package:mentour_web_view/data/models/course/course_model.dart';

class CourseDetailModel {
  final String id;
  final String courseName;
  final String schoolId;
  final String groupId;
  final String mentorId;
  final String moderatorId;
  final String schoolName;
  final String mentorName;
  final String moderatorName;
  final String description;
  final int numberOfLessons;
  final int courseDurationHours;
  final List<Lesson> lessons;
  final List<BookModel> books;
  final num unitProgresses;

  CourseDetailModel({
    required this.id,
    required this.courseName,
    required this.schoolId,
    required this.groupId,
    required this.mentorId,
    required this.moderatorId,
    required this.schoolName,
    required this.mentorName,
    required this.moderatorName,
    required this.description,
    required this.numberOfLessons,
    required this.courseDurationHours,
    required this.lessons,
    required this.books,
    required this.unitProgresses,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) =>
      CourseDetailModel(
        id: json["id"] as String? ?? "",
        courseName: json["courseName"] as String? ?? "",
        schoolId: json["schoolId"] as String? ?? "",
        groupId: json["groupId"] as String? ?? "",
        mentorId: json["mentorId"] as String? ?? "",
        moderatorId: json["moderatorId"] as String? ?? "",
        schoolName: json["schoolName"] as String? ?? "",
        mentorName: json["mentorName"] as String? ?? "",
        moderatorName: json["moderatorName"] as String? ?? "",
        description: json["description"] as String? ?? "",
        numberOfLessons: json["numberOfLessons"] as int? ?? 0,
        courseDurationHours: json["courseDurationHours"] as int? ?? 0,
        unitProgresses: json["unitProgresses"] as num? ?? 0,
        lessons: (json["lessons"] as List? ?? [])
            .map((x) => Lesson.fromJson(x))
            .toList(),
        books: (json["books"] as List? ?? [])
            .map((x) => BookModel.fromJson(x))
            .toList(),
      );
}

class Lesson {
  final String lessonId;
  final String attendanceStatus;
  final String name;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String joinLink;
  final String status;
  final List<Recording> recordings;

  Lesson({
    required this.lessonId,
    required this.attendanceStatus,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    required this.joinLink,
    required this.status,
    required this.recordings,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
    lessonId: json["lessonId"] as String? ?? "",
    attendanceStatus: json["attendanceStatus"] as String? ?? "",
    name: json["name"] as String? ?? "",
    startTime: json["startTime"] as String? ?? "",
    endTime: json["endTime"] as String? ?? "",
    durationMinutes: json["durationMinutes"] as int? ?? 0,
    joinLink: json["joinLink"] as String? ?? "",
    status: json["status"] as String? ?? "",
    recordings: (json["recordings"] as List? ?? [])
        .map((x) => Recording.fromJson(x))
        .toList(),
  );
}

class Recording {
  final String id;
  final String name;
  final String playbackUrl;
  final int durationSeconds;
  final bool isPublished;
  final String lessonUuid;
  final List<Segment> segments;

  Recording({
    required this.id,
    required this.name,
    required this.playbackUrl,
    required this.durationSeconds,
    required this.isPublished,
    required this.lessonUuid,
    required this.segments,
  });

  factory Recording.fromJson(Map<String, dynamic> json) => Recording(
    id: json["id"] as String? ?? "",
    name: json["name"] as String? ?? "",
    playbackUrl: json["playbackUrl"] as String? ?? "",
    durationSeconds: json["durationSeconds"] as int? ?? 0,
    isPublished: json["isPublished"] as bool? ?? false,
    lessonUuid: json["lessonUuid"] as String? ?? "",
    segments: (json["segments"] as List? ?? [])
        .map((x) => Segment.fromJson(x))
        .toList(),
  );
}

class Segment {
  final String id;
  final String name;
  final String playbackUrl;
  final int durationSeconds;
  final String studentId;
  final String studentName;

  Segment({
    required this.id,
    required this.name,
    required this.playbackUrl,
    required this.durationSeconds,
    required this.studentId,
    required this.studentName,
  });

  factory Segment.fromJson(Map<String, dynamic> json) => Segment(
    id: json["id"] as String? ?? "",
    name: json["name"] as String? ?? "",
    playbackUrl: json["playbackUrl"] as String? ?? "",
    durationSeconds: json["durationSeconds"] as int? ?? 0,
    studentId: json["studentId"] as String? ?? "",
    studentName: json["studentName"] as String? ?? "",
  );
}
