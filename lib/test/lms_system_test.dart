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

  group("LmsSystem#enrollStudent", () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S01', studentName: "ronan");

    test('create course', () {
      lms.addCourse(id: "C12", name: "Mobile Development");

      expect(lms.courses[0].name, "Mobile Development");
    });

    test("add to student to course", () {
      lms.enrollStudent(studentId: 'S01', courseId: "C12");

      expect(lms.courses[0].studentIds[0], "S01");
    });

    // test("try to add duplicate student to course", () {
    //   lms.enrollStudent(studentId: 'S01', courseId: "C12");

    //   expect(lms.courses[0].studentIds[1], "S01");
    // });

    test("add score to student", () {
      lms.addScoreToStudent(studentId: "S01", courseId: "C12", score: 85);

      expect(lms.scores[0].id, "C12_S01");
      expect(lms.scores[0].score, 85);
    });

    test("delete student", () {
      lms.removeStudent(studentId: "S01");
      expect(lms.students, isEmpty);
    });
  });

  group("Testing in courses", () {
    //Task 1
    test("Add and remove course", () {
      final lms = LmsSystem();
      lms.addCourse(id: "C12", name: "Mobile Development");
      expect(lms.courses[0].name, "Mobile Development");

      lms.removeCourse(courseId: "C12");
      expect(lms.courses, isEmpty);
    });
    test("Reject the duplicate id and remove nonexist course", () {
      final lms = LmsSystem();

      lms.addCourse(id: "C12", name: "Mobile Development");
      expect(lms.courses[0].name, "Mobile Development");

      expect(() => lms.addCourse(id: "C12", name: "Project Management"),
          throwsException);

      expect(() => lms.removeCourse(courseId: "C13"), throwsException);
    });

    test("Removing a course removes its scores but keeps students", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.addCourse(id: "C13", name: "Project Management");
      lms.enrollStudent(studentId: "S01", courseId: "C12");
      lms.enrollStudent(studentId: "S01", courseId: "C13");
      lms.addScoreToStudent(studentId: "S01", courseId: "C12", score: 85);
      lms.addScoreToStudent(studentId: "S01", courseId: "C13", score: 90);

      lms.removeCourse(courseId: "C12");

      expect(lms.students.map((student) => student.id), contains("S01"));
      expect(lms.courses.map((course) => course.id), contains("C13"));
      expect(lms.scores.map((score) => score.id), ["C13_S01"]);
    });

    //Task 2
    test("Enroll a student in a course", () {
      final lms = LmsSystem();

      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");

      lms.enrollStudent(studentId: "S01", courseId: "C12");
      expect(lms.courses[0].studentIds[0], "S01");
      // Reject enrollment if the student does not exist.
      expect(() => lms.enrollStudent(studentId: "S02", courseId: "C12"),
          throwsException);
      // Reject enrollment if the course does not exist.
      expect(() => lms.enrollStudent(studentId: "S01", courseId: "C13"),
          throwsException);

      // Reject duplicate enrollment.
      expect(() => lms.enrollStudent(studentId: "S01", courseId: "C12"),
          throwsException);
    });

    // Task 3: Unenrollment and Student Removal
    test("Remove an existing enrollment", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.enrollStudent(studentId: "S01", courseId: "C12");

      expect(lms.courses[0].studentIds, contains("S01"));

      lms.discardStudentFromCourse(studentId: "S01", courseId: "C12");

      expect(lms.courses[0].studentIds, isNot(contains("S01")));
    });

    test("Reject removal of a nonexistent enrollment", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addStudent(studentId: "S02", studentName: "alice");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.enrollStudent(studentId: "S01", courseId: "C12");

      // 1. Student exists and course exists, but student S02 is not enrolled
      expect(
        () => lms.discardStudentFromCourse(studentId: "S02", courseId: "C12"),
        throwsException,
      );

      // 2. Course does not exist
      expect(
        () => lms.discardStudentFromCourse(studentId: "S01", courseId: "C99"),
        throwsException,
      );

      // 3. Student does not exist
      expect(
        () => lms.discardStudentFromCourse(studentId: "S99", courseId: "C12"),
        throwsException,
      );
    });

    test("Verify student and course still exist after enrollment is removed", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.enrollStudent(studentId: "S01", courseId: "C12");

      lms.discardStudentFromCourse(studentId: "S01", courseId: "C12");

      // Both student and course must still exist in LMS
      expect(lms.students.map((s) => s.id), contains("S01"));
      expect(lms.courses.map((c) => c.id), contains("C12"));
    });

    test("Verify chosen policy for associated results when enrollment is removed", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.addCourse(id: "C13", name: "Cloud Computing");
      lms.enrollStudent(studentId: "S01", courseId: "C12");
      lms.enrollStudent(studentId: "S01", courseId: "C13");
      lms.addScoreToStudent(studentId: "S01", courseId: "C12", score: 85);
      lms.addScoreToStudent(studentId: "S01", courseId: "C13", score: 95);

      // Remove enrollment for C12
      lms.discardStudentFromCourse(studentId: "S01", courseId: "C12");

      // Policy: The score for C12 is removed
      final courseC12 = lms.courses.firstWhere((c) => c.id == "C12");
      expect(courseC12.scoreIds.contains("S01"), isFalse);
      expect(lms.scores.any((s) => s.id == "C12_S01"), isFalse);

      // The score for C13 must be preserved
      expect(lms.scores.any((s) => s.id == "C13_S01"), isTrue);
    });

    test("Removing a student who has enrollments in multiple courses", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.addCourse(id: "C13", name: "Cloud Computing");
      lms.addCourse(id: "C14", name: "Machine Learning");

      // Student enrolled in C12 and C13, but not C14
      lms.enrollStudent(studentId: "S01", courseId: "C12");
      lms.enrollStudent(studentId: "S01", courseId: "C13");
      lms.addScoreToStudent(studentId: "S01", courseId: "C12", score: 85);
      lms.addScoreToStudent(studentId: "S01", courseId: "C13", score: 90);

      // Remove student from LMS
      lms.removeStudent(studentId: "S01");

      // Verify student is removed from LMS
      expect(lms.students.any((s) => s.id == "S01"), isFalse);

      // Verify student is removed from all courses
      final c12 = lms.courses.firstWhere((c) => c.id == "C12");
      final c13 = lms.courses.firstWhere((c) => c.id == "C13");
      expect(c12.studentIds.contains("S01"), isFalse);
      expect(c13.studentIds.contains("S01"), isFalse);

      // Verify all courses still exist
      expect(lms.courses.length, 3);

      // Verify all student scores are deleted
      expect(lms.scores.any((s) => s.id.contains("S01")), isFalse);
    });

    // Task 4: Recording Results (Scores)
    test("Add a valid result", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.enrollStudent(studentId: "S01", courseId: "C12");

      lms.addScoreToStudent(studentId: "S01", courseId: "C12", score: 85);

      expect(lms.scores.length, 1);
      expect(lms.scores[0].id, "C12_S01");
      expect(lms.scores[0].score, 85);
      expect(lms.courses[0].scoreIds, contains("S01"));
    });

    test("Reject a result for a nonexistent student or course", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.enrollStudent(studentId: "S01", courseId: "C12");

      // Nonexistent student
      expect(
        () => lms.addScoreToStudent(
            studentId: "S99", courseId: "C12", score: 85),
        throwsException,
      );

      // Nonexistent course
      expect(
        () => lms.addScoreToStudent(
            studentId: "S01", courseId: "C99", score: 85),
        throwsException,
      );
    });

    test("Reject a result for a student who is not enrolled", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addStudent(studentId: "S02", studentName: "alice");
      lms.addCourse(id: "C12", name: "Mobile Development");

      // Only S01 is enrolled, S02 is not
      lms.enrollStudent(studentId: "S01", courseId: "C12");

      expect(
        () => lms.addScoreToStudent(
            studentId: "S02", courseId: "C12", score: 90),
        throwsException,
      );
    });

    test("Reject an invalid score", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.enrollStudent(studentId: "S01", courseId: "C12");

      // Score below 0
      expect(
        () => lms.addScoreToStudent(
            studentId: "S01", courseId: "C12", score: -1),
        throwsException,
      );

      // Score above 100
      expect(
        () => lms.addScoreToStudent(
            studentId: "S01", courseId: "C12", score: 101),
        throwsException,
      );
    });

    test("Test the chosen policy for duplicate results", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.enrollStudent(studentId: "S01", courseId: "C12");

      // Add initial score
      lms.addScoreToStudent(studentId: "S01", courseId: "C12", score: 85);

      // Policy: Reject duplicate score for the same student in the same course
      expect(
        () => lms.addScoreToStudent(
            studentId: "S01", courseId: "C12", score: 90),
        throwsException,
      );

      // Verify the original score remains unchanged and no duplicate was added
      expect(lms.scores.length, 1);
      expect(lms.scores[0].score, 85);
    });

    // Task 5: Remove a student result
    test("Remove an existing result", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.enrollStudent(studentId: "S01", courseId: "C12");
      lms.addScoreToStudent(studentId: "S01", courseId: "C12", score: 85);

      expect(lms.scores.any((s) => s.id == "C12_S01"), isTrue);

      lms.removeScore(studentId: "S01", courseId: "C12");

      expect(lms.scores.any((s) => s.id == "C12_S01"), isFalse);
      expect(lms.courses[0].scoreIds.contains("S01"), isFalse);
    });

    test("Reject removal of a nonexistent result", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.enrollStudent(studentId: "S01", courseId: "C12");

      // 1. Student and course exist, but no score was ever added
      expect(
        () => lms.removeScore(studentId: "S01", courseId: "C12"),
        throwsException,
      );

      // 2. Nonexistent student
      expect(
        () => lms.removeScore(studentId: "S99", courseId: "C12"),
        throwsException,
      );

      // 3. Nonexistent course
      expect(
        () => lms.removeScore(studentId: "S01", courseId: "C99"),
        throwsException,
      );
    });

    test("Verify that the result is no longer available", () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.enrollStudent(studentId: "S01", courseId: "C12");
      lms.addScoreToStudent(studentId: "S01", courseId: "C12", score: 85);

      lms.removeScore(studentId: "S01", courseId: "C12");

      // Result is no longer in scores
      expect(lms.scores, isEmpty);

      // Subsequent attempt to remove it again is rejected
      expect(
        () => lms.removeScore(studentId: "S01", courseId: "C12"),
        throwsException,
      );
    });

    test("Verify that student, course, and unrelated results remain unchanged",
        () {
      final lms = LmsSystem();
      lms.addStudent(studentId: "S01", studentName: "ronan");
      lms.addStudent(studentId: "S02", studentName: "alice");
      lms.addCourse(id: "C12", name: "Mobile Development");
      lms.addCourse(id: "C13", name: "Cloud Computing");

      lms.enrollStudent(studentId: "S01", courseId: "C12");
      lms.enrollStudent(studentId: "S01", courseId: "C13");
      lms.enrollStudent(studentId: "S02", courseId: "C12");

      lms.addScoreToStudent(studentId: "S01", courseId: "C12", score: 85);
      lms.addScoreToStudent(studentId: "S01", courseId: "C13", score: 90);
      lms.addScoreToStudent(studentId: "S02", courseId: "C12", score: 95);

      // Remove only S01's score in C12
      lms.removeScore(studentId: "S01", courseId: "C12");

      // 1. Verify students still exist and remain enrolled
      expect(lms.students.map((s) => s.id), containsAll(["S01", "S02"]));
      final c12 = lms.courses.firstWhere((c) => c.id == "C12");
      final c13 = lms.courses.firstWhere((c) => c.id == "C13");
      expect(c12.studentIds, containsAll(["S01", "S02"]));
      expect(c13.studentIds, contains("S01"));

      // 2. Verify courses still exist
      expect(lms.courses.map((c) => c.id), containsAll(["C12", "C13"]));

      // 3. Verify unrelated results remain unchanged
      expect(lms.scores.length, 2);
      expect(lms.scores.any((s) => s.id == "C13_S01" && s.score == 90), isTrue);
      expect(lms.scores.any((s) => s.id == "C12_S02" && s.score == 95), isTrue);
      expect(lms.scores.any((s) => s.id == "C12_S01"), isFalse);
    });
  });
}
