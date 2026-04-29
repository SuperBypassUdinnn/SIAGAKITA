# 📋 SiagaKita — Laporan Kemajuan Pengembangan

> **Terakhir diperbarui:** 29 April 2026  
> **Branch aktif:** `frontend`  
> **Status keseluruhan:** 🟡 Dalam Pengembangan Aktif

---

## 🗂️ Daftar Isi

1. [Gambaran Arsitektur](#1-gambaran-arsitektur)
2. [Status Per Komponen](#2-status-per-komponen)
3. [Perubahan Sesi Terbaru](#3-perubahan-sesi-terbaru)
4. [Struktur File Terkini](#4-struktur-file-terkini)
5. [API Endpoint yang Tersedia](#5-api-endpoint-yang-tersedia)
6. [Schema Database — Perubahan & Status](#6-schema-database--perubahan--status)
7. [Yang Belum Selesai](#7-yang-belum-selesai)
8. [Panduan Setup untuk Anggota Baru](#8-panduan-setup-untuk-anggota-baru)

---

## 1. Gambaran Arsitektur

```
┌──────────────────────────────────────────────────────────────────┐
│                       SiagaKita System                           │
│                                                                  │
│  ┌─────────────────┐    REST/WS    ┌─────────────────────────┐  │
│  │  Mobile Flutter  │◄────────────►│   Go Fiber Backend       │  │
│  │  (Masyarakat &   │              │   Port :8080 (REST)      │  │
│  │   Relawan)       │              │   Port :8081 (WebSocket) │  │
│  └─────────────────┘              └────────────┬────────────┘  │
│                                                │                │
│  ┌─────────────────┐              ┌────────────▼────────────┐  │
│  │  Windows Console │              │   PostgreSQL             │  │
│  │  Flutter (Admin  │              │   (Data Permanen)        │  │
│  │  & Instansi)     │              └────────────┬────────────┘  │
│  └─────────────────┘                           │                │
│                                    ┌────────────▼────────────┐  │
│                                    │   Redis                  │  │
│                                    │   (OTP TTL, Rate Limit,  │  │
│                                    │    WS Hub State)         │  │
│                                    └─────────────────────────┘  │
└──────────────────────────────────────────────────────────────────┘
```

**Stack teknologi:**
| Layer | Teknologi |
|-------|-----------|
| Mobile | Flutter (Dart) |
| Desktop | Flutter Windows |
| Backend | Go 1.26 + Fiber v2 |
| Database | PostgreSQL 15 |
| Cache / Ephemeral | Redis |
| WA Gateway | Fonnte API |
| Email Gateway | SMTP (Gmail App Password) |
| GPS | geolocator + permission_handler |
| Container | Docker Compose |

---

## 2. Status Per Komponen

### 🟢 Backend — Go Fiber

| Domain | File | Status | Keterangan |
|--------|------|--------|-----------|
| Auth (User) | `domain/user/` | ✅ Selesai | Register → Email OTP → JWT; Login → JWT langsung |
| OTP | `domain/otp/` | ✅ Selesai | Dual-channel: Email (SMTP) + Phone (Fonnte WA) |
| Incident | `domain/incident/` | ✅ **Diperbarui** | TriggerSOS, CancelSOS, UpdateLocation, GetActive, Resolve |
| Telemetry | `domain/telemetry/` | ✅ Selesai | Location update, SMS fallback |
| WebSocket Hub | `internal/hub/` + `internal/ws/` | ✅ Selesai | Persistent connection registry |
| Middleware | `internal/middleware/` | ✅ Selesai | JWT Auth, API Key Gateway |

### 🟡 Mobile Flutter

| Layar | File | Status | Keterangan |
|-------|------|--------|-----------|
| Login | `auth/login_screen.dart` | ✅ **Diperbarui** | Single-step (Email+Password → JWT → HomeScreen) |
| Register | `auth/register_screen.dart` | ✅ **Diperbarui** | 2-step: Form → Email OTP; tanpa nomor HP di awal |
| Biodata | `auth/biodata_screen.dart` | 🟡 Sebagian | UI selesai; menerima accessToken/userId |
| Home (SOS) | `masyarakat/home_screen.dart` | ✅ **Diperbarui** | GPS tracking, active SOS state, cancel 5-tap |
| Main Screen | `masyarakat/main_screen.dart` | ✅ **Diperbarui** | Menerima accessToken/userId, pass ke HomeScreen |
| Edit Profil | `masyarakat/edit_profile_screen.dart` | 🟡 Sebagian | UI selesai, API belum terhubung |
| Pengaturan | `masyarakat/settings_screen.dart` | 🟡 Sebagian | UI selesai, API belum terhubung |
| Relawan Dashboard | `relawan/relawan_main_screen.dart` | 🟡 Sebagian | UI selesai, data masih mock |

### 🟢 Services Flutter (Baru)

| Service | File | Status | Keterangan |
|---------|------|--------|-----------|
| AuthService | `core/services/auth_service.dart` | ✅ Selesai | register, verifyRegisterOTP, login (→ JWT), verifyLoginOTP |
| IncidentService | `core/services/incident_service.dart` | ✅ Selesai | triggerSOS, cancelSOS, updateLocation, getActive |
| LocationService | `core/services/location_service.dart` | ✅ Selesai | requestPermission, getCurrentPosition, getCurrentPositionOrNull |

### 🔴 Belum Dimulai / Direncanakan

- Simpan JWT ke `flutter_secure_storage` (Token Management)
- Refresh token otomatis saat expired
- Integrasi WebSocket dari Flutter ke backend
- Dashboard Admin & Instansi (windows_console_flutter)
- Push notification / FCM

---

## 3. Perubahan Sesi Terbaru

### Sprint 1 — Infrastruktur & OTP Domain (26 Apr 2026)

- **`.gitignore`** — Diperbaiki, rules untuk Flutter build artifacts & credential files
- **OTP Domain** — Baru: `gateway.go`, `service.go`, `handler.go`; Redis-based dengan TTL 3 menit, cooldown 1 menit
- **Fonnte WA Gateway** — Normalisasi nomor 08xxx → 628xxx

---

### Sprint 2 — Email OTP & Alur Auth Baru (29 Apr 2026)

#### 🔵 Backend

**`user/model.go`** — Tambah kolom verifikasi:
```go
IsEmailVerified bool  `gorm:"default:false"`
IsPhoneVerified bool  `gorm:"default:false"`
```
Tambah DTO: `VerifyEmailOTPRequest`, `PhoneUpdateRequest`, `VerifyPhoneRequest`

**`user/repository.go`** — Tambah method:
- `SetEmailVerified(userID)` — tandai email terverifikasi
- `SetPhoneVerified(userID)` — tandai HP terverifikasi
- `UpdatePhoneNumber(userID, phone)` — simpan nomor HP, reset `is_phone_verified`
- `DeleteUserByEmail(email)` — hard delete untuk rollback jika OTP gagal

**`user/service.go`** — Alur baru:
- `Register()` → buat akun → kirim Email OTP → **rollback (hard delete) jika OTP gagal**
- `VerifyRegisterOTP()` → verifikasi OTP → tandai `is_email_verified = true` → return JWT
- `Login()` → validasi email+password → **langsung return JWT** (tanpa OTP step)
- `RequestPhoneVerification()` → simpan nomor HP → kirim OTP WA
- `ConfirmPhoneOTP()` → verifikasi OTP WA → tandai `is_phone_verified = true`

**`otp/service.go`** — Dual-channel:
- Email OTP: `RequestEmailOTP(ctx, email, purpose)` + `VerifyEmailOTP(ctx, email, purpose, code)`
- Phone OTP: `RequestOTP(ctx, phone)` + `VerifyOTP(ctx, phone, code)`

Redis key pattern:
```
otp:email:{purpose}:{email}       TTL 180s   ← kode Email OTP
otp_cooldown:email:{email}        TTL 60s    ← rate limit email
otp:phone:{phone}                 TTL 180s   ← kode WA OTP
otp_cooldown:phone:{phone}        TTL 60s    ← rate limit phone
```

**`otp/email_gateway.go`** — SMTP gateway (Gmail App Password):
```go
type SMTPEmailGateway struct { host, port, username, password, from string }
func (g *SMTPEmailGateway) SendOTP(to, purpose, code string) error { ... }
```

**`incident/model.go`** — Tambah:
- `TriggerMethod` di struct `Incident`
- DTO: `TriggerSOSRequest`, `UpdateLocationRequest`, `TriggerSOSResponse`, `ActiveIncidentResponse`

**`incident/repository.go`** — Tambah:
- `MarkCancelled(id)` — status → `false_alarm`
- `UpdateLocation(id, lat, lng)` — update koordinat
- `FindActiveByReporter(reporterID)` — cari SOS aktif milik user

**`incident/service.go`** — Tambah:
- `TriggerSOS(reporterID, req)` — buat incident, status `broadcasting`
- `CancelSOS(id, reporterID)` — validasi ownership → `MarkCancelled`
- `UpdateLocation(id, lat, lng)` — delegasi ke repo
- `GetActive(reporterID)` — cari incident aktif milik reporter

**`config.go`** — Tambah SMTP config:
```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=
SMTP_PASSWORD=         # Gmail App Password
SMTP_FROM=
```

**`cmd/api/main.go`** — Route baru:
```
POST /auth/verify-register-otp
GET  /incidents/active
POST /incidents/trigger
POST /incidents/:id/cancel
PUT  /incidents/:id/location
POST /users/phone/request-otp
POST /users/phone/verify-otp
```

#### 📱 Flutter

**`core/services/auth_service.dart`** — BARU:
| Method | Endpoint | Return |
|--------|----------|--------|
| `register()` | `POST /auth/register` | `String` (email) |
| `verifyRegisterOTP()` | `POST /auth/verify-register-otp` | `AuthResult` (JWT) |
| `login()` | `POST /auth/login` | `AuthResult` (JWT langsung) |
| `verifyLoginOTP()` | `POST /auth/verify-login-otp` | `AuthResult` (JWT) |

**`core/services/incident_service.dart`** — BARU:
| Method | Endpoint |
|--------|----------|
| `triggerSOS()` | `POST /incidents/trigger` |
| `cancelSOS()` | `POST /incidents/:id/cancel` |
| `updateLocation()` | `PUT /incidents/:id/location` (silent fail) |
| `getActive()` | `GET /incidents/active` |

**`core/services/location_service.dart`** — BARU:
- `requestPermission()` — minta izin + buka settings jika permanently denied
- `getCurrentPosition()` — ambil GPS dengan timeout 10s
- `getCurrentPositionOrNull()` — silent fail untuk background update

**`auth/login_screen.dart`** — Single-step (dihapus OTP step):
```
Email + Password → AuthService.login() → JWT → GPS Permission → HomeScreen
```

**`auth/register_screen.dart`** — 2-step (dihapus field nomor HP):
```
Step 0: Nama + Email + Password (strength bar) + Konfirmasi
Step 1: OTP 6 digit + resend cooldown 60 detik
→ GPS Permission → BiodataScreen
```

**`masyarakat/home_screen.dart`** — Rewrite penuh:
- `initState` → cek `GET /incidents/active` saat app dibuka
- Timer 1 menit → `PUT /incidents/:id/location` saat SOS aktif
- Tombol SOS berubah merah (teks **AKTIF**) saat incident aktif
- 5× tap saat SOS aktif → dialog konfirmasi **cancel** (hijau)
- `POST /incidents/:id/cancel` untuk membatalkan SOS
- Koordinat GPS diambil saat trigger SOS

**`masyarakat/main_screen.dart`** — Menerima `accessToken` + `userId`

**`core/router.dart`** — `getHomeByRole()` dan `navigateToHome()` menerima `accessToken` + `userId`

**`pubspec.yaml`** — Tambah dependencies:
```yaml
geolocator: ^13.0.2
permission_handler: ^11.4.0
```

**`AndroidManifest.xml`** — Tambah permission:
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
```

---

## 4. Struktur File Terkini

```
siagakita/
├── .gitignore                              ✅ Diperbaiki
├── backend-go/
│   ├── cmd/api/main.go                     ✅ Route & wiring diperbarui
│   └── internal/
│       ├── config/config.go                ✅ + SMTP config (5 field)
│       └── domain/
│           ├── incident/
│           │   ├── model.go                ✅ + TriggerMethod, DTO baru
│           │   ├── repository.go           ✅ + Cancel, UpdateLocation, FindActive
│           │   ├── service.go              ✅ + TriggerSOS, CancelSOS, UpdateLocation, GetActive
│           │   └── handler.go              ✅ + 4 endpoint baru
│           ├── otp/
│           │   ├── gateway.go              ✅ WA Fonnte interface
│           │   ├── email_gateway.go        🆕 SMTP Email gateway
│           │   ├── service.go              ✅ Dual-channel (WA + Email)
│           │   └── handler.go              ✅ request-otp, verify-otp
│           ├── telemetry/                  ✅ Selesai
│           └── user/
│               ├── model.go                ✅ + IsEmailVerified, IsPhoneVerified, DTO baru
│               ├── repository.go           ✅ + SetEmailVerified, SetPhoneVerified,
│               │                                UpdatePhoneNumber, DeleteUserByEmail
│               ├── service.go              ✅ Alur baru: Register+rollback, Login→JWT
│               └── handler.go              ✅ + verify-register-otp, verify-login-otp,
│                                                phone/request-otp, phone/verify-otp
├── infrastructure/
│   ├── .env                                ✅ (tidak di-track git)
│   ├── .env-example                        ✅ + SMTP template
│   └── docker-compose.yml                  ✅ service: backend (bukan api)
└── mobile-flutter/
    ├── pubspec.yaml                        ✅ + geolocator, permission_handler
    ├── android/app/src/main/
    │   └── AndroidManifest.xml             ✅ + GPS permissions
    └── lib/
        ├── core/
        │   ├── models/user_model.dart      ✅ Selesai
        │   ├── router.dart                 ✅ + accessToken/userId params
        │   └── services/
        │       ├── auth_service.dart       🆕 BARU — 4 method auth
        │       ├── incident_service.dart   🆕 BARU — SOS API client
        │       ├── location_service.dart   🆕 BARU — GPS wrapper
        │       └── otp_service.dart        ✅ WA OTP (legacy, masih dipakai di profile)
        └── features/
            ├── auth/
            │   ├── login_screen.dart       ✅ Single-step, GPS permission
            │   ├── register_screen.dart    ✅ 2-step Email OTP, tanpa HP di awal
            │   └── biodata_screen.dart     🟡 + accessToken/userId params
            └── masyarakat/
                ├── main_screen.dart        ✅ + accessToken/userId params
                ├── home_screen.dart        ✅ GPS tracking, active SOS, cancel 5-tap
                ├── edit_profile_screen.dart    🟡 UI selesai, API pending
                ├── settings_screen.dart        🟡 UI selesai
                └── volunteer_registration_screen.dart  🟡 UI selesai
```

---

## 5. API Endpoint yang Tersedia

Base URL: `http://<host>:8080/api/v1`

### Auth (Public — tidak butuh JWT)
| Method | Endpoint | Body | Keterangan |
|--------|----------|------|-----------|
| POST | `/auth/register` | `{full_name, email, password}` | Buat akun → kirim Email OTP |
| POST | `/auth/verify-register-otp` | `{email, otp_code}` | Verifikasi OTP → return JWT |
| POST | `/auth/login` | `{email, password}` | Validasi → **return JWT langsung** |
| POST | `/auth/verify-login-otp` | `{email, otp_code}` | *(Ada tapi tidak dipakai di login flow saat ini)* |
| POST | `/auth/request-otp` | `{phone_number}` | Kirim OTP WA (Fonnte), rate limit 60s |
| POST | `/auth/verify-otp` | `{phone_number, otp_code}` | Verifikasi OTP WA |

### Users (Protected — butuh `Authorization: Bearer <token>`)
| Method | Endpoint | Keterangan |
|--------|----------|-----------|
| GET | `/users/profile` | Ambil profil lengkap (termasuk is_email_verified, is_phone_verified) |
| POST | `/users/biodata` | Simpan biodata (transaksi atomik) |
| POST | `/users/phone/request-otp` | Simpan nomor HP + kirim OTP WA untuk verifikasi |
| POST | `/users/phone/verify-otp` | `{phone_number, otp_code}` → is_phone_verified = true |

### Incidents (Protected)
| Method | Endpoint | Body | Keterangan |
|--------|----------|------|-----------|
| GET | `/incidents/active` | — | Cek SOS aktif milik user login |
| POST | `/incidents/trigger` | `{latitude, longitude, trigger_method, incident_type?, address_detail?}` | Kirim SOS |
| POST | `/incidents/:id/cancel` | — | Batalkan SOS (status → false_alarm) |
| PUT | `/incidents/:id/location` | `{latitude, longitude}` | Update koordinat GPS (tiap 1 menit) |
| POST | `/incidents/:id/resolve` | — | Tandai insiden selesai (oleh relawan/instansi) |

### Telemetry (Protected)
| Method | Endpoint | Keterangan |
|--------|----------|-----------|
| PUT | `/telemetry/location` | Update lokasi real-time via WebSocket hub |

### WebSocket
| URL | Keterangan |
|-----|-----------|
| `ws://<host>:8081/ws/connect` | Persistent connection untuk SOS events |

---

## 6. Schema Database — Perubahan & Status

| Tabel | Status | Keterangan |
|-------|--------|-----------|
| `users` | ✅ + kolom baru | + `is_email_verified BOOLEAN DEFAULT false` |
| | | + `is_phone_verified BOOLEAN DEFAULT false` |
| | | `role` default diubah ke `'civilian'` |
| | | `phone_number` → nullable (diisi lewat profile) |
| `user_medical_profiles` | ✅ | Golongan darah, alergi, riwayat penyakit |
| `emergency_contacts` | ✅ | Kontak darurat |
| `incidents` | ✅ + kolom baru | + `trigger_method VARCHAR(20) DEFAULT 'timeout'` |
| `incident_responses` | ✅ | Respons relawan/instansi |
| `volunteer_certifications` | ✅ | Sertifikat relawan |
| `m_ranks` | ✅ | Master data rank/level relawan |

> ⚠️ **Jalankan SQL berikut secara manual di database yang sudah berjalan:**
> ```sql
> -- Kolom verifikasi
> ALTER TABLE public.users
>   ADD COLUMN IF NOT EXISTS is_email_verified BOOLEAN NOT NULL DEFAULT false,
>   ADD COLUMN IF NOT EXISTS is_phone_verified  BOOLEAN NOT NULL DEFAULT false;
>
> -- Nomor HP jadi nullable (diisi via profile)
> ALTER TABLE public.users
>   ALTER COLUMN phone_number DROP NOT NULL;
>
> -- Kolom trigger_method di incidents
> ALTER TABLE public.incidents
>   ADD COLUMN IF NOT EXISTS trigger_method VARCHAR(20) NOT NULL DEFAULT 'timeout';
> ```

**Enum yang digunakan:**
```sql
user_role:          civilian | volunteer | agency_responder | admin
incident_status:    grace_period | broadcasting | handled | resolved | false_alarm
response_status:    en_route | on_scene | completed | canceled
cert_status:        pending | approved | rejected
```

---

## 7. Yang Belum Selesai

### Prioritas Tinggi (Sprint Berikutnya)
- [ ] **Token Management:** Simpan `access_token` + `refresh_token` ke `flutter_secure_storage`
- [ ] **Interceptor HTTP:** Attach JWT otomatis ke semua request, handle 401 → refresh
- [ ] **BiodataScreen → API:** Wire `POST /users/biodata`
- [ ] **ProfileScreen → API:** Wire `GET /users/profile`, tampilkan `is_email_verified`, `is_phone_verified`
- [ ] **Phone Verification UI:** Form verifikasi nomor HP di profile screen (kirim OTP WA → konfirmasi)

### Prioritas Sedang
- [ ] **WebSocket Flutter:** Koneksi `wss://host:8081/ws/connect` saat app dibuka
- [ ] **SOS dispatch via WebSocket:** Kirim `TRIGGER_SOS` event sehingga relawan menerima notifikasi real-time
- [ ] **Relawan dashboard:** Ganti data mock dengan data dari API
- [ ] **Edit Profile → API:** Wire form ke `PUT /users/profile`
- [ ] **Refresh token:** Auto-refresh saat `access_token` expired

### Prioritas Rendah / Masa Depan
- [ ] Push notification (FCM) untuk alert darurat
- [ ] Dashboard Admin & Instansi (Windows Flutter)
- [ ] Status verifikasi KTP (admin dapat lihat flag di incident reporter)
- [ ] Riwayat insiden per pengguna

---

## 8. Panduan Setup untuk Anggota Baru

### Prasyarat
```bash
go version    # Go 1.26+
flutter --version   # Flutter 3.x+
docker --version && docker compose version
```

### Langkah Setup

**1. Clone repository:**
```bash
git clone https://github.com/SuperBypassUdinnn/siagakita.git
cd siagakita
git checkout frontend
```

**2. Buat file environment:**
```bash
cp infrastructure/.env-example infrastructure/.env
# Edit .env dan isi:
# DB_USER, DB_PASSWORD, DB_NAME
# REDIS_PASSWORD
# JWT_SECRET (string acak panjang)
# FONNTE_TOKEN (daftar di fonnte.com)
# SMTP_HOST, SMTP_PORT, SMTP_USERNAME, SMTP_PASSWORD, SMTP_FROM
#   → Untuk Gmail: buat App Password di myaccount.google.com/apppasswords
```

**3. Jalankan infrastruktur:**
```bash
sudo docker compose -f infrastructure/docker-compose.yml up -d postgres redis pgadmin
```

**4. Jalankan migrasi database:**
```bash
sudo docker exec -i siagakita_postgres psql \
  -U siagakita_admin -d siagakita \
  < backend-go/migrations/001_init_schema.sql

# Lalu jalankan ALTER TABLE manual (lihat section 6)
```

**5. Build dan jalankan backend:**
```bash
# Development (langsung)
cd backend-go
go run ./cmd/api/

# Atau via Docker (nama service adalah "backend", bukan "api")
sudo docker compose -f infrastructure/docker-compose.yml up --build -d backend
```

**6. Jalankan Flutter mobile:**
```bash
cd mobile-flutter
flutter pub get
flutter run
```

### Cara Akses
| Layanan | URL |
|---------|-----|
| REST API | `http://localhost:8080` |
| Health Check | `http://localhost:8080/health` |
| WebSocket | `ws://localhost:8081/ws/connect` |
| pgAdmin | `http://localhost:5050` |

### Catatan Emulator Android
Flutter emulator menggunakan `10.0.2.2` untuk mengakses `localhost` host machine. Semua `_baseUrl` di service files sudah dikonfigurasi ke `http://10.0.2.2:8080/api/v1`.

### Catatan Alur Auth Terbaru
```
REGISTER:                              LOGIN:
Nama + Email + Password                Email + Password
  ↓ POST /auth/register                  ↓ POST /auth/login
  Kirim OTP ke email                     JWT langsung (tanpa OTP)
  ↓ POST /auth/verify-register-otp         ↓
  JWT + Minta izin GPS                   Minta izin GPS
  ↓                                      ↓
  BiodataScreen                          HomeScreen

VERIFIKASI HP (di Profile setelah login):
  Isi nomor HP → POST /users/phone/request-otp → OTP via WA
  Masukkan OTP → POST /users/phone/verify-otp → is_phone_verified = true
```

---

> 💬 **Pertanyaan?** Hubungi @SuperBypassUdinnn atau buat issue di repository.
