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
    // 1- Remove student from the students list
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

  void addStudentToCourse(
      {required String studentId, required String courseId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception("Student not enrolled yet");
    }

    Course? course = _findExistingCourse(courseId);
    if (course == null) {
      throw Exception("Course $courseId is not exists yet");
    }

    course.studentIds.add(studentId);
  }

  void addScoreToStudent() {}

  Course? _findExistingCourse(String courseId) {
    for (Course c in courses) {
      if (c.id == courseId) {
        return c;
      }
    }
    return null; // not found
  }
}
