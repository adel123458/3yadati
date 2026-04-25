import { Injectable } from '@nestjs/common';
import { Weekday } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

const WEEKDAY_INDEX: Record<number, Weekday> = {
  0: Weekday.SUNDAY,
  1: Weekday.MONDAY,
  2: Weekday.TUESDAY,
  3: Weekday.WEDNESDAY,
  4: Weekday.THURSDAY,
  5: Weekday.FRIDAY,
  6: Weekday.SATURDAY,
};

function parseHHMM(date: Date, hhmm: string): Date {
  const [h, m] = hhmm.split(':').map(Number);
  const d = new Date(date);
  d.setHours(h, m, 0, 0);
  return d;
}

@Injectable()
export class SlotsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Generate AVAILABLE appointment rows for the doctor between [from, to)
   * based on configured working hours and existing appointments. Holidays
   * and existing slots/bookings are skipped.
   */
  async generate(params: { doctorId: string; from: Date; to: Date; branchId?: string }) {
    const { doctorId, from, to, branchId } = params;

    const [workingHours, holidays, existing] = await Promise.all([
      this.prisma.workingHour.findMany({ where: { doctorId, isClosed: false } }),
      this.prisma.holiday.findMany({ where: { doctorId, date: { gte: from, lte: to } } }),
      this.prisma.appointment.findMany({
        where: { doctorId, startAt: { gte: from, lt: to } },
        select: { startAt: true, endAt: true },
      }),
    ]);

    const holidayKeys = new Set(holidays.map((h) => h.date.toISOString().slice(0, 10)));
    const existingKeys = new Set(existing.map((a) => a.startAt.toISOString()));

    const created: { startAt: Date; endAt: Date; weekday: Weekday }[] = [];

    for (let day = new Date(from); day < to; day.setDate(day.getDate() + 1)) {
      const wd = WEEKDAY_INDEX[day.getDay()];
      const dayKey = day.toISOString().slice(0, 10);
      if (holidayKeys.has(dayKey)) continue;

      const wh = workingHours.filter(
        (w) => w.weekday === wd && (!branchId || !w.branchId || w.branchId === branchId),
      );
      for (const w of wh) {
        const dayStart = parseHHMM(day, w.startTime);
        const dayEnd = parseHHMM(day, w.endTime);
        const breakStart = w.breakStart ? parseHHMM(day, w.breakStart) : null;
        const breakEnd = w.breakEnd ? parseHHMM(day, w.breakEnd) : null;
        const slotMs = (w.slotMinutes || 30) * 60 * 1000;

        for (let s = dayStart.getTime(); s + slotMs <= dayEnd.getTime(); s += slotMs) {
          const start = new Date(s);
          const end = new Date(s + slotMs);
          if (breakStart && breakEnd && start < breakEnd && end > breakStart) continue;
          if (existingKeys.has(start.toISOString())) continue;
          created.push({ startAt: start, endAt: end, weekday: wd });
        }
      }
    }

    if (created.length === 0) return { created: 0 };

    await this.prisma.appointment.createMany({
      data: created.map((c) => ({
        doctorId,
        branchId: branchId,
        startAt: c.startAt,
        endAt: c.endAt,
        status: 'AVAILABLE',
        type: 'CONSULTATION',
        isManual: false,
      })),
      skipDuplicates: true,
    });

    return { created: created.length };
  }
}
