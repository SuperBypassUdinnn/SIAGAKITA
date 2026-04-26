# 📋 SiagaKita — Laporan Kemajuan Pengembangan

> **Terakhir diperbarui:** 26 April 2026  
> **Branch aktif:** `frontend`  
> **Status keseluruhan:** 🟡 Dalam Pengembangan Aktif

---

## 🗂️ Daftar Isi

1. [Gambaran Arsitektur](#1-gambaran-arsitektur)
2. [Status Per Komponen](#2-status-per-komponen)
3. [Perubahan Sesi Ini (Refactoring Sprint)](#3-perubahan-sesi-ini-refactoring-sprint)
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
│                                    │   (OTP TTL, Session,     │  │
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
| Container | Docker Compose |

---

## 2. Status Per Komponen

### 🟢 Backend — Go Fiber

| Domain | File | Status | Keterangan |
|--------|------|--------|-----------|
| Auth (User) | `domain/user/` | ✅ Selesai | Register, Login, JWT |
| OTP | `domain/otp/` | ✅ **Baru** | Request + Verify via Fonnte WA |
| Incident | `domain/incident/` | ✅ Selesai | CRUD + Resolve |
| Telemetry | `domain/telemetry/` | ✅ Selesai | Location update, SMS fallback |
| WebSocket Hub | `internal/hub/` + `internal/ws/` | ✅ Selesai | Persistent connection registry |
| Middleware | `internal/middleware/` | ✅ Selesai | JWT Auth, API Key Gateway |

### 🟡 Mobile Flutter

| Layar | File | Status | Keterangan |
|-------|------|--------|-----------|
| Login | `auth/login_screen.dart` | ✅ **Diperbarui** | Form baru, validasi, reset state |
| Register | `auth/register_screen.dart` | ✅ **Diperbarui** | 4-step flow, OTP nyata, strength bar |
| Biodata | `auth/biodata_screen.dart` | 🟡 Sebagian | UI selesai, API belum terhubung |
| Home (SOS) | `masyarakat/home_screen.dart` | ✅ **Diperbarui** | Mekanisme 5-ketukan baru |
| Edit Profil | `masyarakat/edit_profile_screen.dart` | 🟡 Sebagian | UI selesai, API belum terhubung |
| Pengaturan | `masyarakat/settings_screen.dart` | 🟡 Sebagian | UI selesai, API belum terhubung |
| Relawan Dashboard | `relawan/relawan_main_screen.dart` | 🟡 Sebagian | UI selesai, data masih mock |
| Registrasi Relawan | `masyarakat/volunteer_registration_screen.dart` | 🟡 Sebagian | UI selesai, API belum terhubung |

### 🔴 Belum Dimulai / Direncanakan

- Integrasi WebSocket dari Flutter ke backend
- Service layer `AuthService` (login/register → API)
- `ProfileService`, `BiodataService`
- Dashboard Admin & Instansi (windows_console_flutter)
- Push notification / FCM

---

## 3. Perubahan Sesi Ini (Refactoring Sprint)

### 🗃️ Repository & Infrastruktur

- **`.gitignore`** — Diperbaiki dari conflict markers. Ditambahkan rules untuk:
  - Flutter build artifacts (`build/`, `.dart_tool/`, `.flutter-plugins`, dll.)
  - Credential files (`.env`, `*.keystore`)
- **`infrastructure/.env-example`** — Ditambahkan template untuk:
  ```env
  FONNTE_TOKEN=          # Token WhatsApp Gateway Fonnte
  ```

### 🗄️ Database (001_init_schema.sql)

> ⚠️ **Penting untuk tim backend:** Jalankan SQL di bawah secara manual ke DB yang sudah berjalan (jangan re-run migration dari awal kecuali fresh install).

**Perubahan 1 — Kolom baru `trigger_method` di tabel `incidents`:**
```sql
ALTER TABLE public.incidents
  ADD COLUMN trigger_method character varying(20) NOT NULL DEFAULT 'timeout';
```
Tujuan: Audit apakah SOS dikirim karena user menekan tombol (`'user'`) atau otomatis karena konfirmasi habis (`'timeout'`).

**Perubahan 2 — Field registrasi dijadikan nullable:**
```sql
ALTER TABLE public.users
  ALTER COLUMN nik DROP NOT NULL,
  ALTER COLUMN date_of_birth DROP NOT NULL;
-- phone_number TETAP NOT NULL (wajib untuk OTP)
```
Tujuan: NIK dan tanggal lahir bisa dilengkapi nanti di halaman profil/biodata.

**Idempotency guards:** Ditambahkan `DROP TYPE IF EXISTS ... CASCADE` / `RESTRICT` sebelum setiap CREATE TYPE untuk mencegah error saat migration dijalankan ulang.

> **User role TIDAK berubah:** Nilai enum tetap `civilian`, `volunteer`, `agency_responder`, `admin`.

---

### 🔵 Backend — OTP Domain (BARU)

Tiga file baru di `backend-go/internal/domain/otp/`:

#### `gateway.go` — WhatsApp Gateway Interface + Fonnte Implementation
```go
type Gateway interface {
    Send(phone, message string) error
}
// Implementasi: fonnteGateway → POST https://api.fonnte.com/send
// Normalisasi nomor: 08xxx → 628xxx, +628xxx → 628xxx
```

#### `service.go` — Logika Bisnis OTP
```go
type Service interface {
    RequestOTP(ctx context.Context, phone string) error
    VerifyOTP(ctx context.Context, phone, code string) error
}
```
Mekanisme:
- **Request:** Cek cooldown Redis → generate 6 digit → simpan ke Redis (TTL 3 menit) → set cooldown 1 menit → kirim WA → rollback Redis jika kirim gagal
- **Verify:** Ambil dari Redis → bandingkan → hapus (anti-replay) → error jika TTL habis

Redis key pattern:
```
otp:register:{phone}     TTL 180s  ← kode OTP
otp_cooldown:{phone}     TTL 60s   ← rate limit
```

#### `handler.go` — HTTP Handler
| Method | Endpoint | Body | Response |
|--------|----------|------|----------|
| POST | `/api/v1/auth/request-otp` | `{ "phone_number": "08xxx" }` | `200 OK` / `429 Rate Limit` / `500` |
| POST | `/api/v1/auth/verify-otp` | `{ "phone_number": "08xxx", "otp_code": "123456" }` | `200 OK { verified: true }` / `400` |

#### Perubahan ke `config.go` dan `main.go`
- `config.go`: Ditambahkan field `FonnteToken string`, membaca `FONNTE_TOKEN` dari env
- `main.go`: OTP domain di-wire (gateway → service → handler → routes)

---

### 📱 Flutter — Mobile

#### `login_screen.dart` — Diperbarui Total
- **Fix:** Error validation tidak lagi melebarkan kotak form (pindah dari `Container` wrapper ke `InputDecoration` langsung dengan `enabledBorder` / `focusedBorder` / `errorBorder`)
- **Fix:** Error validasi direset saat kembali dari halaman Register (`.then(() => _formKey.currentState?.reset())`)
- Validasi: email format (`RegExp`), password wajib isi

#### `register_screen.dart` — Diperbarui Total
**Dihapus:**
- Field `Username` (tidak diperlukan)
- Field `Nomor KTP` (wajib → opsional, dipindah ke halaman profil)
- Mock role selector

**Ditambahkan:**
- 4-step registration flow: **Form → OTP → Foto KTP (opsional) → Selfie**
- Validasi ketat:
  - Nama: tidak boleh kosong
  - Nomor HP: format Indonesia (08xxx / 628xxx / +628xxx), min 10 digit
  - Email: format regex
  - Password: min 8 karakter + huruf besar + angka + simbol
  - Konfirmasi password: harus cocok
- **Password Strength Bar** — 3 segmen animasi real-time:
  - 🔴 Merah = Lemah (hanya penuhi 1 syarat)
  - 🟠 Oranye = Sedang (penuhi 2 syarat)
  - 🟢 Hijau = Kuat ✓ (penuhi semua syarat)
- **Integrasi OTP nyata** via `OTPService` → backend Fonnte
- Loading spinner di tombol saat request berlangsung
- OTP resend cooldown 60 detik (countdown ditampilkan di tombol)

#### `home_screen.dart` (SOS) — Diperbarui Total
**Mekanisme SOS lama (hold 10 detik)** → **Diganti mekanisme 5-ketukan:**

```
Pengguna ketuk 5× dalam 1.5 detik
    ↓
Confirmation Dialog muncul dengan countdown 5 detik
    ↓
Option A: User tekan "BATALKAN" → SOS dibatalkan
Option B: User tekan "KIRIM!" → SOS dikirim (trigger_method: 'user')
Option C: Countdown habis → SOS dikirim otomatis (trigger_method: 'timeout')
    ↓
Banner konfirmasi muncul 4 detik
```

UI baru:
- 5 titik dot indicator (animasi fill saat ketuk)
- Ring progress circular di luar tombol SOS
- Dialog overlay dengan countdown progress bar
- Banner animasi slide-down saat SOS terkirim

#### File lain — Perbaikan Linter (Flutter analyze: 0 issues)
| File | Perubahan |
|------|-----------|
| `settings_screen.dart` | `activeColor` → `activeThumbColor` (SwitchListTile) |
| `relawan_main_screen.dart` | `activeColor` → `activeThumbColor` (Switch) |
| `edit_profile_screen.dart` | `value` → `initialValue` (DropdownButtonFormField), empty catch → `debugPrint` |
| `volunteer_registration_screen.dart` | `value` → `initialValue` (DropdownButtonFormField) |
| `biodata_screen.dart` | `value` → `initialValue` (DropdownButtonFormField) |
| `main.dart` | Unnamed parameter `__` → `w` (leading underscore warning) |

#### `core/services/otp_service.dart` — BARU
```dart
class OTPService {
    static Future<void> requestOTP(String phoneNumber) async { ... }
    static Future<void> verifyOTP(String phoneNumber, String otpCode) async { ... }
}
class OTPException implements Exception {
    final String message;
    final bool isRateLimit; // true jika 429, false jika error lain
}
```

---

## 4. Struktur File Terkini

```
siagakita/
├── .gitignore                          ✅ Diperbaiki
├── backend-go/
│   ├── cmd/api/main.go                 ✅ OTP domain di-wire
│   ├── internal/
│   │   ├── config/config.go            ✅ + FonnteToken
│   │   ├── domain/
│   │   │   ├── incident/               ✅ Selesai
│   │   │   ├── otp/                    🆕 BARU
│   │   │   │   ├── gateway.go          🆕 Fonnte WA interface
│   │   │   │   ├── service.go          🆕 Redis OTP logic
│   │   │   │   └── handler.go          🆕 HTTP endpoints
│   │   │   ├── telemetry/              ✅ Selesai
│   │   │   └── user/                   ✅ Selesai
│   │   ├── hub/                        ✅ Selesai (WS registry)
│   │   ├── middleware/                 ✅ Selesai
│   │   └── ws/                        ✅ Selesai
│   └── migrations/
│       └── 001_init_schema.sql         ✅ + trigger_method, nullable fields
├── infrastructure/
│   ├── .env                            ✅ (tidak di-track git)
│   ├── .env-example                    ✅ + FONNTE_TOKEN template
│   └── docker-compose.yml             ✅ Selesai
└── mobile-flutter/
    ├── pubspec.yaml                    ✅ + http: ^1.2.2
    └── lib/
        ├── main.dart                   ✅ Lint fixed
        ├── core/
        │   ├── models/user_model.dart  ✅ Selesai
        │   ├── router.dart             ✅ Selesai
        │   └── services/
        │       └── otp_service.dart    🆕 BARU
        └── features/
            ├── auth/
            │   ├── login_screen.dart   ✅ Diperbarui total
            │   ├── register_screen.dart ✅ Diperbarui total
            │   └── biodata_screen.dart 🟡 UI selesai, API pending
            ├── masyarakat/
            │   ├── home_screen.dart    ✅ SOS 5-ketukan baru
            │   ├── edit_profile_screen.dart  🟡 UI selesai, API pending
            │   ├── settings_screen.dart      ✅ Lint fixed
            │   └── volunteer_registration_screen.dart  🟡 UI selesai
            └── relawan/
                └── relawan_main_screen.dart  🟡 UI selesai, data mock
```

---

## 5. API Endpoint yang Tersedia

Base URL: `http://<host>:8080/api/v1`

### Auth (Public — tidak butuh JWT)
| Method | Endpoint | Keterangan |
|--------|----------|-----------|
| POST | `/auth/register` | Daftar akun baru |
| POST | `/auth/login` | Login, return access_token + refresh_token |
| POST | `/auth/request-otp` | Kirim OTP ke WA via Fonnte (rate limit 60s) |
| POST | `/auth/verify-otp` | Verifikasi kode OTP |

### Users (Protected — butuh `Authorization: Bearer <token>`)
| Method | Endpoint | Keterangan |
|--------|----------|-----------|
| GET | `/users/profile` | Ambil profil pengguna |
| POST | `/users/biodata` | Simpan biodata (transaksi atomik) |

### Incidents (Protected)
| Method | Endpoint | Keterangan |
|--------|----------|-----------|
| POST | `/incidents/:id/resolve` | Tandai insiden selesai |

### Telemetry (Protected)
| Method | Endpoint | Keterangan |
|--------|----------|-----------|
| PUT | `/telemetry/location` | Update lokasi real-time |

### WebSocket
| URL | Keterangan |
|-----|-----------|
| `ws://<host>:8081/ws/connect` | Persistent connection untuk SOS events |

**WS Event yang sudah direncanakan:**
- `TRIGGER_SOS` — dari client ke server
- `CANCEL_SOS` — dari client ke server  
- `SOS_DISPATCHED` — dari server ke relawan/instansi

---

## 6. Schema Database — Perubahan & Status

Tabel yang sudah ada dan statusnya:

| Tabel | Status | Keterangan |
|-------|--------|-----------|
| `users` | ✅ + nullable | `nik`, `date_of_birth` nullable; `phone_number` WAJIB |
| `user_medical_profiles` | ✅ | Golongan darah, alergi, riwayat penyakit |
| `emergency_contacts` | ✅ | Kontak darurat (relasi ke users) |
| `incidents` | ✅ + kolom baru | + `trigger_method VARCHAR(20) DEFAULT 'timeout'` |
| `incident_responses` | ✅ | Respons relawan/instansi terhadap insiden |
| `volunteer_certifications` | ✅ | Sertifikat relawan (approval flow) |
| `m_badges` | ✅ | Master data badge |
| `volunteer_badges_acquired` | ✅ | Badge yang dimiliki relawan |

**Enum yang digunakan:**
```sql
user_role:          civilian | volunteer | agency_responder | admin
incident_category:  (sesuai definisi awal)
incident_status:    grace_period | broadcasting | handled | resolved | false_alarm
response_status:    en_route | on_scene | completed | canceled
cert_status:        pending | approved | rejected
blood_type_enum:    (tipe darah standar)
```

---

## 7. Yang Belum Selesai

### Prioritas Tinggi (Sprint Berikutnya)
- [ ] **Task 6 — Service Layer Flutter:**
  - `AuthService.login()` dan `AuthService.register()` → API `/auth/login` & `/auth/register`
  - Simpan `access_token` di `flutter_secure_storage`
  - Attach JWT ke setiap request (Interceptor / custom http client)
- [ ] **Biodata → API:** Wire `BiodataScreen` ke `POST /users/biodata`
- [ ] **Profile → API:** Wire `EditProfileScreen` ke `GET/PUT /users/profile`

### Prioritas Sedang
- [ ] **WebSocket Flutter:** Koneksi `wss://host:8081/ws/connect` saat app buka
- [ ] **SOS dispatch ke WebSocket:** `TRIGGER_SOS` event dengan `triggered_by` dan koordinat GPS
- [ ] **Relawan dashboard:** Ganti data mock dengan data dari API
- [ ] **Refresh token:** Auto-refresh saat `access_token` expired

### Prioritas Rendah / Masa Depan
- [ ] Push notification (FCM) untuk alert darurat
- [ ] Dashboard Admin Windows Flutter
- [ ] Status verifikasi KTP (admin dapat lihat status akun pengirim SOS)
- [ ] Riwayat insiden per pengguna

---

## 8. Panduan Setup untuk Anggota Baru

### Prasyarat
```bash
# Go 1.26+
go version

# Flutter 3.x+
flutter --version

# Docker & Docker Compose
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
# Edit .env dan isi credential yang dibutuhkan:
# - DB_USER, DB_PASSWORD
# - REDIS_PASSWORD
# - JWT_SECRET (buat string acak panjang)
# - FONNTE_TOKEN (daftar di fonnte.com, scan WA, copy token)
```

**3. Jalankan infrastruktur (PostgreSQL + Redis + pgAdmin):**
```bash
sudo docker compose -f infrastructure/docker-compose.yml up -d postgres redis pgadmin
```

**4. Jalankan migrasi database:**
```bash
sudo docker exec -i siagakita_postgres psql \
  -U siagakita_admin -d siagakita \
  < backend-go/migrations/001_init_schema.sql
```

**5. Build dan jalankan backend:**
```bash
# Development (langsung)
cd backend-go
go run ./cmd/api/

# Atau via Docker
sudo docker compose -f infrastructure/docker-compose.yml up --build -d api
```

**6. Jalankan Flutter mobile:**
```bash
cd mobile-flutter
flutter pub get
flutter run
# Atau: flutter run -d <device_id>
```

### Cara Akses
| Layanan | URL |
|---------|-----|
| REST API | `http://localhost:8080` |
| Health Check | `http://localhost:8080/health` |
| WebSocket | `ws://localhost:8081/ws/connect` |
| pgAdmin | `http://localhost:5050` |

### Catatan Emulator Android
Flutter emulator menggunakan `10.0.2.2` untuk mengakses `localhost` host machine. Ini sudah dikonfigurasi di `otp_service.dart`.

---

> 💬 **Pertanyaan?** Hubungi @SuperBypassUdinnn atau buat issue di repository.
