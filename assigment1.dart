import 'dart:io';

enum Grade { A, B, C, D, F, NotAssigned }

extension GradeExtension on Grade {
  String get stringValue {
    switch (this) {
      case Grade.A: return 'A';
      case Grade.B: return 'B';
      case Grade.C: return 'C';
      case Grade.D: return 'D';
      case Grade.F: return 'F';
      case Grade.NotAssigned: return 'Not Assigned';
    }
  }

  double get numericValue {
    switch (this) {
      case Grade.A: return 4.0;
      case Grade.B: return 3.0;
      case Grade.C: return 2.0;
      case Grade.D: return 1.0;
      case Grade.F: return 0.0;
      case Grade.NotAssigned: return 0.0;
    }
  }

  String get colorCode {
    switch (this) {
      case Grade.A: return '\x1B[32m';
      case Grade.B: return '\x1B[36m';
      case Grade.C: return '\x1B[33m';
      case Grade.D: return '\x1B[35m';
      case Grade.F: return '\x1B[31m';
      case Grade.NotAssigned: return '\x1B[37m';
    }
  }
}

class Student {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final List<Enrollment> enrollments;

  Student({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
  }) : enrollments = [];

  double get gpa {
    if (enrollments.isEmpty) return 0.0;
    
    double totalPoints = 0;
    int totalCredits = 0;
    
    for (var enrollment in enrollments) {
      if (enrollment.grade != Grade.NotAssigned) {
        totalPoints += enrollment.grade.numericValue * enrollment.course.creditHours;
        totalCredits += enrollment.course.creditHours;
      }
    }
    
    return totalCredits > 0 ? totalPoints / totalCredits : 0.0;
  }

  void addEnrollment(Enrollment enrollment) {
    enrollments.add(enrollment);
  }

  @override
  String toString() {
    return 'Student(ID: $id, Name: $name, Email: $email, Phone: ${phoneNumber ?? "N/A"})';
  }
}

class Course {
  final String courseCode;
  final String courseName;
  final int creditHours;
  final List<Enrollment> enrollments;

  Course({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
  }) : enrollments = [];

  void addEnrollment(Enrollment enrollment) {
    enrollments.add(enrollment);
  }

  double get averageGrade {
    if (enrollments.isEmpty) return 0.0;
    
    double total = 0;
    int count = 0;
    
    for (var enrollment in enrollments) {
      if (enrollment.grade != Grade.NotAssigned) {
        total += enrollment.grade.numericValue;
        count++;
      }
    }
    
    return count > 0 ? total / count : 0.0;
  }

  @override
  String toString() {
    return 'Course(Code: $courseCode, Name: $courseName, Credits: $creditHours)';
  }
}

class Enrollment {
  final Student student;
  final Course course;
  Grade grade;

  Enrollment({
    required this.student,
    required this.course,
    this.grade = Grade.NotAssigned,
  });

  void updateGrade(Grade newGrade) {
    grade = newGrade;
  }

  @override
  String toString() {
    final gradeColor = grade.colorCode;
    final resetColor = '\x1B[0m';
    return 'Enrollment(Student: ${student.name}, Course: ${course.courseName}, Grade: $gradeColor${grade.stringValue}$resetColor)';
  }
}

class CEMS {
  final List<Student> _students = [];
  final List<Course> _courses = [];
  final List<Enrollment> _enrollments = [];

  String _getInput(String prompt, {bool optional = false}) {
    while (true) {
      stdout.write(prompt);
      final input = stdin.readLineSync()?.trim() ?? '';
      
      if (!optional && input.isEmpty) {
        print('Error: This field is required!');
        continue;
      }
      
      return input;
    }
  }

  Grade _parseGrade(String gradeInput) {
    switch (gradeInput) {
      case 'A': return Grade.A;
      case 'B': return Grade.B;
      case 'C': return Grade.C;
      case 'D': return Grade.D;
      case 'F': return Grade.F;
      default: throw Exception('Invalid grade. Please use A, B, C, D, or F.');
    }
  }

  void addStudent() {
    print('\n=== Add New Student ===');
    
    try {
      final id = _getInput('Enter student ID: ');
      if (_students.any((s) => s.id == id)) {
        print('Error: Student with ID $id already exists!');
        return;
      }

      final name = _getInput('Enter student name: ');
      if (name.isEmpty) {
        print('Error: Name cannot be empty!');
        return;
      }

      final email = _getInput('Enter student email: ');
      if (_students.any((s) => s.email == email)) {
        print('Error: Student with email $email already exists!');
        return;
      }

      final phone = _getInput('Enter student phone (optional): ', optional: true);

      final student = Student(
        id: id,
        name: name,
        email: email,
        phoneNumber: phone.isEmpty ? null : phone,
      );

      _students.add(student);
      print('Success: Student added successfully!');
    } catch (e) {
      print('Error adding student: $e');
    }
  }

  void addCourse() {
    print('\n=== Add New Course ===');
    
    try {
      final code = _getInput('Enter course code: ');
      if (_courses.any((c) => c.courseCode == code)) {
        print('Error: Course with code $code already exists!');
        return;
      }

      final name = _getInput('Enter course name: ');
      if (name.isEmpty) {
        print('Error: Course name cannot be empty!');
        return;
      }

      final credits = int.tryParse(_getInput('Enter credit hours: '));
      if (credits == null || credits <= 0) {
        print('Error: Invalid credit hours!');
        return;
      }

      final course = Course(
        courseCode: code,
        courseName: name,
        creditHours: credits,
      );

      _courses.add(course);
      print('Success: Course added successfully!');
    } catch (e) {
      print('Error adding course: $e');
    }
  }

  void enrollStudent() {
    print('\n=== Enroll Student in Course ===');
    
    try {
      final studentId = _getInput('Enter student ID: ');
      final courseCode = _getInput('Enter course code: ');

      final student = _students.firstWhere((s) => s.id == studentId);
      final course = _courses.firstWhere((c) => c.courseCode == courseCode);

      if (_enrollments.any((e) => e.student.id == studentId && e.course.courseCode == courseCode)) {
        print('Error: Student is already enrolled in this course!');
        return;
      }

      final enrollment = Enrollment(student: student, course: course);
      _enrollments.add(enrollment);
      student.addEnrollment(enrollment);
      course.addEnrollment(enrollment);

      print('Success: Student enrolled successfully!');
    } catch (e) {
      print('Error enrolling student: $e');
    }
  }

  void assignGrade() {
    print('\n=== Assign Grade ===');
    
    try {
      final studentId = _getInput('Enter student ID: ');
      final courseCode = _getInput('Enter course code: ');

      final enrollment = _enrollments.firstWhere(
        (e) => e.student.id == studentId && e.course.courseCode == courseCode,
        orElse: () => throw Exception('Enrollment not found'),
      );

      print('Available grades: A, B, C, D, F');
      final gradeInput = _getInput('Enter grade: ').toUpperCase();
      
      final grade = _parseGrade(gradeInput);
      enrollment.updateGrade(grade);

      print('Success: Grade assigned successfully!');
    } catch (e) {
      print('Error assigning grade: $e');
    }
  }

  void viewAllStudentsAndCourses() {
    print('\n=== All Students ===');
    if (_students.isEmpty) {
      print('No students found.');
    } else {
      for (var student in _students) {
        print(student);
        if (student.enrollments.isNotEmpty) {
          print('  Enrollments:');
          for (var enrollment in student.enrollments) {
            print('    - ${enrollment.course.courseName} (${enrollment.grade.stringValue})');
          }
        } else {
          print('  No enrollments');
        }
        print('');
      }
    }

    print('\n=== All Courses ===');
    if (_courses.isEmpty) {
      print('No courses found.');
    } else {
      for (var course in _courses) {
        print(course);
        print('  Enrolled students: ${course.enrollments.length}');
        print('');
      }
    }
  }

  void displayMenu() {
    print('''
🎓 Course Enrollment Management System
======================================
1. Add Student
2. Add Course
3. Enroll Student in Course
4. Assign Grade
5. View All Students & Courses
6. Exit
======================================
''');
  }

  void run() {
    print('Welcome to Course Enrollment Management System!');
    
    // Add sample data with your names
    _students.addAll([
      Student(id: '1234', name: 'Arwa', email: 'arwa@uni.edu'),
      Student(id: '1001', name: 'Eyad', email: 'eyad@uni.edu'),
      Student(id: '1002', name: 'Adam', email: 'adam@uni.edu'),
    ]);

    _courses.addAll([
      Course(courseCode: 'CS101', courseName: 'Programming', creditHours: 3),
      Course(courseCode: 'MATH101', courseName: 'Mathematics', creditHours: 4),
    ]);

    print('Sample data loaded: Roway (ID: 1234), Ayad, Adam');
    
    while (true) {
      displayMenu();
      final choice = _getInput('Enter your choice (1-6): ');
      
      try {
        switch (choice) {
          case '1': addStudent(); break;
          case '2': addCourse(); break;
          case '3': enrollStudent(); break;
          case '4': assignGrade(); break;
          case '5': viewAllStudentsAndCourses(); break;
          case '6': 
            print('Thank you for using CEMS. Goodbye!');
            return;
          default: 
            print('Error: Invalid choice.');
        }
      } catch (e) {
        print('Error: $e');
      }
      
      _getInput('\nPress Enter to continue...');
    }
  }
}

void main() {
  final cems = CEMS();
  cems.run();
}