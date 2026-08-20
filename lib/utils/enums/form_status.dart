enum FormStatus {
  pure,

  /// Fetch Notifications
  fetchNotificationsInLoading,
  fetchNotificationsInSuccess,
  fetchNotificationsInFailure,

  /// Get Library Videos
  getLibraryVideosInLoading,
  getLibraryVideosInSuccess,
  getLibraryVideosInFailure,

  /// get Last Attendance
  getLastAttendanceLoading,
  getLastAttendanceSuccess,
  getLastAttendanceFailure,

  /// Check Pronunciation Task
  checkPronunciationTaskLoading,
  checkPronunciationTaskSuccess,
  checkPronunciationTaskFailure,

  /// Submit Speaking Task
  submitSpeakingTaskLoading,
  submitSpeakingTaskSuccess,
  submitSpeakingTaskFailure,

  /// Get Speaking Question
  getSpeakingQuestionLoading,
  getSpeakingQuestionSuccess,
  getSpeakingQuestionFailure,

  /// Get Writing Question
  getWritingQuestionLoading,
  getWritingQuestionSuccess,
  getWritingQuestionFailure,

  /// Upload File
  uploadFileLoading,
  uploadFileSuccess,
  uploadFileFailure,

  /// Order Create in Coins Market
  orderCreateLoading,
  orderCreateSuccess,
  orderCreateFailure,

  /// Get Coin Market Products
  getCoinMarketProductsLoading,
  getCoinMarketProductsSuccess,
  getCoinMarketProductsFailure,

  /// Get Orders History
  getOrdersHistoryLoading,
  getOrdersHistorySuccess,
  getOrdersHistoryFailure,

  /// Get Coins History
  getCoinsHistoryLoading,
  getCoinsHistorySuccess,
  getCoinsHistoryFailure,

  /// Get Ranking By Group
  getRankingLoading,
  getRankingSuccess,
  getRankingFailure,

  /// Get Ranking By Group
  getRankingByGroupLoading,
  getRankingByGroupSuccess,
  getRankingByGroupFailure,

  /// Get Ranking By School
  getRankingBySchoolLoading,
  getRankingBySchoolSuccess,
  getRankingBySchoolFailure,

  /// Get Exercise Result By Task Id
  getExerciseResultLoading,
  getExerciseResultSuccess,
  getExerciseResultFailure,

  /// Get Exercise Result By Task Id
  getExerciseAiAnalysisResultLoading,
  getExerciseAiAnalysisResultSuccess,
  getExerciseAiAnalysisResultFailure,

  /// Get Questions By Task Id
  getQuestionsByTaskIdLoading,
  getQuestionsByTaskIdSuccess,
  getQuestionsByTaskIdFailure,

  /// Get Unit Detail
  getUnitDetailLoading,
  getUnitDetailSuccess,
  getUnitDetailFailure,

  /// Get Vocabulary Detail
  getVocabularyDetailLoading,
  getVocabularyDetailSuccess,
  getVocabularyDetailFailure,

  /// Get All Homeworks
  getAllHomeWorksLoading,
  getAllHomeWorksSuccess,
  getAllHomeWorksFailure,

  /// Get Homeworks By Lesson
  getHomeworksByLessonLoading,
  getHomeworksByLessonSuccess,
  getHomeworksByLessonFailure,

  /// Start Exam
  startExamLoading,
  startExamSuccess,
  startExamFailure,

  /// Resume Exam
  resumeExamLoading,
  resumeExamSuccess,
  resumeExamFailure,

  /// Get Active Homework
  getActiveHomeworkLoading,
  getActiveHomeworkSuccess,
  getActiveHomeworkFailure,

  /// Get Unit Section Detail
  getUnitSectionLoading,
  getUnitSectionSuccess,
  getUnitSectionFailure,

  /// Sign In
  signInLoading,
  signInSuccess,
  signInFailure,

  /// Get Profile Info
  getProfileInfoInLoading,
  getProfileInfoInSuccess,
  getProfileInfoInFailure,

  /// Get Course Detail
  getCourseDetailInLoading,
  getCourseDetailInSuccess,
  getCourseDetailInFailure,

  /// Get Course Group Details
  getCourseGroupDetailsInLoading,
  getCourseGroupDetailsInSuccess,
  getCourseGroupDetailsInFailure,

  /// Edit Password
  editPasswordInLoading,
  editPasswordInSuccess,
  editPasswordInFailure,

  /// Update Profile
  updateProfileInLoading,
  updateProfileInSuccess,
  updateProfileInFailure,

  /// Post FCM Token
  postFCMTokenInLoading,
  postFCMTokenInSuccess,
  postFCMTokenInFailure,

  /// Check User
  checkUserInLoading,
  checkUserInSuccess,
  checkUserInFailure,

  /// Get Student All Courses
  getStudentAllCoursesInLoading,
  getStudentAllCoursesInSuccess,
  getStudentAllCoursesInFailure,

  /// Get Student All Courses
  getStudentAllLessonsInLoading,
  getStudentAllLessonsInSuccess,
  getStudentAllLessonsInFailure,

  /// Get All Payments
  getAllPaymentsInLoading,
  getAllPaymentsInSuccess,
  getAllPaymentsInFailure,

  /// Create Student Pay
  createStudentPayInLoading,
  createStudentPayInSuccess,
  createStudentPayInFailure,

  /// Submit Gap Fill
  submitPronunciationLoading,
  submitPronunciationSuccess,
  submitPronunciationFailure,

  /// Submit Gap Fill
  submitGapFillLoading,
  submitGapFillSuccess,
  submitGapFillFailure,

  /// Submit Ordering
  submitOrderingLoading,
  submitOrderingSuccess,
  submitOrderingFailure,

  /// Submit Selection
  submitSelectionLoading,
  submitSelectionSuccess,
  submitSelectionFailure,

  /// Submit Matching
  submitMatchingLoading,
  submitMatchingSuccess,
  submitMatchingFailure,

  /// Submit Multi Select
  submitMultiSelectLoading,
  submitMultiSelectSuccess,
  submitMultiSelectFailure,

  /// Submit Circle
  submitCircleLoading,
  submitCircleSuccess,
  submitCircleFailure,

  /// Submit Writing Task
  submitWritingTaskLoading,
  submitWritingTaskSuccess,
  submitWritingTaskFailure,

  /// Submit Tracing
  submitTracingLoading,
  submitTracingSuccess,
  submitTracingFailure,

  /// Submit Fixing
  submitFixingLoading,
  submitFixingSuccess,
  submitFixingFailure,

  /// Get Vocabulary Set Learn
  getVocabularySetLearnLoading,
  getVocabularySetLearnSuccess,
  getVocabularySetLearnFailure,

  /// Get Vocabulary Set Quiz
  getVocabularySetQuizLoading,
  getVocabularySetQuizSuccess,
  getVocabularySetQuizFailure,

  /// Submit Vocabulary Answer
  submitVocabularyAnswerLoading,
  submitVocabularyAnswerSuccess,
  submitVocabularyAnswerFailure,

  /// Get Vocabulary Set Result
  getVocabularySetResultLoading,
  getVocabularySetResultSuccess,
  getVocabularySetResultFailure,
}
