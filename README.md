# 🎓 Quiz App - Flutter Mobile Application

Aplikasi manajemen kuis berbasis mobile yang dibangun menggunakan **Flutter**. Aplikasi ini memfasilitasi dua peran pengguna (Guru dan Siswa) dengan fitur pembuatan soal, pengerjaan kuis, dan penilaian otomatis maupun manual.

## 📱 Gambaran Umum

Aplikasi ini menggunakan sistem **Role-Based Access Control**.
- **Guru** dapat membuat, mengedit, menghapus kuis, serta menilai jawaban esai siswa.
- **Siswa** dapat mengerjakan kuis (Pilihan Ganda, True/False, Esai) dan melihat riwayat nilai mereka.

> **Catatan Teknis:** Autentikasi pengguna dikelola menggunakan **Firebase Authentication**, sedangkan data kuis dan riwayat disimpan secara lokal menggunakan **SharedPreferences** dalam format JSON Serialized.

---

## ✨ Fitur Utama

### 🔐 Autentikasi & Keamanan
- Login menggunakan Email & Password (terintegrasi Firebase Auth).
- Validasi Role otomatis (Guru/Siswa) berdasarkan *Allowlist Email*.

### 👨‍🏫 Mode Guru (Teacher)
- **Dashboard Guru:** Ringkasan aktivitas.
- **Manajemen Kuis (CRUD):** - Membuat Kuis baru dengan pengaturan Timer.
    - Menambah soal (Pilihan Ganda, True/False, Esai).
    - Mengedit dan Menghapus Kuis.
- **Grading (Penilaian):**
    - Melihat daftar siswa yang sudah mengerjakan.
    - Memberikan nilai manual & komentar untuk soal Esai.

### 👨‍🎓 Mode Siswa (Student)
- **Pengerjaan Kuis:**
    - Timer berjalan mundur saat pengerjaan.
    - Mendukung navigasi antar soal.
    - Tidak diperbolehkan keluar, timer tidak dapat diulang.
- **Auto-Grading:** Soal PG dan True/False dinilai otomatis oleh sistem.
- **Riwayat & Hasil:**
    - Melihat skor sementara (jika ada esai, status menjadi "Pending").
    - Visualisasi hasil menggunakan Pie Chart.

---

## 🛠️ Teknologi yang Digunakan

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **Authentication:** Firebase Auth
- **Local Persistence:** SharedPreferences (JSON Structure)
- **State Management:** Native `setState` & `ChangeNotifier` (MVVM Pattern)
- **Charts:** `pie_chart` package

---

## 🚀 Cara Menjalankan (Installation)

1. **Clone Repository**
   ```bash
   git clone [https://github.com/NATHANIELJOVAN/quizziz.git]
   