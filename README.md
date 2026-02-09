## Crop3000

Crop3000 adalah utilitas Flutter desktop untuk crop, resize, dan re‑encode banyak gambar sekaligus menjadi persegi sempurna dengan ukuran yang bisa kamu atur (default 3000×3000). Antarmuka mendukung drag & drop, input path manual, dan file picker, lalu memproses semuanya secara paralel di isolate supaya UI tetap responsif.

### Workflow

1. Jalankan aplikasi desktop (`flutter run -d windows`, macOS, atau Linux jika didukung).
2. Atur preferensi:
   - **Bahasa UI**: Indonesia, English, 中文, 日本語, 한국어, العربية, Русский, हिन्दी.
   - **Tema**: Light, Dark, atau System (disimpan ke SharedPreferences).
   - **Output**: ukuran target (px), format (JPG/PNG/BMP – JPG default), dan profil kompresi.
   - Tekan tombol **Help** di top bar kapan saja untuk membuka panduan lengkap langsung di aplikasi.
3. Masukkan gambar dengan:
   - Drag & drop ke area drop,
   - Paste path ke input manual lalu tekan tombol tambah,
   - Atau klik tombol untuk membuka file picker sistem.
4. Cek daftar antrian. Hapus item tertentu atau bersihkan semua sebelum mulai.
5. Tekan tombol mulai. Setiap file akan divalidasi, di‑crop ke persegi tengah, di‑resize, dan disimpan ke format yang dipilih (JPG/PNG menghormati pengaturan kompresi, BMP disimpan mentah).
6. Pantau progress bar dan log rinci untuk status tiap file, termasuk catatan kompresi dan pesan error yang ramah pengguna.

### Fitur

- **Multi-input**: drag & drop, path manual, dan file picker.
- **Manajemen antrian**: list tanpa duplikat, bisa hapus per‑item atau clear all.
- **Output fleksibel**: ukuran bebas, pilihan format JPG/PNG/BMP, dan mode kompresi.
- **Proses paralel**: crop/resize/encode di isolate dengan progress real‑time.
- **Tema & bahasa tersimpan**: pilihan Light/Dark/System dan bahasa UI disimpan dengan SharedPreferences.
- **Log aktivitas**: riwayat sukses/gagal per file dengan detail format dan kompresi.
- **Help & Guide**: tombol *Help* di top bar membuka dialog panduan langkah demi langkah plus tautan cepat ke README.
- **Menu Pengaturan & Tentang**:
  - Picker bahasa (Indonesia, English, 中文, 日本語, 한국어, العربية, Русский, हिन्दी) dengan nama asli (bukan latin).
  - Seksi *About* yang mengkredit GitHub `Ian7672`.
  - Tombol donasi ke Trakteer dan Ko‑fi.

### Build & Development

- Butuh Flutter 3.8.1+ (lihat `environment` di `pubspec.yaml`).
- Install dependency: `flutter pub get`.
- Jalankan di Windows: `flutter run -d windows`.
- Build Windows release: `flutter build windows --release`.
- Opsional: `flutter analyze` untuk linting dan `flutter test` untuk pengujian.

### Credits & Support

- **Developer**: [Ian7672](https://github.com/Ian7672)
- **Donasi**:
  - Trakteer: `https://trakteer.id/Ian7672`
  - Ko‑fi: `https://ko-fi.com/Ian7672`
