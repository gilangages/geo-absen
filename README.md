# 📍 Geo Absen - Attendance System with Geofencing

Geo Absen adalah sistem manajemen absensi modern berbasis lokasi (**Geofencing**) yang dirancang untuk validasi kehadiran karyawan secara akurat. Sistem ini terdiri dari backend **Laravel** yang kuat (lengkap dengan Dashboard Admin Filament) dan aplikasi mobile **Flutter** yang intuitif.

Projek ini menggunakan algoritma **Haversine** untuk menghitung jarak antara koordinat GPS karyawan dengan lokasi kantor, serta didukung verifikasi foto selfie dan manajemen pengajuan izin (Sakit, Izin, Cuti).

## 🚀 Tech Stack

### 🖥️ Backend (API & Admin Panel)
- **Framework**: Laravel 13 (PHP ^8.3)
- **Authentication**: Laravel Sanctum (Token-based API)
- **Admin Dashboard**: Filament v5 (Panel Pengelolaan User & Kantor)
- **Database**: MySQL / SQLite (Default config: MySQL)
- **Core Logic**: `OfficeService` (Haversine Formula for Distance Calculation)

### 📱 Frontend (Mobile Application)
- **Framework**: Flutter (Dart ^3.10.4)
- **Routing**: go_router 17.2.0 (State-based routing)
- **Networking**: http, flutter_dotenv
- **Sensors**: geolocator (GPS/Location), image_picker (Camera/Selfie)
- **State Management**: Provider-like / ViewModel pattern

## 🛠️ Prerequisites

Pastikan alat-alat berikut sudah terinstall di komputer Anda:
- **PHP** >= 8.3 & **Composer**
- **Node.js** & **npm**
- **Flutter SDK** (v3.10.4 atau lebih baru)
- **MySQL Server** (Untuk database produksi)
- **Android Studio / Xcode** (Untuk emulator)

## 📦 Installation & Setup

### 1. Konfigurasi Backend (Laravel)
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
```

**Konfigurasi Penting `.env` Backend:**
1.  **Database**: Atur `DB_CONNECTION=mysql` dan sesuaikan kredensial database Anda.
2.  **Filesystem**: Ubah `FILESYSTEM_DISK=public` agar foto selfie bisa diakses publik.
3.  **Admin Seeder**: Tambahkan variabel berikut untuk akun admin pertama:
    ```env
    ADMIN_EMAIL=admin@admin.com
    ADMIN_PASS=password123
    ```

**Finalisasi Backend:**
```bash
php artisan migrate --seed    # Membuat tabel & data awal (Admin & Kantor)
php artisan storage:link      # Menghubungkan folder upload ke public
npm install && npm run build  # Compile assets Filament
php artisan serve --host=0.0.0.0 --port=8000
```

### 2. Konfigurasi Frontend (Flutter)
1.  Buat file `.env` di dalam folder `frontend`:
    ```env
    API_URL=http://<IP_LAPTOP_ANDA>:8000/api
    ```
2.  Jalankan instalasi library:
    ```bash
    cd frontend
    flutter pub get
    ```

### 3. Cara Menjalankan Aplikasi Frontend
Ada dua cara umum untuk menjalankan aplikasi Flutter di projek ini:

- **Emulator / Real Device (Android/iOS):**
  ```bash
  flutter run
  ```

- **Web Browser (Chrome) - Spesifik Port 3000:**
  Jika Anda ingin mengetes melalui Chrome, gunakan perintah di bawah ini agar port terkunci di **3000**. Hal ini penting karena Laravel CORS sudah dikonfigurasi untuk menerima request dari `http://localhost:3000`:
  ```bash
  flutter run -d chrome --web-server 3000
  ```
  *(Catatan: Perintah ini memastikan port tidak berubah-ubah saat proses reload/restart)*.

---

## 📂 Project Structure

```
geo-absen/
├── backend/                # Laravel Framework
│   ├── app/
│   │   ├── Filament/       # Admin Panel Configuration
│   │   ├── Models/         # Database Schema (Attendance, Office, Leave)
│   │   └── Services/       # Business Logic (Haversine & Attendance)
│   ├── database/           # Migrations & Seeders
│   └── routes/             # API & Web Routes
└── frontend/               # Flutter Application
    ├── lib/
    │   ├── core/           # Network & App Configuration
    │   ├── data/           # API Integration (Data Sources)
    │   └── screens/        # UI Modules (Dashboard, History, Profile)
```

## ❓ FAQ & Troubleshooting

### Kenapa running Laravel harus pakai `--host=0.0.0.0`?
Secara default, `php artisan serve` hanya berjalan di `127.0.0.1` (localhost internal). Artinya, server hanya bisa menerima request yang berasal dari dalam laptop itu sendiri.
- **Masalah Koneksi:** Karena aplikasi Flutter (di HP/Emulator) memanggil backend menggunakan **Alamat IP** (bukan localhost), Laravel akan menolak koneksi tersebut (Error: *Connection Refused*) jika tidak dibuka aksesnya.
- **Solusi 0.0.0.0:** Dengan menambahkan `--host=0.0.0.0`, Laravel diperintahkan untuk "mendengarkan" request dari semua jalur (interface) jaringan, baik itu Localhost, Wi-Fi, maupun LAN. 
- Hal ini **wajib** agar aplikasi Flutter bisa "ngobrol" dengan server Laravel melalui jaringan yang sama.

### Kenapa API_URL di `.env` bukan `localhost`?
Dalam pengembangan mobile:
1.  **Emulator Android**: Merujuk ke `localhost` sebagai dirinya sendiri. Untuk mengakses laptop host, gunakan IP `10.0.2.2`.
2.  **HP Asli**: Harus menggunakan **IP Lokal Laptop** (contoh: `192.168.1.10`) agar bisa terhubung selama dalam satu jaringan Wi-Fi.
3.  **Localhost (127.0.0.1)**: Hanya bekerja jika Anda menjalankan Flutter di mode Web atau Desktop di mesin yang sama.

### Kenapa harus Port 3000 di Chrome?
Karena port default Flutter Web seringkali acak (random). Sehingga, untuk mempermudah saya telah mengatur `backend/config/cors.php` agar hanya mengizinkan origin `http://localhost:3000` demi keamanan.

Built with ❤️ by Abdian
