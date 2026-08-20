import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mentour_web_view/data/models/course/course_model.dart';
import 'package:mentour_web_view/screens/courses/courses_screen.dart';
import 'package:mentour_web_view/screens/courses/sub_screens/course_detail/course_detail_screen.dart';
import 'package:mentour_web_view/screens/grammar/questions_screen.dart';
import 'package:mentour_web_view/screens/exam/exam_tasks_screen.dart';
import 'package:mentour_web_view/screens/exam/section_questions_screen.dart';
import 'package:mentour_web_view/screens/exam/view_exam_sections_screen.dart';
import 'package:mentour_web_view/screens/groups/groups_screen.dart';
import 'package:mentour_web_view/screens/home/home_screen.dart';
import 'package:mentour_web_view/screens/home/sub_screens/coin_score/coin_score_screen.dart';
import 'package:mentour_web_view/screens/home/sub_screens/notifications/notifications_screen.dart';
import 'package:mentour_web_view/screens/home/sub_screens/ranking/ranking_screen.dart';
import 'package:mentour_web_view/screens/home_works/home_works_screen.dart';
import 'package:mentour_web_view/screens/home_works/sub_screens/unit_detail/sub_screens/tasks_details/tasks_details_screen.dart';
import 'package:mentour_web_view/screens/home_works/sub_screens/unit_detail/sub_screens/vocabulary_detail/vocabulary_detail_screen.dart';
import 'package:mentour_web_view/screens/home_works/sub_screens/unit_detail/unit_detail_screen.dart';
import 'package:mentour_web_view/screens/library/library_screen.dart';
import 'package:mentour_web_view/screens/library/sub_screens/videos/video_detail_screen.dart';
import 'package:mentour_web_view/screens/library/sub_screens/videos/videos_screen.dart';
import 'package:mentour_web_view/screens/no_internet/no_internet_screen.dart';
import 'package:mentour_web_view/screens/results/exercise/exercise_result_screen.dart';
import 'package:mentour_web_view/screens/speaking/speaking_pronunciation_task_screen.dart';
import 'package:mentour_web_view/screens/speaking/speaking_task_screen.dart';
import 'package:mentour_web_view/screens/results/vocabulary/vocabulary_result_screen.dart';
import 'package:mentour_web_view/screens/exam/exam_speaking_pronunciation_task_screen.dart';
import 'package:mentour_web_view/screens/exam/exam_speaking_task_screen.dart';
import 'package:mentour_web_view/screens/exam/exam_vocabulary_detail_screen.dart';
import 'package:mentour_web_view/screens/exam/exam_quiz_words_screen.dart';
import 'package:mentour_web_view/screens/exam/exam_writing_task_screen.dart';
import 'package:mentour_web_view/screens/results/exercise/exam_exercise_result_screen.dart';
import 'package:mentour_web_view/screens/results/vocabulary/exam_vocabulary_result_screen.dart';
import 'package:mentour_web_view/screens/vocabulary/sub_screens/learn_words/learn_words_screen.dart';
import 'package:mentour_web_view/screens/vocabulary/sub_screens/quiz_words/quiz_words_screen.dart';
import 'package:mentour_web_view/screens/writing/writing_task_screen.dart';

class AppRouterNames {
  static const String coursesRoute = '/courses';
  static const String groupsRoute = '/groups';
  static const String homeRoute = '/home';
  static const String videosRoute = '/videos';
  static const String videoDetailRoute = '/video_detail';
  static const String libraryRoute = '/library';
  static const String profileRoute = '/profile';
  static const String homeworksRoute = '/homeworks';
  static const String payment = '/payment';
  static const String paymentWeb = '/payment_web';
  static const String editPasswordRoute = '/edit_password';
  static const String unitDetailRoute = '/unit_detail';
  static const String courseDetailRoute = '/course_detail';
  static const String questionsRoute = '/questions';
  static const String sectionQuestionsRoute = '/section_questions';
  static const String viewExamSectionsRoute = '/view_exam_sections';
  static const String exerciseResultRoute = '/exercise_result';
  static const String quizWordsRoute = '/quiz_words';
  static const String learnWordsRoute = '/learn_words';
  static const String vocabularyResultRoute = '/vocabulary_result';
  static const String noInternetRoute = '/no_internet';
  static const String tasksDetailsRoute = '/tasks_details';
  static const String vocabularyDetailRoute = '/vocabulary_detail';
  static const String notificationsRoute = '/notifications';
  static const String rankingRoute = '/ranking';
  static const String coinScoreRoute = '/coin_score';
  static const String writingTaskRoute = '/writing_task';
  static const String speakingTaskRoute = '/speaking_task';
  static const String speakingPronunciationTaskRoute =
      '/speaking_pronunciation_task';
  static const String examTasksRoute = '/exam_tasks';
  static const String examWritingTaskRoute = '/exam_writing_task';
  static const String examSpeakingTaskRoute = '/exam_speaking_task';
  static const String examSpeakingPronunciationTaskRoute =
      '/exam_speaking_pronunciation_task';
  static const String examVocabularyDetailRoute = '/exam_vocabulary_detail';
  static const String examQuizWordsRoute = '/exam_quiz_words';
  static const String examExerciseResultRoute = '/exam_exercise_result';
  static const String examVocabularyResultRoute = '/exam_vocabulary_result';
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    Map<String, dynamic>? getArgs() =>
        settings.arguments is Map<String, dynamic>
            ? settings.arguments as Map<String, dynamic>
            : null;

    Route<dynamic> missingArgs(String routeName) =>
        MaterialPageRoute(builder: (_) => HomeScreen());

    switch (settings.name) {
      case AppRouterNames.coinScoreRoute:
        return MaterialPageRoute(
          builder: (_) =>
              CoinScoreScreen(schoolId: settings.arguments as String),
        );
      case AppRouterNames.rankingRoute:
        return MaterialPageRoute(builder: (_) => const RankingScreen());
      case AppRouterNames.notificationsRoute:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppRouterNames.learnWordsRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => LearnWordsScreen(
            setUuid: args["setUuid"],
            unitId: args["unitId"],
            isQuizWordsTap: args["isQuizWordsTap"],
          ),
        );
      case AppRouterNames.vocabularyDetailRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => VocabularyDetailScreen(
            groupUuid: args["groupUuid"],
            sectionType: args["sectionType"],
            unitTitle: args["unitTitle"],
            topicName: args["topicName"],
            unitUuid: args["unitUuid"],
            fromHome: args["fromHome"],
          ),
        );
      case AppRouterNames.tasksDetailsRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => TasksDetailsScreen(
            sectionType: args["sectionType"],
            unitTitle: args["unitTitle"],
            topicName: args["topicName"],
            unitUuid: args["unitUuid"],
            fromHome: args["fromHome"],
            groupUuid: args["groupUuid"],
          ),
        );
      case AppRouterNames.writingTaskRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) =>
              WritingTaskScreen(unitId: args["unitId"], taskId: args["taskId"]),
        );
      case AppRouterNames.speakingTaskRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => SpeakingTaskScreen(
            unitId: args["unitId"],
            taskId: args["taskId"],
          ),
        );
      case AppRouterNames.speakingPronunciationTaskRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => SpeakingPronunciationTaskScreen(
            unitId: args["unitId"],
            taskId: args["taskId"],
            maxAttempts: args["maxAttempts"],
          ),
        );
      case AppRouterNames.examWritingTaskRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => ExamWritingTaskScreen(
            unitId: args["unitId"],
            taskId: args["taskId"],
            freezeScreen: args["freezeScreen"] as bool? ?? false,
            freezeTimer: args["freezeTimer"] as int? ?? 30,
            noScreenshot: args["noScreenshot"] as bool? ?? false,
          ),
        );
      case AppRouterNames.examSpeakingTaskRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => ExamSpeakingTaskScreen(
            unitId: args["unitId"],
            taskId: args["taskId"],
            freezeScreen: args["freezeScreen"] as bool? ?? false,
            freezeTimer: args["freezeTimer"] as int? ?? 30,
            noScreenshot: args["noScreenshot"] as bool? ?? false,
          ),
        );
      case AppRouterNames.examSpeakingPronunciationTaskRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => ExamSpeakingPronunciationTaskScreen(
            unitId: args["unitId"],
            taskId: args["taskId"],
            maxAttempts: args["maxAttempts"],
            freezeScreen: args["freezeScreen"] as bool? ?? false,
            freezeTimer: args["freezeTimer"] as int? ?? 30,
            noScreenshot: args["noScreenshot"] as bool? ?? false,
          ),
        );
      case AppRouterNames.examVocabularyDetailRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => ExamVocabularyDetailScreen(
            sectionType: args["sectionType"],
            unitTitle: args["unitTitle"],
            topicName: args["topicName"],
            unitUuid: args["unitUuid"],
            freezeScreen: args["freezeScreen"] as bool? ?? false,
            freezeTimer: args["freezeTimer"] as int? ?? 30,
            noScreenshot: args["noScreenshot"] as bool? ?? false,
          ),
        );
      case AppRouterNames.examQuizWordsRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => ExamQuizWordsScreen(
            setUuid: args["setUuid"],
            unitId: args["unitId"],
            freezeScreen: args["freezeScreen"] as bool? ?? false,
            freezeTimer: args["freezeTimer"] as int? ?? 30,
            noScreenshot: args["noScreenshot"] as bool? ?? false,
          ),
        );
      case AppRouterNames.courseDetailRoute:
        return MaterialPageRoute(
          builder: (_) => CourseDetailScreen(
            courseModel: settings.arguments as CourseModel,
          ),
        );
      case AppRouterNames.homeworksRoute:
        return MaterialPageRoute(
          builder: (_) =>
              HomeWorksScreen(groupUuid: settings.arguments as String? ?? ''),
        );
      case AppRouterNames.groupsRoute:
        return MaterialPageRoute(builder: (_) => GroupsScreen());
      case AppRouterNames.coursesRoute:
        return MaterialPageRoute(builder: (_) => CoursesScreen());
      case '/':
      case AppRouterNames.homeRoute:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(fromInitialRoute: true),
        );
      case AppRouterNames.noInternetRoute:
        return MaterialPageRoute(
          builder: (_) => NoInternetScreen(
            voidCallback: settings.arguments as VoidCallback,
          ),
        );
      case AppRouterNames.unitDetailRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => UnitDetailScreen(
            groupUuid: args["groupUuid"],
            unitId: args["unitId"],
            unitTitle: args["unitTitle"],
          ),
        );
      case AppRouterNames.quizWordsRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) =>
              QuizWordsScreen(setUuid: args["setUuid"], unitId: args["unitId"]),
        );
      case AppRouterNames.sectionQuestionsRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => SectionQuestionsScreen(
            taskId: args["taskId"],
            unitId: args["unitId"],
            type: args["type"],
            freezeScreen: args["freezeScreen"] as bool? ?? false,
            freezeTimer: args["freezeTimer"] as int? ?? 30,
            noScreenshot: args["noScreenshot"] as bool? ?? false,
          ),
        );
      case AppRouterNames.questionsRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => QuestionsScreen(
            taskId: args["taskId"],
            unitId: args["unitId"],
            type: args["type"],
          ),
        );
      case AppRouterNames.libraryRoute:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());
      case AppRouterNames.videosRoute:
        return MaterialPageRoute(builder: (_) => const VideosScreen());
      case AppRouterNames.videoDetailRoute:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => VideoDetailScreen(
            videoId: args["videoId"],
            videoTitle: args["videoTitle"],
            levelType: args["levelType"],
            videoDescription: args["videoDescription"],
          ),
        );
      case AppRouterNames.viewExamSectionsRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          settings:
          settings, // needed for ModalRoute.of(context)?.settings.name
          builder: (_) => ViewExamSectionsScreen(
            homework: args["homework"],
            groupUuid: args["groupUuid"],
          ),
        );
      case AppRouterNames.examTasksRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          settings:
          settings, // needed for ModalRoute.of(context)?.settings.name
          builder: (_) => ExamTasksScreen(
            unitUuid: args["unitUuid"],
            sectionType: args["sectionType"],
            freezeScreen: args["freezeScreen"] as bool? ?? false,
            freezeTimer: args["freezeTimer"] as int? ?? 30,
            noScreenshot: args["noScreenshot"] as bool? ?? false,
          ),
        );
      case AppRouterNames.exerciseResultRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => ExerciseResultScreen(
            taskId: args["taskId"],
            unitId: args["unitId"],
            type: args["type"],
          ),
        );
      case AppRouterNames.vocabularyResultRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => VocabularyResultScreen(
            setUuid: args["setUuid"],
            unitId: args["unitId"],
          ),
        );
      case AppRouterNames.examExerciseResultRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => ExamExerciseResultScreen(
            taskId: args["taskId"],
            unitId: args["unitId"],
            type: args["type"],
          ),
        );
      case AppRouterNames.examVocabularyResultRoute:
        final args = getArgs();
        if (args == null) return missingArgs(settings.name ?? '');
        return MaterialPageRoute(
          builder: (_) => ExamVocabularyResultScreen(
            setUuid: args["setUuid"],
            unitId: args["unitId"],
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) {
            return Scaffold(
              body: Center(
                child: Text('${"no_route_defined".tr()} ${settings.name}'),
              ),
            );
          },
        );
    }
  }
}
