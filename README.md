# 💖 CUK Commit — From Campus to Forever

**CUK Commit** is a university-exclusive dating platform built for students of **Central University of Karnataka (CUK)**.  
It focuses on **real connections** — relationships, friendships, and meaningful campus interactions — rather than mindless swiping.

> 🎯 Goal: help students connect inside campus in a safe, verified, and structured way.

---

## ✨ Key Features

### 🔐 Authentication
- Email + Password login/signup
- **Email verification**
- **Forgot password / Reset password**
- **Google Sign-In (OAuth)** using Supabase

### 🧑‍🎓 Verified Campus Profiles
- Student identity-based user accounts
- Onboarding flow to complete profile
- User profile completion checks before discovery access

### 🧾 Onboarding Flow
- Profile Setup (name, gender, etc.)
- Photo Upload (min 2 photos, max 6)
- Interest selection
- Bio setup

### 📸 Photo Upload System
- Slot-based upload (6 grid fixed)
- Remove photo support
- Upload progress indicator per tile
- Powered by **Supabase Storage**

### ❤️ Matching / Discovery
- Discover page for browsing matches
- Profile-driven filtering readiness (future scope)

---

## 🧱 Tech Stack

### Frontend
- **Flutter**
- Provider (state management)
- Custom reusable UI widgets (TextFields, Buttons, Dropdowns)

### Backend
- **Supabase**
  - Supabase Auth
  - Supabase Database (`profiles` table etc.)
  - Supabase Storage (user photos)

---

## 🗂️ Project Structure

```bash
lib/
├── core/
│   ├── constants/
│   ├── routes/
│   ├── services/
│   └── widgets/
├── features/
│   ├── auth/
│   │   └── screens/
│   ├── onboarding/
│   │   ├── screens/
│   │   ├── providers/
│   │   └── repositories/
│   ├── matching/
│   │   └── screens/
│   └── splash/
│       └── screens/
├── auth_gate.dart
└── main.dart
```

---

## 🔄 App Flow (Routing Logic)

### 1) Splash → Welcome
- Checks if welcome was seen using SharedPreferences

### 2) Auth Gate
Handles correct routing based on auth + profile completion:

✅ Not logged in:
- Welcome screen (first time)
- Login screen

✅ Logged in:
- If profile incomplete → onboarding screens
- If profile completed → Discover screen

---

## 🔗 Deep Linking Support

The app supports mobile deep links for:

- Login callback:
  ```
  com.app.cukcommit://login-callback/
  ```

- Reset password:
  ```
  com.app.cukcommit://reset-password/
  ```

---

## 🚀 Setup Instructions

### 1) Clone the repo
```bash
git clone <your-repo-url>
cd cuk_commit
```

### 2) Install dependencies
```bash
flutter pub get
```

### 3) Configure environment variables

Create `.env`:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

### 4) Run the app
```bash
flutter run
```

---

## 🔑 Supabase Setup Checklist

### Auth Providers
- Enable Email Auth
- Enable Google OAuth

### Redirect URLs
Add these inside Supabase:
- `com.app.cukcommit://login-callback/`
- `com.app.cukcommit://reset-password/`

### Storage Bucket
Create bucket:
- `user-photos` (or whatever your code expects)

✅ Make sure bucket name matches your `SupabaseStorageService`.

---

## 📌 Security Notes

- No sensitive keys are committed
- Supabase keys are loaded using `.env`
- Session persistence is handled by Supabase Auth internally

---

## 🛠 Future Improvements (Planned)
- Match algorithm improvements
- Filters: department/year/interests
- Chat system (with moderation/reporting)
- Profile verification badge system
- Admin dashboard for moderation

---

## 📄 License

This project is **NOT open source**.

**All Rights Reserved.**  
No permission is granted to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of this software without explicit written permission.

---
## 👥 Team Members

| Profile | Name |
|--------|------|
| <img src="https://github.com/Uni-Creator.png" width="80" height="80" style="border-radius:50%"/> | **[Abhay Singh](https://github.com/Uni-Creator)** <br/> 
| <img src="https://github.com/Droid-DevX.png" width="80" height="80" style="border-radius:50%"/> | **[Ayush Tandon](https://github.com/Droid-DevX)** <br/>
| <img src="https://github.com/abhaydwived.png" width="80" height="80" style="border-radius:50%"/> | **[Abhay Dwivedi](https://github.com/abhaydwived)** <br/> 
---
