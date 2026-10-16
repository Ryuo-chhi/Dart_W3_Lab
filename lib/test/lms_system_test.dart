import 'package:test/test.dart';

import '../service/lms_system.dart';

void main() {
  test('creates a student', () {
    final lms = LmsSystem();

    // Create a student
    lms.addStudent(studentId: 'S1', studentName: "ronan");

    expect(lms.students.first.name, 'ronan');

    // Remove the student
    lms.removeStudent(studentId: 'S1');
    expect(lms.students.length, 0);
  });

  group("LmsSystem#addStudentToCourse", () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: "ronan");

    test('create course', () {
      lms.addCourse(id: "c12", name: "dart");

      expect(lms.courses[0].name, "dart");
    });

    test("add to student to course", () {
      lms.addStudentToCourse(studentId: 'S1', courseId: "c12");

      expect(lms.courses[0].studentIds[0], "S1");
    });
  });
}
