# ASL Learning App
# 🧠 ASL Learning App

A mobile UI implementation application built using Flutter to help users learn American Sign Language (ASL) through interactive visual and hands-on learning modes.

---

## 📱 Features

### 🔐 Authentication
- Email-based Sign In / Sign Up
- Password strength validation
- Show/Hide password

### 🎓 Learning Modes
- **Learn by Seeing**
  - Swipeable gesture gallery
  - Visual learning with images
  - Progress tracking

- **Learn by Doing**
  - Live camera feed
  - Simulated gesture detection
  - Interactive practice interface

### 🧭 Learning Hub
- Resume learning
- Practice mode (planned)
- Tests (locked until progress threshold)

### 🎨 UI/UX
- Clean modern interface
- British Racing Green theme
- Micro-interactions and animations

---

## 🧪 Alternate Design (HCI Requirement)

An alternate UI design is implemented using a **list-based layout** for gesture learning.

### Primary Design
- Visual, swipe-based interaction
- Large images and guided navigation

### Alternate Design
- Compact list view
- Faster scanning and reduced cognitive load

This demonstrates different interaction paradigms as per Human-Computer Interaction principles.

---

## 🛠 Tech Stack

- **Flutter**
- **Dart**
- **Camera Plugin**
- Native MethodChannel (planned for gesture detection)

---

## 🧠 Future Improvements

- Real-time hand gesture detection
- KNN-based classification
- Progress persistence
- User profiles and leaderboards
- Gesture accuracy scoring

---

## 📂 Project Structure
asl-learning-app/
│
├── lib/
│   ├── main.dart
│   │
│   ├── core/
│   │   ├── theme.dart
│   │   └── constants.dart
│   │
│   ├── models/
│   │   └── gesture_model.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── signup_screen.dart
│   │   │
│   │   ├── onboarding/
│   │   │   ├── intro_screen.dart
│   │   │   └── loading_screen.dart
│   │   │
│   │   ├── home/
│   │   │   ├── welcome_screen.dart
│   │   │   ├── mode_select_screen.dart
│   │   │   └── learning_hub_screen.dart
│   │   │
│   │   ├── learning/
│   │   │   ├── learn_by_seeing_screen.dart
│   │   │   ├── learn_by_seeing_alt_screen.dart   // Alternate UI design
│   │   │   └── learn_doing_screen.dart
│   │   │
│   │   └── profile/
│   │       └── profile_screen.dart (future)
│   │
│   ├── widgets/
│   │   ├── mode_card.dart
│   │   └── password_rule.dart
│   │
│   └── services/
│       └── auth_service.dart (future)
│
├── assets/
│   └── gestures/
│       ├── A.png
│       ├── B.png
│       └── C.png
│
├── android/
├── ios/
│
├── pubspec.yaml
├── pubspec.lock
├── README.md
└── .gitignore

> [!NOTE]
> This project focuses on UI/UX and interaction design. Gesture recognition is simulated but the architecture supports real-time implementation.
