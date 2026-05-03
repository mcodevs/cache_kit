# cache_kit

> Media–keshni (<kbd>video</kbd>, <kbd>audio</kbd>, <kbd>image</kbd>, <kbd>file</kbd>) **saqlash, o‘qish va tozalash** uchun oson, soddalashtirilgan Flutter kutubxonasi.

[![Pub Version](https://img.shields.io/pub/v/cache_kit.svg)](https://pub.dev/packages/cache_kit)
[![Platform](https://img.shields.io/badge/platform-android%20|%20ios%20|%20macos%20|%20windows%20|%20linux-blue)](#platform-support)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

`cache_kit` ilova vaqtinchalik xotirasini tartibga solib, media‑fayllarni alohida kataloglarda saqlaydi, statistikani ko‘rsatadi va istalgan payt tozalash imkonini beradi. Kiritilgan fayl kengaytmasi orqali turini avtomatik aniqlaydi yoki **`MediaType`** enum’i bilan qo‘lda belgilashingiz mumkin.

---

## ✨ Xususiyatlar

| ⚙️ Funksiya                   | Tavsifi                                                     |
|-------------------------------|-------------------------------------------------------------|
| `save()`                      | Baytlar oqimini (bytes) kerakli katalogga yozadi            |
| `getFile()`                   | Faylni nomi orqali qaytaradi (yo‘q bo‘lsa `null`)           |
| `getFileCount()`              | Katalogdagi fayllar sonini qaytaradi                        |
| `getTotalSize()`              | Katalogdagi jami hajmni (bayt) hisoblaydi                   |
| `clearCache()`                | Tanlangan yoki barcha media‑turlarini o‘chiradi             |
| `clearAppData()`              | **Platform‑native** kesh/ma’lumotlarni tozalaydi            |
| `CacheKitScope` (widget)      | Kontekst orqali bir nechta ekranda boshqarishni osonlashtiradi |

---

## 🚀 O‘rnatish

```yaml
dependencies:
  cache_kit: ^<last_version>
```

```bash
flutter pub get
```

---

## ⚡ Tez boshlash

### 1‑variant: To‘g‘ridan‑to‘g‘ri foydalanish

```dart
import 'package:cache_kit/cache_kit.dart';

final cacheKit = CacheKit(saveDirectory: 'my_app_cache');

// Saqlash
await cacheKit.save(bytes,
    fileName: 'photo.jpg'); // media turi kengaytmadan aniqlanadi

// O‘qish
final file = await cacheKit.getFile('photo.jpg');
if (file != null) print('🖼️  Fayl topildi: ${file.path}');

// Tozalash (faqat rasm va video)
await cacheKit.clearCache(types: [MediaType.image, MediaType.video]);
```

### 2‑variant: `CacheKitScope` orqali (kontekst bilan)

```dart
void main() {
  runApp(CacheKitScope(
    saveDirectory: 'my_app_cache',
    child: const MyApp(),
  ));
}

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cache = CacheKitScope.of(context);

    return ElevatedButton(
      onPressed: () async {
        final count = await cache.getFileCount(MediaType.image);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Rasmlar soni: $count')));
      },
      child: const Text('Statistika'),
    );
  }
}
```

---

## 📚 API qisqa sharhi

| Method | Imzo | Qisqa izoh |
|--------|------|-------------|
| `save(Uint8List bytes, {required String fileName, MediaType? mediaType})` | Faylni keshga yozish |
| `getFile(String fileName, {MediaType? mediaType}) → Future<File?>` | Faylni keshdan olish |
| `getCacheDirectory` | Bazaviy kesh katalogini qaytaradi |
| `getMediaDirectory(MediaType)` | Muayyan `<type>/` katalogini qaytaradi |
| `getFileCount(MediaType)` | Fayllar soni |
| `getTotalSize(MediaType)` | Umumiy hajm (bayt) |
| `clearCache({List<MediaType>? types})` | Tanlangan / barcha turdagi fayllarni o‘chiradi |
| `removeFile(String fileName, {MediaType? mediaType}) → Future<bool>` | Bitta faylni o‘chirish |
| `exists(String fileName, {MediaType? mediaType}) → Future<bool>` | Fayl mavjudligini tekshirish |
| `getTotalSizeByType() → Future<Map<MediaType, int>>` | Har bir media turining hajmi |
| `purgeExpired(Duration maxAge, {List<MediaType>? types}) → Future<int>` | Eskirgan fayllarni tozalash |
| `enforceMaxSize(int maxBytes, {List<MediaType>? types}) → Future<int>` | Limitdan oshsa LRU bo‘yicha tozalash |
| `clearAppData()` | Ilovaning **barcha** kesh va hujjat kataloglarini tozalaydi (Android/iOS/macOS/...) |

---

## 🖥️ Platform qo‘llab‑quvvatlash

> Kutubxona **`dart:io`** va **`path_provider`** ga tayangan:
> ‑ Android  
> ‑ iOS / iPadOS  
> ‑ macOS (Intel va Apple Silicon)  
> ‑ Windows  
> ‑ Linux  
> ⚠️: Hozircha Web qo‘llab‑quvvatlanmaydi.

---

## ⚠️ E’tibor bering

* **Fayl nomida kengaytma bo‘lishi shart**, aks holda `FormatException` qaytariladi.  
* `clearAppData()` – ba’zi OS versiyalarida cheklangan ruxsatlar tufayli hamma narsani tozalay olmasligi mumkin.  
* `MediaType.music` – audio fayllar (`.mp3`, `.aac`, `.m4a` va hokazo) toifasi. Kengaytmalar ro‘yxatini `extensions.dart` orqali kengaytirish mumkin.

---

## 📌 Roadmap

- [ ] Web (Was mim) uchun qo‘llab‑quvvatlash  
- [ ] Max hajmga yetganda avtomatik LRU‑tozalash  
- [ ] Hive/Isar yordamida metadata qaydnomasi  
- [ ] Platform indipendent background cleaning (Isolate/Worker)  

---

## 📝 Hissa qo‘shish

Pull‑requestlar, masalalar (issue) va takliflar xush kelibsiz!  
1. Fork → 2. Branch → 3. PR → 4. :tada:

```bash
git clone https://github.com/mcodevs/cache_kit.git
git checkout -b fix/my-awesome-fix
```

---

## 📄 Litsenziya

Distributed under the **MIT License**. For more information see [`LICENSE`](LICENSE).

---

<div align="center">

⭐️ **cache_kit** – ilovangizni engil va tartibli qiling! ⭐️

</div>
