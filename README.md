<div align="center">

<img src="assets/images/logo.png" alt="Tripline Logo" width="120" height="120" style="border-radius: 24px"/>

# 🧭 Tripline

### *Your World. Your Way.*

**AI-Powered Travel Discovery & Smart Trip Planning Mobile Application**

<br/>

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Supabase](https://img.shields.io/badge/Supabase-Free_Tier-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![Groq](https://img.shields.io/badge/Groq-Llama_3.3_70B-F55036?style=for-the-badge&logo=meta&logoColor=white)](https://console.groq.com)
[![License](https://img.shields.io/badge/License-MIT-F59E0B?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-brightgreen?style=for-the-badge&logo=android&logoColor=white)](https://flutter.dev)

<br/>

> Discover world-class destinations, save your favorites, collaborate with travel buddies,
> track trip expenses, and let AI plan your perfect journey — all on **100% free services**.

<br/>

[✨ Features](#-features) &nbsp;•&nbsp;
[🛠️ Tech Stack](#️-tech-stack) &nbsp;•&nbsp;
[🚀 Getting Started](#-getting-started) &nbsp;•&nbsp;
[📁 Project Structure](#-project-structure) &nbsp;•&nbsp;
[🖥️ Web Admin Dashboard](#%EF%B8%8F-web-admin-dashboard) &nbsp;•&nbsp;
[👥 Team](#-team)

</div>

---

## 📖 About The Project

**Tripline** (formerly VistaVoyage) is a comprehensive, production-ready cross-platform travel application built with **Flutter** and **Supabase**. It empowers travelers to discover global destinations, create smart trip itineraries, track travel budgets/expenses, interact with a local Q&A board, and generate instant AI travel blueprints powered by **Groq Llama 3.3 70B**.

The application ecosystem consists of two key components:
1. **Tripline Mobile App**: Flutter mobile application for travelers.
2. **Tripline Web Admin Dashboard**: Flutter Web application for moderation, destination management, hidden gem approvals, and audit logging.

---

## ✨ Features

### 🔐 Authentication & Security
- Email & password registration with strong password enforcement (8+ chars, uppercase, digit).
- Supabase Authentication with persistent session auto-login.
- Client-side login lockout protection against brute-force attempts (5 failed attempts trigger lock).
- Admin privilege guard protecting moderation routes.

### 🌍 Destination Discovery & Interactive Features
- Paginated destination feed with live search & category filters (City, Mountain, Beach, Historic).
- **Travel Requirements Check**: Smart origin-to-destination visa check (includes automatic handling for domestic travel like Pakistan → Pakistan).
- **Audio Tour Guide**: Built-in audio guide narration for destination highlights.
- **Local Weather & Air Quality**: Real-time temperature, condition, and AQI snapshot.
- **Currency Converter**: Instant budget conversion (USD to PKR, EUR, GBP, JPY, AED, INR).

### 🧳 Trip Management & Collaboration
- **Trip Planner & Itinerary Builder**: Group destinations into custom trips.
- **Expense Tracking & Cost Splitting**: Track spending per trip with category breakdown and budget progress.
- **Digital Travel Journal**: Log notes and memory photos per trip stop, shareable via social apps.
- **Trip Buddy Matching**: Find fellow travelers visiting the same destination during matching date ranges.
- **QR Code Trip Sharing**: Export and import trips via instant QR code scanning.

### 🤖 AI Travel Blueprint & Assistants
- **AI Itinerary Generator**: Custom 3-day or multi-day trip blueprints powered by Groq Llama 3.3 70B.
- **Free-Form AI Travel Q&A**: Interactive chat assistant tailored to destination context.

### 👥 Community & Loyalty
- **Ask Locals Q&A Board**: Community board to post questions and receive local advice.
- **Community Hidden Gems**: User-submitted hidden spots (with admin moderation workflow).
- **Loyalty Rewards & Referrals**: Earn points for reviews and completing trips; unique referral links.

---

## 🛠️ Tech Stack

- **Framework**: Flutter 3.x (Dart 3.x)
- **Backend / Database**: Supabase (PostgreSQL + Auth + Row Level Security)
- **AI Integration**: Groq API (`llama-3.3-70b-versatile`)
- **State Management & Architecture**: Provider + Service Pattern
- **Local Storage / Caching**: Shared Preferences, `flutter_dotenv`
- **Push Notifications**: `flutter_local_notifications`
- **Maps & Geolocation**: `flutter_map` with CartoDB / OpenStreetMap tiles
- **Web Admin**: Flutter Web + `fl_chart` + `data_table_2`

---

## 📁 Project Structure

```text
VistaVoyage-Semester-Project-main/
├── android/                   # Native Android configuration (package: com.example.tripline)
├── assets/                    # Application logos and static assets
├── integration_test/          # Integration & regression tests
├── lib/                       # Main Flutter mobile app codebase
│   ├── l10n/                  # Localization files
│   ├── models/                # Data models (Destination, Review, etc.)
│   ├── screens/               # App screens (Home, Detail, Trip, AI, Settings, etc.)
│   ├── services/              # API & Data services (Supabase, Groq AI, Currency, etc.)
│   ├── theme/                 # App color system & providers
│   ├── utils/                 # Validators, toasts, result wrappers
│   └── widgets/               # Reusable UI components
├── test/                      # Unit & Widget tests
├── tripline_admin_dashboard/  # Flutter Web Admin Dashboard sub-project
├── pubspec.yaml               # Package definition (name: tripline)
├── README.md                  # Project documentation
└── data.md                    # Data architecture & reference documentation
```

---

## 🖥️ Web Admin Dashboard

The project includes a separate Flutter Web Admin Dashboard (`tripline_admin_dashboard/`) providing:
- **Moderation Queue**: Review and approve/reject user-submitted community Hidden Gems.
- **Destination Management**: Add and manage global destinations.
- **Audit Logging**: System audit log of admin activities.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.3.0`
- Android Studio / VS Code with Flutter extension

### Installation

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd VistaVoyage-Semester-Project-main
   ```

2. **Setup Environment Variables**:
   Create a `.env` file in the root directory:
   ```env
   SUPABASE_URL=https://your-supabase-url.supabase.co
   SUPABASE_ANON_KEY=your-supabase-anon-key
   GROQ_API_KEY=your-groq-api-key
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run Unit & Widget Tests**:
   ```bash
   flutter test
   ```

5. **Run the App**:
   ```bash
   flutter run
   ```

---

## 🚀 Ongoing Improvements & Future Enhancements

The project is actively being developed and enhanced. Planned roadmap items and continuous improvements include:

- 🔄 **Continuous UI/UX Polish**: Ongoing refinements to micro-animations, theme transitions, and responsive layouts across all screen sizes.
- ⚡ **Offline Data Syncing**: Enhancing local caching for offline itinerary edits with background cloud sync upon reconnection.
- 🤖 **Advanced AI Features**: Adding multi-day custom activity preferences, budget-constrained routing, and voice-assisted travel prompts.
- 🌐 **Expanded Localization**: Extending multi-language support (Urdu, French, Spanish) across all app flows.
- 📊 **Enhanced Admin Analytics**: Adding deeper user engagement charts and automated moderation tools in the Web Dashboard.

---

## 👥 Team

Built with ❤️ as a Semester Project.
