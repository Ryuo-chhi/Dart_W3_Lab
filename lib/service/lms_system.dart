import '../model/student.dart';
import '../model/course.dart';
import '../model/score.dart';

class LmsSystem {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<Score> scores = [];

  void addStudent({required String studentId, required String studentName}) {
    // ! Student shall not exist already
    Student? student = _findStudentOrNull(studentId);
    if (student != null) {
      throw Exception('Student $student already exists');
    }

    students.add(Student(id: studentId, name: studentName));
  }

  void removeStudent({required String studentId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }

  // 1. Clean up student from courses
    for (final course in courses) {
      course.studentIds.remove(studentId);
      course.scoreIds.removeWhere((id) => id.contains(studentId));
    }

  // 2. Clean up student's scores
    scores.removeWhere((score) => score.id.contains(studentId));

    /*it can remove the score even the score id is course id + student id 
      because we look up with student id that contain in the score id
    */
    //  Remove student from the students list
    students.removeWhere((student) => student.id == studentId);
  }

  Student? _findStudentOrNull(String studentId) {
    for (Student s in students) {
      if (s.id == studentId) {
        return s;
      }
    }
    return null; // not found
  }

  void addCourse({required String id, required String name}) {
    Course? course = _findExistingCourse(id);
    if (course != null) {
      throw Exception("Course $id is already exists");
    }
    courses.add(Course(id: id, name: name));
  }

  void removeCourse({required String courseId}) {
    Course? course = _findExistingCourse(courseId);
    if (course == null) {
      throw Exception("Course $courseId is not exists!");
    }
    scores.removeWhere((score) => score.id.startsWith('${courseId}_'));
    courses.removeWhere((c) => c == course);
    print("Couse id: $courseId have been removed.");
  }

  void enrollStudent({required String studentId, required String courseId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception("Student not exists yet");
    }

    Course? course = _findExistingCourse(courseId);
    if (course == null) {
      throw Exception("Course $courseId is not exists yet");
    }

    if (course.studentIds.any((s) => s == studentId))
      throw Exception("Student already enrolled in this course!");

    course.studentIds.add(studentId);
  }

  void discardStudentFromCourse(
      {required String studentId, required String courseId}) {
    final course =
        _validateStudentAndCourse(studentId: studentId, courseId: courseId);

    course.scoreIds.removeWhere((scoreId) => scoreId.contains(studentId));
    course.studentIds.removeWhere((sid) => sid == studentId);
    //remove from main list
    scores.removeWhere((score) => score.id == '${courseId}_$studentId');
    print("Discarded student ID: $studentId from course ID: $courseId.");
  }

  void addScoreToStudent(
      {required String studentId,
      required String courseId,
      required int score}) {
    if (score < 0 || score > 100) {
      throw Exception('Score must be between 0 and 100');
    }
    final course =
        _validateStudentAndCourse(studentId: studentId, courseId: courseId);

    //generate Score ID
    final scoreID = "${courseId}_${studentId}";

    // Reject duplicate score
    if (scores.any((s) => s.id == scoreID)) {
      throw Exception(
          'Score already exists for student $studentId in course $courseId');
    }

    scores.add(Score(scoreID, score));
    course.scoreIds.add(studentId);
  }

  /// Task 5: Remove a student result
  void removeScore({required String studentId, required String courseId}) {
    // 1. Validate that the student exists
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId not found');
    }

    // 2. Validate that the course exists
    final course = _findExistingCourse(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }

    // 3. Must the result exist? Yes -> throw if not found
    final resultId = "${courseId}_${studentId}";
    final index = scores.indexWhere((s) => s.id == resultId);
    if (index == -1) {
      throw Exception(
          'Score for student $studentId in course $courseId not found');
    }

    // 4. Data consistency: remove from global scores list
    scores.removeAt(index);

    // 5. Data consistency: remove from course.scoreIds
    course.scoreIds.removeWhere((id) => id == studentId || id == resultId);
  }

  //helper function

  // Validates that:
  // 1. The student exists
  // 2. The course exists
  // 3. The student is enrolled in the course
  //
  // Throws [Exception] with a specific message if any check fails.
  Course _validateStudentAndCourse({
    required String studentId,
    required String courseId,
  }) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId does not exist');
    }

    final course = _findExistingCourse(courseId);
    if (course == null) {
      throw Exception('Course $courseId does not exist');
    }

    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in course $courseId');
    }
    return course;
  }

  Course? _findExistingCourse(String courseId) {
    for (Course c in courses) {
      if (c.id == courseId) {
        return c;
      }
    }
    return null; // not found
  }
}
