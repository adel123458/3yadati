import { ForbiddenException, Injectable } from '@nestjs/common';
import { AppointmentStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class StatisticsService {
  constructor(private readonly prisma: PrismaService) {}

  private async doctorId(userId: string) {
    const d = await this.prisma.doctor.findUnique({ where: { userId } });
    if (!d) throw new ForbiddenException();
    return d.id;
  }

  async overview(userId: string) {
    const doctorId = await this.doctorId(userId);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);
    const weekAgo = new Date(today);
    weekAgo.setDate(today.getDate() - 7);

    const [todayCount, todayConfirmed, todayPending, todayCancelled, todayCompleted, totalPatients, newPatients, upcoming, totalRevenueToday] =
      await Promise.all([
        this.prisma.appointment.count({
          where: { doctorId, startAt: { gte: today, lt: tomorrow }, NOT: { status: 'AVAILABLE' } },
        }),
        this.prisma.appointment.count({
          where: { doctorId, startAt: { gte: today, lt: tomorrow }, status: 'CONFIRMED' },
        }),
        this.prisma.appointment.count({
          where: { doctorId, startAt: { gte: today, lt: tomorrow }, status: 'PENDING' },
        }),
        this.prisma.appointment.count({
          where: { doctorId, startAt: { gte: today, lt: tomorrow }, status: 'CANCELLED' },
        }),
        this.prisma.appointment.count({
          where: { doctorId, startAt: { gte: today, lt: tomorrow }, status: 'COMPLETED' },
        }),
        this.prisma.doctorPatient.count({ where: { doctorId } }),
        this.prisma.doctorPatient.count({ where: { doctorId, createdAt: { gte: weekAgo } } }),
        this.prisma.appointment.findMany({
          where: { doctorId, startAt: { gte: new Date() }, status: { in: ['CONFIRMED', 'PENDING'] } },
          orderBy: { startAt: 'asc' },
          take: 5,
          include: { patient: true },
        }),
        this.computeRevenueToday(doctorId, today, tomorrow),
      ]);

    return {
      today: {
        total: todayCount,
        confirmed: todayConfirmed,
        pending: todayPending,
        cancelled: todayCancelled,
        completed: todayCompleted,
        revenue: totalRevenueToday,
      },
      patients: {
        total: totalPatients,
        newThisWeek: newPatients,
      },
      upcoming,
    };
  }

  private async computeRevenueToday(doctorId: string, from: Date, to: Date) {
    const doctor = await this.prisma.doctor.findUnique({ where: { id: doctorId } });
    const price = Number(doctor?.consultationPrice ?? 0);
    const completed = await this.prisma.appointment.count({
      where: { doctorId, startAt: { gte: from, lt: to }, status: 'COMPLETED' },
    });
    return price * completed;
  }

  async weekly(userId: string) {
    const doctorId = await this.doctorId(userId);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const start = new Date(today);
    start.setDate(today.getDate() - 6);

    const appts = await this.prisma.appointment.findMany({
      where: { doctorId, startAt: { gte: start, lte: today }, NOT: { status: AppointmentStatus.AVAILABLE } },
      select: { startAt: true, status: true },
    });
    const buckets: Record<string, number> = {};
    for (let i = 0; i < 7; i++) {
      const d = new Date(start);
      d.setDate(start.getDate() + i);
      buckets[d.toISOString().slice(0, 10)] = 0;
    }
    for (const a of appts) {
      const k = a.startAt.toISOString().slice(0, 10);
      if (k in buckets) buckets[k]++;
    }
    return Object.entries(buckets).map(([date, count]) => ({ date, count }));
  }

  async statusBreakdown(userId: string) {
    const doctorId = await this.doctorId(userId);
    const groups = await this.prisma.appointment.groupBy({
      by: ['status'],
      where: { doctorId, NOT: { status: AppointmentStatus.AVAILABLE } },
      _count: { _all: true },
    });
    return groups.map((g) => ({ status: g.status, count: g._count._all }));
  }
}
