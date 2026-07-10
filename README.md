# ⚔️ TaskQuest — RPG Task Manager for Students

> *Selesaikan tugasmu, naiki level-mu.*

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Supabase-Cloud-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" />
</p>

---

## 🎓 Identitas Project

| Info | Detail |
|------|--------|
| **Nama Aplikasi** | TaskQuest |
| **Mata Kuliah** | Pemrograman Piranti Bergerak (TI253311) |
| **Program Studi** | Teknologi Informasi |
| **Semester** | IV — 2025/2026 |
| **Kelompok** | 03 |
| **Platform** | Flutter → Android |

### 👥 Anggota Kelompok

| Nama | NIM | Tanggung Jawab |
|------|-----|----------------|
| I Gusti Ngurah Agung Pradnaya Asmara Kusuma | *(240040043)* | Backend, CRUD SQLite, Supabase Cloud, Kamera, OpenStreetMap, API Service, Auth & Session |
| Orang B (Raditya) | *(NIM)* | UI/UX, Navigasi, State Management (Provider), Gamification (XP/Level), Sensor Gyroscope/Compass |

---

## 📖 Deskripsi Aplikasi

**TaskQuest** adalah aplikasi manajemen tugas harian berbasis **RPG (Role-Playing Game)** yang dirancang khusus untuk mahasiswa. Aplikasi ini mengubah rutinitas mengerjakan tugas menjadi petualangan yang menyenangkan — setiap tugas yang diselesaikan memberikan **XP (Experience Points)**, karakter RPG milik pengguna naik level, dan animasi level-up yang responsif terhadap orientasi fisik perangkat (gyroscope/compass) akan muncul sebagai reward visual.

---

## 🚨 Permasalahan

Mahasiswa sering kali kesulitan memotivasi diri untuk menyelesaikan tugas tepat waktu. Aplikasi to-do list biasa terasa membosankan dan tidak memberikan reward instan yang memuaskan. Akibatnya:

- Tugas sering ditunda hingga mendekati atau melewati deadline.
- Tidak ada rasa pencapaian yang konkret setelah menyelesaikan tugas.
- Sulit memantau produktivitas belajar secara visual.
- Tidak ada elemen sosial/kompetisi yang mendorong konsistensi.

---

## 💡 Solusi

TaskQuest menawarkan pendekatan **gamifikasi tugas akademik**:

1. **Sistem XP & Leveling** — Setiap tugas yang diselesaikan memberi XP. Tugas yang dikerjakan tepat waktu atau bahkan lebih cepat mendapat bonus multiplier (hingga **1.5× "Clutch Bonus"**).
2. **Karakter RPG Personal** — Pengguna memilih kelas karakter (Ksatria / Mage / Archer) yang berkembang secara visual (5 tahap penampilan) seiring kenaikan level.
3. **Animasi Interaktif** — Animasi level-up bereaksi terhadap kemiringan dan orientasi HP menggunakan sensor **Gyroscope/Compass**, membuat momen pencapaian terasa nyata.
4. **Leaderboard Cloud** — Progres disinkronkan ke Supabase untuk fitur leaderboard antar mahasiswa, mendorong kompetisi sehat.
5. **Bukti Penyelesaian Tugas** — Integrasi kamera untuk mengambil foto sebagai bukti tugas selesai.
6. **Peta Lokasi Belajar** — OpenStreetMap untuk mencatat dan berbagi lokasi belajar/tempat konsultasi favorit.
7. **Quotes Motivasi** — Integrasi API eksternal untuk menampilkan kutipan motivasi sebagai quest template.

---

## ✨ Fitur Aplikasi

### Fitur Utama (Wajib)
| Fitur | Deskripsi |
|-------|-----------|
| 🔐 **Login & Logout** | Autentikasi via Supabase + session disimpan di SharedPreferences |
| 📋 **CRUD Tugas** | Buat, lihat, edit, hapus tugas dengan kategori & prioritas |
| 🗺️ **Navigasi Multi-Halaman** | Login → Dashboard → Daftar Quest → Detail Quest → Profil |
| 📷 **Kamera** | Foto bukti penyelesaian tugas langsung dari aplikasi |
| 🗺️ **OpenStreetMap** | Tampilkan peta & lokasi pengguna; catat lokasi belajar favorit |
| 🧭 **Sensor Gyroscope/Compass** | Animasi partikel level-up reaktif terhadap orientasi HP |
| 🌐 **API Motivasi** | Quotes motivasi & quest template dari API publik |
| ☁️ **Cloud Database (Supabase)** | Sinkronisasi progres, XP log, leaderboard real-time |

### Fitur Gamifikasi (RPG)
| Fitur | Deskripsi |
|-------|-----------|
| ⚔️ **Pemilihan Kelas** | Knight, Mage, Archer — masing-masing dengan visual unik |
| ✨ **Sistem XP** | XP dihitung dari prioritas tugas × urgency multiplier |
| 📈 **Level-Up** | Formula: `XP threshold = 100 × level^1.3` |
| 🎭 **Appearance Stage** | Tampilan karakter berubah setiap kelipatan 5 level (hingga 5 tahap) |
| 🏆 **Leaderboard** | Peringkat XP antar mahasiswa secara real-time |
| 🎖️ **Character Items** | Unlock senjata, badge, dan outfit berdasarkan pencapaian |

### Kalkulasi XP
```
Base XP (saat task dibuat):
  Low Priority    = 10 XP
  Medium Priority = 20 XP
  High Priority   = 35 XP

Urgency Multiplier (saat task diselesaikan):
  Selesai > 3 hari sebelum deadline   = 1.0×
  Selesai 1–3 hari sebelum deadline   = 1.2×
  Selesai tepat di hari deadline       = 1.5× 🔥 Clutch Bonus!
  Selesai setelah deadline             = 0.5×
```

---

## 🏗️ Arsitektur Aplikasi

Proyek ini menggunakan **Clean Architecture** dengan pemisahan layer yang ketat:

```
lib/
│
├── main.dart
│
├── core/                    # Shared utilities
│   ├── constants/
│   ├── errors/              # Failure & Exception classes
│   ├── utils/
│   └── theme/               # AppTheme, AppColors (Crail Terracotta palette)
│
├── data/                    # Implementasi konkret (terluar)
│   ├── datasources/
│   │   ├── local/           # SQLite (sqflite), SharedPreferences
│   │   └── remote/          # Supabase, REST API
│   ├── models/              # DTO — extends entity, punya fromJson/toJson
│   └── repositories/        # Implementasi interface dari domain
│
├── domain/                  # Business logic murni (pure Dart)
│   ├── entities/            # Task, Character, User, XpLog, StudyLocation
│   ├── repositories/        # Abstract interface / contract
│   └── usecases/            # Satu file = satu use case
│       ├── CalculateXpUseCase
│       ├── LevelUpUseCase
│       ├── CompleteTaskUseCase
│       └── ...
│
└── presentation/            # Layer UI
    ├── screens/             # Login, Dashboard, TaskList, TaskDetail, Profile
    ├── widgets/             # Reusable widgets (RPG card, XP bar, dll)
    ├── providers/           # State management (Provider)
    └── navigation/          # go_router — AppRouter
```

---

## 🗄️ Database Schema

### Tabel Utama

| Tabel | Lokasi | Keterangan |
|-------|--------|-----------|
| `users` | ☁️ Cloud (Supabase) | Data akun pengguna |
| `characters` | ☁️ Cloud (Supabase) | Karakter RPG & progres level |
| `tasks` | 📱 SQLite (offline-first) + ☁️ Cloud | Data tugas, disinkronkan ke cloud |
| `xp_logs` | ☁️ Cloud (Supabase) | Histori perolehan XP & leaderboard |
| `character_items` | ☁️ Cloud (Supabase) | Item/badge/outfit yang di-unlock |
| `study_locations` | 📱 SQLite | Lokasi belajar favorit (personal) |

**Session login** (`user_id`, `username`, `is_logged_in`) disimpan di **SharedPreferences**.

---

## 🎨 Design System

Tampilan TaskQuest terinspirasi dari estetika **warm & calm** dengan palet warna:

| Token | Warna | Kegunaan |
|-------|-------|---------|
| Crail Terracotta | `#C15F3C` | Aksen utama — tombol, highlight |
| Cream | `#F4F3EE` | Background utama |
| Warm White | `#FAF9F5` | Background kartu/panel |
| Charcoal | `#2D2B26` | Teks utama |
| Warm Gray | `#6B6862` | Teks sekunder, caption |

**Font:** Inter / Public Sans — ukuran dasar 16px, line-height 1.6

---

## 🛠️ Teknologi yang Digunakan

| Teknologi | Versi | Kegunaan |
|-----------|-------|---------|
| **Flutter** | ≥3.x | Framework mobile utama |
| **Dart** | ^3.12.2 | Bahasa pemrograman |
| **Supabase** | ^2.15.4 | Cloud database & autentikasi |
| **sqflite** | ^2.4.3 | Local database SQLite (offline-first) |
| **shared_preferences** | ^2.5.5 | Penyimpanan session login |
| **go_router** | ^17.3.0 | Navigasi multi-halaman |
| **provider** | ^6.1.5 | State management |
| **sensors_plus** | ^7.1.0 | Sensor Gyroscope & Compass |
| **image_picker** | ^1.2.3 | Integrasi kamera |
| **flutter_map** | ^8.3.1 | Tampilan peta OpenStreetMap |
| **latlong2** | ^0.10.1 | Koordinat geografis |
| **geolocator** | ^14.0.3 | Lokasi pengguna real-time |
| **http** | ^1.6.0 | HTTP client untuk API quotes |
| **uuid** | ^4.5.3 | Generate UUID untuk primary key |

---

## 🚀 Cara Instalasi & Menjalankan

### Prasyarat
- Flutter SDK ≥ 3.x terinstall ([panduan instalasi](https://docs.flutter.dev/get-started/install))
- Android Studio / VS Code
- Perangkat Android (API 21+) atau emulator
- Akun Supabase (untuk konfigurasi cloud)

### Langkah Instalasi

```bash
# 1. Clone repository
git clone https://github.com/<username>/PPB2026_Kelompok03_TaskQuest.git
cd PPB2026_Kelompok03_TaskQuest

# 2. Install dependencies
flutter pub get

# 3. Konfigurasi Supabase
# Buat file lib/core/constants/supabase_config.dart dan isi dengan:
# const supabaseUrl = 'YOUR_SUPABASE_URL';
# const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

# 4. Jalankan di device/emulator
flutter run

# 5. (Opsional) Build APK debug
flutter build apk --debug
```

### Konfigurasi Supabase
1. Buat project baru di [supabase.com](https://supabase.com)
2. Jalankan script SQL dari file `supabase_schema.sql` di SQL Editor Supabase
3. Salin URL & anon key dari **Project Settings → API**
4. Masukkan ke konfigurasi aplikasi

---

## 📁 Struktur Repository

```
PPB2026_Kelompok03_TaskQuest/
├── lib/                    # Source code utama Flutter
│   ├── core/
│   ├── data/
│   ├── domain/
│   ├── presentation/
│   └── main.dart
├── assets/
│   └── images/characters/  # Sprite karakter RPG
├── supabase/               # Konfigurasi Supabase
├── supabase_schema.sql     # Script DDL database
├── test/                   # Unit test & widget test
├── android/                # Konfigurasi platform Android
├── pubspec.yaml            # Dependency Flutter
└── README.md
```

---

## 📋 Pembagian Tugas

| Nama | NIM | Tanggung Jawab Detail |
|------|-----|-----------------------|
| **Orang A** | *(NIM)* | Data Layer (SQLite + Supabase), autentikasi & session, CRUD task datasource, integrasi kamera, OpenStreetMap & lokasi, API quotes motivasi, schema database, sinkronisasi offline↔cloud |
| **Orang B (Raditya)** | *(NIM)* | Presentation Layer (semua halaman UI), navigasi go_router, state management Provider, gamification use case (CalculateXpUseCase, LevelUpUseCase), animasi level-up, integrasi sensor Gyroscope/Compass, design system & theming |

---

## 📄 Dokumen Pengumpulan

| Dokumen | Format | Nama File |
|---------|--------|-----------|
| Laporan Project | PDF | `PPB2026_Kelompok03_Laporan.pdf` |
| Installer Aplikasi | APK | `PPB2026_Kelompok03.apk` |
| Link Repository | URL | *(link GitHub ini)* |

---

## 📝 Conventional Commits

Project ini menggunakan format **Conventional Commits**:

```
feat(task): tambah use case CompleteTaskUseCase
fix(auth): perbaiki session tidak tersimpan setelah login
refactor(character): pisah logika XP ke CalculateXpUseCase
test(domain): tambah unit test untuk LevelUpUseCase
docs(readme): update cara instalasi
chore(deps): tambah package sensors_plus untuk gyroscope
```

---
