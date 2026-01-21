# SmartVitals

**SmartVitals** is a comprehensive AI-powered health monitoring and management system. It bridges the gap between hardware sensor data and clinical analysis to provide real-time health risk assessments and personalized nutritional guidance.

## Key Features

* **Real-Time Vitals Monitoring**: Integrated BLE support for MAX30102 pulse sensors to track heart rate and oxygen saturation.
* **Predictive Health Analytics**: On-device and cloud-based XGBoost models that predict risks for Type 2 Diabetes, Hypertension, and Heart Attacks with ~85.8% accuracy.
* **Medical Report Parsing**: Automated extraction of biochemical blood test data from E-Nabız PDF reports.
* **Nutritional Intelligence**: A database of 64,000+ recipes with AI-powered filtering for allergens (gluten, dairy) and ethical/religious dietary requirements (Halal, Vegan).
* **AI Health Assistant**: A dedicated chatbot powered by Google Gemini for health queries and application guidance.
* **Emergency SOS System**: Automatic broadcast of vitals and location to emergency contacts/services upon detecting critical heart rate anomalies.

## 🛠 Tech Stack

### Frontend & Mobile

* **Framework**: Flutter (Dart)
* **State Management**: Bloc/Cubit for reactive UI updates
* **Navigation**: GoRouter
* **Hardware Connectivity**: Bluetooth Low Energy (BLE)

### Backend & AI

* **Database & Auth**: Firebase Firestore & Authentication
* **AI Models**: XGBoost (Inference), Google Gemini (NLP)
* **Data Processing**: Python-based pipeline for nutritional data engineering

### Hardware

* **Microcontrollers**: ESP32 / Arduino Uno
* **Sensors**: MAX30102 Pulse Oximeter

## 🏗 System Architecture

The project follows a **Clean Architecture** pattern to maintain separation of concerns:

```text
lib/
├── core/                # Reusable widgets, services, and utilities
├── config/              # App themes and route definitions
├── features/            # Feature-driven modules
│   ├── analysis/        # ML risk assessment logic
│   ├── auth/            # Firebase auth & profile management
│   ├── chatbot/         # Gemini API integration
│   ├── device_connectivity/ # BLE communication protocols
│   ├── recipes/         # Nutritional database & filtering
│   └── reports/         # PDF parsing & health history
└── injection_container.dart # Dependency injection setup

```

## 📋 Getting Started

### Prerequisites

* Flutter SDK (v3.24.5 or higher)
* A Firebase project setup
* Google Gemini API Key

### Installation

1. **Clone the repository**:
```bash
git clone https://github.com/username/smart_vitals.git
cd smart_vitals

```


2. **Install dependencies**:
```bash
flutter pub get

```


3. **Setup Environment**:
Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective directories.
4. **Run the application**:
```bash
flutter run

```



## 👥 Contributors

**İzmir University of Economics - Senior Design Project Team:**

* **Özkan YILDIRIM**
* **Doğa ERDEM**
* **Barış ÖZDEMİR**
* **Alp KOÇAK**
* **Eren NEHROZOĞLU**
* **Kaan ÇAVDAR**

**Supervisor**: Okan YAMAN

---

*This project was developed as part of the FENG 497 Senior Project curriculum.*
