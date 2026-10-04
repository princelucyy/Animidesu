# Animidesu

Animidesu adalah fondasi client anime lintas platform berbasis Flutter. UI dan struktur fiturnya mengambil inspirasi dari pola umum aplikasi anime modern (beranda, pencarian, detail, koleksi, jadwal, profile, gacha/pet, dan player), tetapi tidak menyalin kode, logo, nama aset, atau desain proprieter aplikasi lain.

## Fitur fondasi

- Home: trending, airing/terbaru, search.
- Detail anime: banner, deskripsi, genre, score, status, episode picker.
- Koleksi: favorit + histori/progress lokal.
- Jadwal: episode berikutnya dari metadata AniList.
- Profil: level/XP, gacha pet sederhana, konfigurasi API streaming sendiri.
- Player lintas platform menggunakan `media_kit`.
- Arsitektur stream adapter: backend Anda memasok URL HLS/MP4 yang sah.
- Android APK via GitHub Actions.

## API stream

Animidesu tidak menyertakan scraper atau mirror bajakan. Buat backend Anda sendiri atau gunakan provider resmi/berlisensi.

Endpoint yang diharapkan client:

`GET {BASE}/streams/{anilistId}/{episode}?lang=id`

Response:

```json
{
  "streams": [
    {"url": "https://cdn.example.com/video.m3u8", "label": "Main", "quality": "1080p"},
    {"url": "https://cdn.example.com/video-720.m3u8", "label": "Backup", "quality": "720p"}
  ]
}
```

## Termux → GitHub

```bash
pkg update -y
pkg install git openssh
cd ~
git clone <URL-REPO-ANDA> animidesu
cd animidesu
# salin/ganti file dari template ini, lalu:
git add .
git commit -m "Initial Animidesu client"
git branch -M main
git push -u origin main
```

Setelah push, buka tab **Actions** di GitHub. Job **Build Android APK** akan membuat APK `arm64`, `armeabi-v7a`, dan `x86_64` sebagai artifacts.

## Build lokal

Jika Flutter sudah tersedia:

```bash
./tool/prepare_platforms.sh
flutter build apk --release --split-per-abi
```

Flutter 3.47 adalah channel stabil per 4 Oktober 2026; workflow menguncinya ke versi tersebut untuk hasil build yang konsisten.
