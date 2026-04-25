import { PrismaClient, UserRole, Weekday, AppointmentStatus, AppointmentType, Gender } from '@prisma/client';
import * as argon2 from 'argon2';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  const specialties = await Promise.all(
    [
      { nameAr: 'طب القلب', nameEn: 'Cardiology', icon: 'heart' },
      { nameAr: 'طب الأطفال', nameEn: 'Pediatrics', icon: 'child' },
      { nameAr: 'طب الأسنان', nameEn: 'Dentistry', icon: 'tooth' },
      { nameAr: 'طب العيون', nameEn: 'Ophthalmology', icon: 'eye' },
      { nameAr: 'الجلدية', nameEn: 'Dermatology', icon: 'skin' },
      { nameAr: 'النساء والولادة', nameEn: 'Gynecology', icon: 'gyno' },
    ].map((s) =>
      prisma.specialty.upsert({
        where: { id: s.nameEn },
        update: {},
        create: { id: s.nameEn, ...s },
      }),
    ),
  );

  const passwordHash = await argon2.hash('Password123!');

  const doctorUser = await prisma.user.upsert({
    where: { email: 'doctor@3yadati.dz' },
    update: {},
    create: {
      email: 'doctor@3yadati.dz',
      phone: '+213500000001',
      passwordHash,
      fullName: 'د. أحمد السعيد',
      role: UserRole.DOCTOR,
      doctor: {
        create: {
          specialtyId: specialties[0].id,
          bio: 'طبيب قلب بخبرة 12 سنة في تشخيص وعلاج أمراض القلب والشرايين.',
          yearsOfExperience: 12,
          consultationPrice: 3500,
          currency: 'DZD',
          branches: {
            create: [
              {
                name: 'الفرع الرئيسي - الجزائر العاصمة',
                phone: '+213500000010',
                address: 'شارع ديدوش مراد، الجزائر',
                city: 'الجزائر',
                latitude: 36.7538,
                longitude: 3.0588,
                isPrimary: true,
              },
              {
                name: 'فرع وهران',
                phone: '+213500000011',
                address: 'حي الصديقية، وهران',
                city: 'وهران',
                latitude: 35.6911,
                longitude: -0.6417,
              },
            ],
          },
        },
      },
    },
    include: { doctor: { include: { branches: true } } },
  });

  const doctor = doctorUser.doctor!;
  const primaryBranch = doctor.branches.find((b) => b.isPrimary)!;

  // Working hours: Sun-Thu 09:00-17:00, break 12:30-13:30
  const weekdays = [
    Weekday.SUNDAY,
    Weekday.MONDAY,
    Weekday.TUESDAY,
    Weekday.WEDNESDAY,
    Weekday.THURSDAY,
  ];
  await prisma.workingHour.deleteMany({ where: { doctorId: doctor.id } });
  for (const wd of weekdays) {
    await prisma.workingHour.create({
      data: {
        doctorId: doctor.id,
        branchId: primaryBranch.id,
        weekday: wd,
        startTime: '09:00',
        endTime: '17:00',
        slotMinutes: 30,
        breakStart: '12:30',
        breakEnd: '13:30',
      },
    });
  }

  // Sample patients
  const patientsData = [
    { fullName: 'سارة محمد', phone: '+213551111111', gender: Gender.FEMALE },
    { fullName: 'أحمد السالم', phone: '+213552222222', gender: Gender.MALE },
    { fullName: 'محمد عبدالله', phone: '+213553333333', gender: Gender.MALE },
    { fullName: 'نورة علي', phone: '+213554444444', gender: Gender.FEMALE },
    { fullName: 'منال درعي', phone: '+213555555555', gender: Gender.FEMALE },
    { fullName: 'ياسر خليل', phone: '+213556666666', gender: Gender.MALE },
    { fullName: 'خالد الفيصل', phone: '+213557777777', gender: Gender.MALE },
  ];
  const patients = await Promise.all(
    patientsData.map((p) =>
      prisma.patient.upsert({
        where: { id: p.phone },
        update: {},
        create: { id: p.phone, ...p },
      }),
    ),
  );

  // Link patients to doctor
  for (const p of patients) {
    await prisma.doctorPatient.upsert({
      where: { doctorId_patientId: { doctorId: doctor.id, patientId: p.id } },
      update: {},
      create: {
        doctorId: doctor.id,
        patientId: p.id,
        firstVisit: new Date(Date.now() - 1000 * 60 * 60 * 24 * 30),
        lastVisit: new Date(Date.now() - 1000 * 60 * 60 * 24 * 7),
      },
    });
  }

  // Some sample appointments today
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  const mkSlot = (hour: number, min: number, dur = 30) => {
    const s = new Date(today);
    s.setHours(hour, min, 0, 0);
    const e = new Date(s.getTime() + dur * 60 * 1000);
    return { startAt: s, endAt: e };
  };

  const sample = [
    { patient: patients[0], time: mkSlot(9, 0), status: AppointmentStatus.CONFIRMED, reason: 'استشارة قلبية' },
    { patient: patients[1], time: mkSlot(11, 0), status: AppointmentStatus.PENDING, reason: 'تخطيط قلب' },
    { patient: patients[2], time: mkSlot(10, 30), status: AppointmentStatus.CONFIRMED, reason: 'متابعة حالة' },
    { patient: patients[3], time: mkSlot(13, 30), status: AppointmentStatus.CONFIRMED, reason: 'فحص دوري' },
    { patient: patients[4], time: mkSlot(14, 30), status: AppointmentStatus.PENDING, reason: 'متابعة نتائج' },
    { patient: patients[5], time: mkSlot(15, 0), status: AppointmentStatus.CONFIRMED, reason: 'استشارة قلبية' },
    { patient: patients[6], time: mkSlot(16, 0), status: AppointmentStatus.CANCELLED, reason: 'استشارة قلبية' },
  ];

  await prisma.appointment.deleteMany({ where: { doctorId: doctor.id } });
  for (const a of sample) {
    await prisma.appointment.create({
      data: {
        doctorId: doctor.id,
        branchId: primaryBranch.id,
        patientId: a.patient.id,
        startAt: a.time.startAt,
        endAt: a.time.endAt,
        status: a.status,
        type: AppointmentType.CONSULTATION,
        reason: a.reason,
      },
    });
  }

  // Demo patient user
  await prisma.user.upsert({
    where: { email: 'patient@3yadati.dz' },
    update: {},
    create: {
      email: 'patient@3yadati.dz',
      phone: '+213500000099',
      passwordHash,
      fullName: 'مريض تجريبي',
      role: UserRole.PATIENT,
    },
  });

  console.log('✅ Seed complete.');
  console.log('   Doctor login: doctor@3yadati.dz / Password123!');
  console.log('   Patient login: patient@3yadati.dz / Password123!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
