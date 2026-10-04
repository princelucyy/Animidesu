# Arsitektur Animidesu

```text
Flutter UI
  ├─ Home / Search / Detail / Library / Schedule / Profile
  ├─ Player UI
  │    └─ media_kit + media_kit_video
  ├─ LocalStore
  │    ├─ Favorites
  │    ├─ Watch progress/history
  │    ├─ XP/level/pet/tickets
  │    └─ Stream API URL
  ├─ AniListApi
  │    └─ metadata + schedule
  └─ StreamRepository
       └─ your licensed stream backend
```

## Production systems to add

- Auth + account sync: Supabase/Firebase/custom API.
- Push notification: FCM/APNs with topic subscriptions.
- Downloads: Android-only background downloader using authorized files; never bypass DRM.
- Search indexing: backend cache for AniList metadata to reduce client API usage.
- CDN/security: signed URLs, short-lived tokens, rate limiting.
- Admin panel: catalog management, reports, moderation, release notes.
- Observability: crash reporting, structured logs, uptime checks.
- Desktop packaging: `.msix`, `.dmg`, AppImage/deb; iOS builds require macOS/Xcode.
