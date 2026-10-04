# Animidesu Stream API

API kecil untuk menghubungkan client Animidesu ke sumber video yang Anda miliki atau memang berlisensi untuk didistribusikan.

## Jalankan

```bash
node server.js
```

Default: `http://localhost:8787`

## Isi catalog

Salin `catalog.example.json` menjadi `catalog.json`, lalu isi URL HLS/MP4 milik Anda.

Client memanggil:

`GET /streams/{anilistId}/{episode}?lang=id`

Response:

```json
{"streams":[{"url":"https://cdn.example.com/master.m3u8","label":"Main","quality":"adaptive"}]}
```
