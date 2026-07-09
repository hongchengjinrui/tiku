import '../mock/models.dart';

abstract class TikuRepository {
  List<Subject> loadSubjects();

  List<Chapter> loadPracticeChapters();

  List<Chapter> loadExamChapters();

  List<Paper> loadPracticePapers();

  List<Paper> loadExamPapers();

  List<StudyRecord> loadPracticeRecords();

  List<StudyRecord> loadExamRecords();

  List<Question> buildPracticeSectionQuestions(Section section);

  List<Question> buildPracticePaperQuestions(Paper paper);

  List<Question> buildRandomPracticeQuestions({
    required int count,
    List<String> catalogIds = const [],
  });

  List<Question> buildFavoritePracticeQuestions({required int count});

  List<Question> buildWrongPracticeQuestions({required int count});

  List<Question> buildExamSectionQuestions(Section section);

  List<Question> buildExamPaperQuestions(Paper paper);

  List<Question> buildAssemblyExamQuestions({
    required int count,
    List<String> catalogIds = const [],
  });
}
