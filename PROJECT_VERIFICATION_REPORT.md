# VistaVoyage — Project Submission & Feature Verification Report

> **Repository:** [https://github.com/QaswarSarfrazcodes/Vista-Voyage-](https://github.com/QaswarSarfrazcodes/Vista-Voyage-)  
> **Evaluation Framework:** 28 Tasks (100 Points Total)

---

## 📋 Summary Overview

| Category | Total Tasks | Points | Status |
| :--- | :---: | :---: | :---: |
| **Code Implementation Links** | 10 | 40 pts | **AVAILABLE / COMPLETE (100%)** |
| **User Stories Document** | 1 | 9 pts | **AVAILABLE / UPDATED (100%)** |
| **GitHub Repository Link** | 1 | 2 pts | **READY & PUSHED (100%)** |
| **Screenshot Evidence** | 16 | 49 pts | **CHECKLIST CREATED (Requires captures)** |
| **TOTAL** | **28 Tasks** | **100 pts** | **13 Tasks Direct Code / 16 Evidence Slots** |

---

## 🔍 Detailed 28-Task Verification Checklist

### 1. Repository & Documentation (11 Points)

* **Task 1: GitHub Public Repository Link (2 Points)**
  * **Status:** `[AVAILABLE]`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-`
  * **Notes:** Repository initialized, main branch created, and code pushed to remote.

* **Task 2: User Stories Document (9 Points)**
  * **Status:** `[AVAILABLE & UPDATED]`
  * **File Path:** `user_stories.md`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/user_stories.md`
  * **Notes:** Includes all 9 required user stories with user role, feature goal, rationale, and acceptance criteria.

---

### 2. Figma UI Design Evidence (9 Points)

* **Task 3: Figma Screens 1 - Core Screens (5 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `figma-evidence1.png` or `figma-evidence1.jpg`
  * **Content Needed:** Screenshot featuring 5 Figma screens: Login, Registration, Home, Detail, and Favorites/Profile.
  * **Location in Project:** Save to `screenshots/figma-evidence1.png`

* **Task 4: Figma Screens 2 - Extended Features (4 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `figma-evidence2.png` or `figma-evidence2.jpg`
  * **Content Needed:** Screenshot featuring 4 Figma screens: External API Integration, Settings Menu, Settings Screen, and Notifications Screen.
  * **Location in Project:** Save to `screenshots/figma-evidence2.png`

---

### 3. Authentication Features (17 Points)

* **Task 5: Signup Code Implementation (4 Points)**
  * **Status:** `[AVAILABLE]`
  * **File Path:** `lib/screens/signup_screen.dart`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/signup_screen.dart`

* **Task 6: Signup Screen Evidence (6 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `signup_screen_evidence.png` or `.jpg`
  * **Content Needed:** Screenshot displaying Username, Email, Password fields, Sign-Up button, and Login link.

* **Task 7: Signup Error Evidence (2 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `signup_error.png` or `.jpg`
  * **Content Needed:** Screenshot showing error banner during registration attempt (e.g., existing email or weak password).

* **Task 8: Login Code Implementation (4 Points)**
  * **Status:** `[AVAILABLE]`
  * **File Path:** `lib/screens/login_screen.dart`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/login_screen.dart`

* **Task 9: Login Screen Evidence (5 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `login_screen_evidence.png` or `.jpg`
  * **Content Needed:** Screenshot displaying Email and Password fields, Sign In button, and Sign Up link.

* **Task 10: Login Error Evidence (2 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `login_error.png` or `.jpg`
  * **Content Needed:** Screenshot showing error message upon invalid login attempt.

---

### 4. Core App & Detail Navigation (16 Points)

* **Task 11: Home Screen Code Implementation (4 Points)**
  * **Status:** `[AVAILABLE]`
  * **File Path:** `lib/screens/home_screen.dart`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/home_screen.dart`

* **Task 12: Home Screen Evidence (4 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `home-screen-evidence.png` or `.jpg`
  * **Content Needed:** Screenshot of home screen layout showing destination cards and VistaVoyage logo in header.

* **Task 13: Detail Screen Code Implementation (4 Points)**
  * **Status:** `[AVAILABLE]`
  * **File Path:** `lib/screens/detail_screen.dart`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/detail_screen.dart`

* **Task 14: Detail Navigation Evidence (2 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `evidence-detail-navigation.png` or `.jpg`
  * **Content Needed:** Screenshot highlighting the navigation icon/card on the main screen that opens details.

* **Task 15: Detail Screen Layout Evidence (2 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `evidence-detail-screen.png` or `.jpg`
  * **Content Needed:** Screenshot of the detail screen displaying destination information, rating, budget, and description.

---

### 5. Local Storage & Data Persistence (8 Points)

* **Task 16: Local Storage / Favorites Code Implementation (4 Points)**
  * **Status:** `[AVAILABLE]`
  * **File Path:** `lib/services/supabase_data_service.dart`
  * **Secondary Reference:** `lib/screens/favorites_screen.dart`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/services/supabase_data_service.dart`

* **Task 17: Data Persistence Evidence (2 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `evidence-persistence.png` or `.jpg`
  * **Content Needed:** Screenshot demonstrating saved favorites stored in local storage / Supabase state.

* **Task 18: Integrated Persistence Evidence (2 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `evidence-integrateScreen-persistence.png` or `.jpg`
  * **Content Needed:** Screenshot displaying favorites both in the app front-end UI and reflected in local/cloud storage.

---

### 6. External API Integration (6 Points)

* **Task 19: API Integration Code Implementation (4 Points)**
  * **Status:** `[AVAILABLE]`
  * **File Path:** `lib/services/ai_service.dart`
  * **Secondary Reference:** `lib/screens/ai_screen.dart`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/services/ai_service.dart`

* **Task 20: API Integration UX Evidence (2 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `evidence-api-ux.png` or `.jpg`
  * **Content Needed:** Screenshot showing AI response (Groq API Llama 3.3 model output) displayed in the chat UI.

---

### 7. Settings Menu & Settings Screen (13 Points)

* **Task 21: Settings Menu Code Implementation (4 Points)**
  * **Status:** `[AVAILABLE]`
  * **File Path:** `lib/screens/settings_menu.dart`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/settings_menu.dart`

* **Task 22: Settings Menu Icon Evidence (2 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `evidence-menu-icon.png` or `.jpg`
  * **Content Needed:** Screenshot highlighting the settings gear icon in the app bar.

* **Task 23: Settings Menu Items Evidence (5 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `evidence-menu-items.png` or `.jpg`
  * **Content Needed:** Screenshot showing menu items inside the settings bottom sheet/page.

* **Task 24: Settings Screen Code Implementation (4 Points)**
  * **Status:** `[AVAILABLE]`
  * **File Path:** `lib/screens/settings_screen.dart`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/settings_screen.dart`

* **Task 25: Settings Screen Evidence (2 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `evidence-settings-screen.png` or `.jpg`
  * **Content Needed:** Screenshot displaying the full Settings screen with preference toggles and sections.

---

### 8. Push Notifications (10 Points)

* **Task 26: Push Notifications Code Implementation (4 Points)**
  * **Status:** `[AVAILABLE]`
  * **File Path:** `lib/services/notification_service.dart`
  * **Secondary Reference:** `lib/screens/notifications_screen.dart`
  * **Link to Submit:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/services/notification_service.dart`

* **Task 27: Notification Setup / Configuration Evidence (2 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `evidence-notification-configure.png` or `.jpg`
  * **Content Needed:** Screenshot showing notification permissions prompt or configuration card in the app.

* **Task 28: Test Notification Banner Evidence (4 Points)**
  * **Status:** `[PENDING SCREENSHOT]`
  * **Required Filename:** `evidence-notification-alert.png` or `.jpg`
  * **Content Needed:** Screenshot capturing active system push notification banner triggered by the app.

---

## 📌 Checklist of What Needs to Be Submitted for Submission Form

1. **Repo URL:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-`
2. **User Stories (.md):** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/user_stories.md`
3. **Signup Implementation Code Link:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/signup_screen.dart`
4. **Login Implementation Code Link:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/login_screen.dart`
5. **Home Screen Implementation Code Link:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/home_screen.dart`
6. **Detail Screen Implementation Code Link:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/detail_screen.dart`
7. **Local Storage Implementation Code Link:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/services/supabase_data_service.dart`
8. **API Integration Implementation Code Link:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/services/ai_service.dart`
9. **Settings Menu Implementation Code Link:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/settings_menu.dart`
10. **Settings Screen Implementation Code Link:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/screens/settings_screen.dart`
11. **Notifications Implementation Code Link:** `https://github.com/QaswarSarfrazcodes/Vista-Voyage-/blob/main/lib/services/notification_service.dart`
12. **16 Image Screenshots:** Saved in `screenshots/` directory with exact names listed in section above.
