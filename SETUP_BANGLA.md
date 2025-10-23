# সহজ সেটআপ গাইড (বাংলা)

## ১. প্রথমবার যা করতে হবে

### App Build করুন:
```bash
flutter pub get
flutter build apk --release
```

আপনার APK পাবেন এখানে:
```
build/app/outputs/flutter-apk/app-release.apk
```

## ২. Server সেটআপ (সবচেয়ে সহজ পদ্ধতি - GitHub)

### GitHub ব্যবহার করে (সম্পূর্ণ বিনামূল্যে):

#### ধাপ ১: GitHub Repository তৈরি করুন
1. https://github.com এ যান
2. নতুন repository তৈরি করুন (যেমন: `factory-app-updates`)
3. Public রাখুন

#### ধাপ ২: version.json ফাইল তৈরি করুন
Repository তে একটি `version.json` ফাইল তৈরি করুন:

```json
{
  "version": "1.0.0",
  "buildNumber": 1,
  "apkUrl": "https://github.com/YOUR_USERNAME/factory-app-updates/releases/download/v1.0.0/app-release.apk",
  "releaseNotes": "প্রথম ভার্সন"
}
```

**Note:** `YOUR_USERNAME` আপনার GitHub username দিয়ে বদলান

#### ধাপ ৩: Release তৈরি করুন
1. GitHub repository তে "Releases" এ যান
2. "Create a new release" ক্লিক করুন
3. Tag: `v1.0.0` দিন
4. Title: `Version 1.0.0` দিন
5. আপনার `app-release.apk` ফাইল attach করুন
6. "Publish release" ক্লিক করুন

#### ধাপ ৪: App এ URL সেট করুন

`lib/services/update_service.dart` ফাইল খুলুন এবং এই line টি পরিবর্তন করুন:

```dart
static const String versionCheckUrl =
    'https://raw.githubusercontent.com/YOUR_USERNAME/factory-app-updates/main/version.json';
```

**Note:** `YOUR_USERNAME` এবং `factory-app-updates` আপনার তথ্য দিয়ে বদলান

## ৩. নতুন আপডেট দেওয়ার পদ্ধতি

### যখনই app এ নতুন feature যোগ করবেন:

#### ধাপ ১: Version বাড়ান
`pubspec.yaml` ফাইলে:
```yaml
version: 1.0.1+2  # আগে ছিল 1.0.0+1
```

#### ধাপ ২: নতুন APK build করুন
```bash
flutter build apk --release
```

#### ধাপ ৩: GitHub এ নতুন Release তৈরি করুন
1. GitHub repository তে "Releases" এ যান
2. "Create a new release" ক্লিক করুন
3. Tag: `v1.0.1` দিন (নতুন version)
4. নতুন `app-release.apk` attach করুন
5. "Publish release" করুন

#### ধাপ ৪: version.json আপডেট করুন
GitHub এ `version.json` ফাইল edit করুন:

```json
{
  "version": "1.0.1",
  "buildNumber": 2,
  "apkUrl": "https://github.com/YOUR_USERNAME/factory-app-updates/releases/download/v1.0.1/app-release.apk",
  "releaseNotes": "নতুন features যোগ করা হয়েছে"
}
```

✅ **সম্পন্ন!** এখন factory workers রা app খুলে "আপডেট চেক করুন" বাটনে ক্লিক করলে নতুন version পাবে!

## ৪. Factory তে প্রথম Install

### Workers দের Phone এ:

1. APK পাঠান (WhatsApp/Email/USB)
2. APK ফাইলে tap করুন
3. "Unknown sources থেকে install" permission দিন
4. Install করুন
5. App খুলুন এবং সব permissions দিন

## ৫. পরবর্তী Update গুলো

Workers দের শুধু বলতে হবে:
1. App খুলুন
2. "আপডেট চেক করুন" বাটনে ক্লিক করুন
3. যদি update থাকে, "আপডেট করুন" বাটনে ক্লিক করুন
4. Download এবং install automatically হবে!

## বিকল্প Server Options

### Google Drive ব্যবহার করে:

1. Google Drive এ folder তৈরি করুন
2. `version.json` এবং `app-release.apk` আপলোড করুন
3. Files public করুন এবং direct download link নিন
4. version.json এ সেই links ব্যবহার করুন

### Dropbox ব্যবহার করে:

Same as Google Drive

### নিজের Website ব্যবহার করে:

যদি আপনার কোন website/hosting থাকে:
1. সেখানে files আপলোড করুন
2. Direct URL ব্যবহার করুন

## Common সমস্যা ও সমাধান

### ❌ "Update check failed"
**সমাধান:**
- Internet connection check করুন
- GitHub URL সঠিক আছে কিনা দেখুন
- version.json public accessible কিনা চেক করুন

### ❌ "Download failed"
**সমাধান:**
- Phone এ storage space আছে কিনা চেক করুন
- APK URL সঠিক কিনা দেখুন
- Internet connection stable কিনা চেক করুন

### ❌ "Install করতে পারছে না"
**সমাধান:**
- Settings > Security > "Unknown sources" enable করুন
- বা Settings > Apps > Special access > Install unknown apps > আপনার app টি enable করুন

## Test করার জন্য

প্রথমে local network এ test করতে চাইলে:

1. একটি folder এ `version.json` এবং APK রাখুন
2. Python দিয়ে server চালান:
```bash
python -m http.server 8000
```
3. আপনার computer এর IP address খুঁজুন (ipconfig command)
4. App এ URL দিন: `http://192.168.1.XXX:8000/version.json`

## সাহায্য দরকার?

কোন সমস্যা হলে:
1. README.md ফাইল ভালো করে পড়ুন
2. GitHub Issues চেক করুন
3. YouTube এ "Flutter APK auto update" খুঁজুন

---

**আপনার Factory App সফলভাবে চলুক! 🎉**
