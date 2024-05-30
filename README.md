# College Bus Management System App

The College Bus Management System App is a comprehensive solution designed to streamline and enhance the efficiency of managing student transportation within a college campus. It consists of three key modules: Admin, Student, and Driver, each serving specific roles to ensure a smooth and organized bus transportation system.

## Features

- **Admin Module**:
  - Centralized platform for managing the entire bus transportation system.
  - Dynamic assignment of routes and schedule timings.
  - Addition and removal of buses and drivers.
  - Verification of students and drivers with email notifications.
  - Assignment of buses to drivers and monitoring of driver alerts to students.
  - Management of student fees and attendance.
  - Management of districts, places, departments, and courses.
  - Handling student and driver complaints and feedback.
  - Generation of reports.

- **Student Module**:
  - Registration and verification with email confirmation.
  - Selection of routes and stops.
  - Complaint submission about bus routes and timings.
  - Viewing bus fee details and receipt generation upon payment.
  - Attendance marking via QR code.
  - Notification reception for driver alerts.
  - Request for route and stop changes.

- **Driver Module**:
  - Registration and verification with email confirmation.
  - Alert submission to students.
  - Complaint submission.
  - Viewing assigned buses, students, and guardian details.
  - Viewing and editing alerts given to students.

## Technology Stack

- **Frontend**: Flutter
- **Backend**: Python, Django
- **Database**: Firebase (for real-time updates and notifications)

## Key Functionalities

- **Admin**:
  - Manages all aspects of bus transportation including routes, schedules, buses, drivers, and student/driver verification.
  - Handles complaints, feedback, fee management, and attendance tracking.
  - Generates reports for analysis.

- **Student**:
  - Chooses routes and stops.
  - Manages bus fee and attendance.
  - Receives notifications and submits complaints.
  - Requests changes to routes and stops.

- **Driver**:
  - Alerts students and submits complaints.
  - Views assigned buses and student details.
  - Manages their profile.

## Goals

- Improve transportation efficiency and safety.
- Reduce operational costs.
- Provide a convenient experience for passengers.
- Create a sustainable and organized campus environment.

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/college-bus-management-app.git
   ```

2. Navigate into the directory:

   ```bash
   cd college-bus-management-app
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Set up Firebase:

   - Create a new Firebase project on the [Firebase Console](https://console.firebase.google.com/).
   - Add Android/iOS app to your Firebase project.
   - Follow the Firebase setup instructions for Flutter: [Firebase Flutter Setup](https://firebase.flutter.dev/docs/overview)

5. Run the app:

   ```bash
   flutter run
   ```

## Contributing

Contributions are welcome! If you find any issues or have feature requests, please open an issue or create a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Authors

- Developed with Krishnapriya B

## Acknowledgments

- This project was developed to enhance the efficiency and management of student transportation within college campuses.

---
