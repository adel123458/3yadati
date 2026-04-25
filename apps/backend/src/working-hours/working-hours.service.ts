import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateHolidayDto, UpdateWorkingHourDto, UpsertWorkingHourDto } from './working-hours.dto';

@Injectable()
export class WorkingHoursService {
  constructor(private readonly prisma: PrismaService) {}

  private async doctorId(userId: string) {
    const d = await this.prisma.doctor.findUnique({ where: { userId } });
    if (!d) throw new ForbiddenException();
    return d.id;
  }

  async list(userId: string) {
    const doctorId = await this.doctorId(userId);
    return this.prisma.workingHour.findMany({
      where: { doctorId },
      orderBy: [{ weekday: 'asc' }, { startTime: 'asc' }],
    });
  }

  async create(userId: string, dto: UpsertWorkingHourDto) {
    const doctorId = await this.doctorId(userId);
    return this.prisma.workingHour.create({ data: { ...dto, doctorId } });
  }

  async update(userId: string, id: string, dto: UpdateWorkingHourDto) {
    const doctorId = await this.doctorId(userId);
    const existing = await this.prisma.workingHour.findFirst({ where: { id, doctorId } });
    if (!existing) throw new NotFoundException();
    return this.prisma.workingHour.update({ where: { id }, data: dto });
  }

  async remove(userId: string, id: string) {
    const doctorId = await this.doctorId(userId);
    const existing = await this.prisma.workingHour.findFirst({ where: { id, doctorId } });
    if (!existing) throw new NotFoundException();
    await this.prisma.workingHour.delete({ where: { id } });
    return { ok: true };
  }

  // Holidays
  async listHolidays(userId: string) {
    const doctorId = await this.doctorId(userId);
    return this.prisma.holiday.findMany({ where: { doctorId }, orderBy: { date: 'asc' } });
  }

  async addHoliday(userId: string, dto: CreateHolidayDto) {
    const doctorId = await this.doctorId(userId);
    return this.prisma.holiday.create({
      data: { doctorId, date: new Date(dto.date), reason: dto.reason },
    });
  }

  async removeHoliday(userId: string, id: string) {
    const doctorId = await this.doctorId(userId);
    const h = await this.prisma.holiday.findFirst({ where: { id, doctorId } });
    if (!h) throw new NotFoundException();
    await this.prisma.holiday.delete({ where: { id } });
    return { ok: true };
  }
}
