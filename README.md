# 3yadati — عيادتي

نظام متكامل لإدارة العيادات والمواعيد للأطباء والمراكز الطبية، مبني كـ **Monorepo** يحتوي على:

```
3yadati/
├── apps/
│   ├── doctor/      # تطبيق Flutter للأطباء (Android / iOS / Web)
│   ├── patient/     # هيكل تطبيق Flutter للمرضى (placeholder)
│   └── backend/     # NestJS + Prisma + PostgreSQL API مشتركة
└── docs/
```

## المميزات الأساسية

### تطبيق الطبيب (Doctor App)

- **Splash + تسجيل الدخول / إنشاء حساب** للأطباء والمراكز الطبية.
- **لوحة تحكم (Dashboard)** فيها بطاقات إحصاءات اليوم: الحجوزات، المرضى الجدد، الإيرادات، المواعيد القادمة.
- **التقويم**: عرض يومي / أسبوعي / شهري لكل المواعيد.
- **تفاصيل الحجز**: تأكيد الوصول، إعادة جدولة، إلغاء، تغيير الحالة.
- **ساعات العمل**: لكل يوم من أيام الأسبوع، مع أوقات الاستراحة والإجازات.
- **الفروع**: إدارة فروع متعددة للمركز الطبي مع موقع جغرافي.
- **المرضى**: قائمة المرضى مع البحث وتفاصيل ملف كل مريض.
- **الإحصائيات**: نظرة عامة + رسم بياني للحجوزات الأسبوعية + توزيع الحالات.
- **الإشعارات**: قائمة كاملة بكل تنبيهات الحجوزات.
- **الملف الشخصي والإعدادات**.
- **RTL + خط Tajawal + ألوان طبية احترافية** (Primary `#1FAE9A`).

### Backend

- مصادقة JWT + تشفير كلمات السر بـ Argon2.
- صلاحيات Roles: `DOCTOR`, `ASSISTANT`, `CENTER_MANAGER`, `PATIENT`, `ADMIN`.
- موارد: `Doctors`, `Branches`, `WorkingHours`, `Holidays`, `Appointments`, `Patients`, `Notifications`, `Statistics`.
- توليد المواعيد التلقائي (slots) بناءً على ساعات العمل وأوقات الاستراحة والإجازات.
- حالات المواعيد: `AVAILABLE / PENDING / CONFIRMED / COMPLETED / CANCELLED / NO_SHOW / CLOSED`.
- Swagger docs على `/docs`.
- Helmet + Throttler + Validation Pipe.

## التشغيل المحلي

### المتطلبات

- Node.js >= 20
- Flutter >= 3.24
- PostgreSQL >= 14 (أو Docker)

### Backend

```bash
cd apps/backend
cp .env.example .env
# عدّل DATABASE_URL إذا لزم
npm install
npx prisma migrate dev
npm run seed       # بيانات تجريبية + حساب طبيب
npm run start:dev
```

سترى الـ API على `http://localhost:3000/api/v1` و Swagger على `http://localhost:3000/docs`.

**حساب تجريبي بعد الـ seed:**
- البريد: `doctor@3yadati.dz`
- كلمة المرور: `Password123!`

### Doctor App

```bash
cd apps/doctor
flutter pub get
# Android emulator:
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
# Web:
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000/api/v1
```

> ⚠️ التطبيق يعمل أيضًا في **وضع Demo** بدون Backend — عند تعذّر الاتصال يقع الـ fallback تلقائيًا على بيانات تجريبية بحيث تستطيع تجربة كل الشاشات.

### Patient App (placeholder)

```bash
cd apps/patient
flutter pub get
flutter run
```

## المخطط (Architecture)

- **Backend**: NestJS modular monolith + Prisma ORM + PostgreSQL.
- **Doctor App**: Flutter + Riverpod + go_router + Dio.
- قاعدة بيانات واحدة مشتركة بين تطبيقي الطبيب والمريض (مزامنة فورية لاحقًا عبر WebSockets / FCM).

تفاصيل أكثر في [`docs/`](docs/).

## الخطوات القادمة

- [ ] ربط Push Notifications (Firebase Cloud Messaging).
- [ ] خرائط Google Maps لاختيار مواقع الفروع.
- [ ] WebSockets للتنبيهات الفورية.
- [ ] إكمال تطبيق المرضى.
- [ ] CI/CD على GitHub Actions.
- [ ] دعم اللغة الإنجليزية كاملًا.

## الترخيص

MIT
