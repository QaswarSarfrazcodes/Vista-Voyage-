# VistaVoyage — Nine User Stories

This document contains the required **nine user stories** mapping to each major feature of the VistaVoyage mobile application, satisfying **Task 2** of the semester project submission requirements.

---

### 1. Signup / Registration Feature
**User Story:**
* **As a** new user,
* **I want to** sign up by entering a username, email, and password,
* **So that** I can create an account and access personalized travel planning features.

**Acceptance Criteria:**
* Must request 3 fields: Username/Name, Email, and Password.
* Must include a "Create Account" or "Sign Up" button.
* Must show a link/button to navigate to the Login screen.
* Must handle errors (e.g., empty fields, invalid email format, weak passwords, or already registered email) and display them in a clear banner.

**Implementation File:** [`lib/screens/signup_screen.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/screens/signup_screen.dart)

---

### 2. Login Feature
**User Story:**
* **As a** returning user,
* **I want to** log in with my email and password,
* **So that** I can securely log back into my profile and retrieve my saved travel data.

**Acceptance Criteria:**
* Must request 2 fields: Email and Password.
* Must include a "Sign In" button.
* Must show a link to navigate to the Signup screen.
* Must handle credentials mismatch and connectivity errors by displaying a red error message.

**Implementation File:** [`lib/screens/login_screen.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/screens/login_screen.dart)

---

### 3. Home Screen browsing
**User Story:**
* **As a** user,
* **I want to** browse a beautifully structured home screen listing multiple travel destinations,
* **So that** I can discover and explore places to travel to.

**Acceptance Criteria:**
* Home screen shows a header/AppBar containing the VistaVoyage logo or branding.
* Displays a list of destination cards containing names, countries, ratings, and tags.
* Provides a functional search bar to query destinations by name or country.

**Implementation File:** [`lib/screens/home_screen.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/screens/home_screen.dart)

---

### 4. Detail Screen exploration
**User Story:**
* **As a** user,
* **I want to** tap on any destination card to open its dedicated detail screen,
* **So that** I can view complete details, ratings, highlights, budgets, and descriptions.

**Acceptance Criteria:**
* Tapping a card or a navigation icon on the Home screen successfully opens the Detail screen.
* Detail screen displays the destination's name, country, description, ratings out of 5.0, top highlights, best time to visit, and average daily budget.
* Provides back-navigation and options to save to favorites or prompt the AI travel guide.

**Implementation File:** [`lib/screens/detail_screen.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/screens/detail_screen.dart)

---

### 5. Local Storage / Favorites Persistence
**User Story:**
* **As a** user,
* **I want to** save destinations to my favorites list and have them persist locally or in the cloud,
* **So that** I can view and manage my saved itineraries anytime.

**Acceptance Criteria:**
* Tapping the heart icon on any detail page toggles favorite status.
* Favorites are stored and retrieved from local/cloud databases (Supabase).
* A dedicated Favorites screen displays all saved destinations, reflecting local storage state instantly.
* Supports swipe-to-dismiss to remove favorites.

**Implementation Files:** 
* [`lib/services/supabase_data_service.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/services/supabase_data_service.dart)
* [`lib/screens/favorites_screen.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/screens/favorites_screen.dart)

---

### 6. AI Assistant / API Integration
**User Story:**
* **As a** user,
* **I want to** ask the AI Travel Assistant to generate personalized itineraries for any destination,
* **So that** I can plan my trips with custom schedules, food recommendations, and budget tips.

**Acceptance Criteria:**
* Clicking "Ask AI for Itinerary" on a detail screen redirects to the AI Chat screen.
* Automatically sends an initial prompt generating a 3-day itinerary.
* Returns real-time responses fetched via the Groq API (Llama 3.3 70B / Llama 3 models).
* Offers quick-prompt chips for common questions and supports free-form user messages.

**Implementation Files:**
* [`lib/services/ai_service.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/services/ai_service.dart)
* [`lib/screens/ai_screen.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/screens/ai_screen.dart)

---

### 7. Settings Menu
**User Story:**
* **As a** user,
* **I want to** access a settings menu from the main screen,
* **So that** I can quickly navigate to different preference pages.

**Acceptance Criteria:**
* A settings gear/menu icon is visible in the Home screen AppBar.
* Tapping the icon displays a slide-up bottom sheet menu.
* Bottom sheet displays structured menu options (Profile, Notifications, App Settings, About, Help, Logout).

**Implementation File:** [`lib/screens/settings_menu.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/screens/settings_menu.dart)

---

### 8. Settings Screen
**User Story:**
* **As a** user,
* **I want to** open a dedicated Settings screen,
* **So that** I can configure my account, change appearance modes, or toggle notifications.

**Acceptance Criteria:**
* Accessible from the Settings Menu.
* Displays section headers (Account, Notifications, Appearance, About) and card tiles.
* Includes functional toggle switches for app preferences (notifications, travel reminders, dark mode).
* Provides a secure logout button that signs out of Supabase and navigates back to the Login screen.

**Implementation File:** [`lib/screens/settings_screen.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/screens/settings_screen.dart)

---

### 9. Push Notifications
**User Story:**
* **As a** user,
* **I want to** configure and receive push notifications on my device,
* **So that** I can get real-time travel alerts, daily destination recommendations, and system reminders.

**Acceptance Criteria:**
* Provides a card/toggle to request push notification permissions dynamically.
* Includes a "Send Test Notification" button that triggers a local push notification immediately.
* Displays triggered notifications as system banners at the top of the mobile device screen.

**Implementation Files:**
* [`lib/services/notification_service.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/services/notification_service.dart)
* [`lib/screens/notifications_screen.dart`](file:///c:/Users/hp/Downloads/VistaVoyage-Semester-Project-main/VistaVoyage-Semester-Project-main/lib/screens/notifications_screen.dart)
