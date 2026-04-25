import { BadRequestException, ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { AppointmentStatus, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import {
  ChangeStatusDto,
  CreateAppointmentDto,
  GenerateSlotsDto,
  RescheduleDto,
  UpdateAppointmentDto,
} from './appointments.dto';
import { SlotsService } from './slots.service';
import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class AppointmentsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly slots: SlotsService,
    private readonly notifications: NotificationsService,
  ) {}

  private async doctorId(userId: string) {
    const d = await this.prisma.doctor.findUnique({ where: { userId } });
    if (!d) throw new ForbiddenException();
    return d.id;
  }

  async list(
    userId: string,
    query: {
      from?: string;
      to?: string;
      status?: AppointmentStatus;
      branchId?: string;
      view?: 'day' | 'week' | 'month';
    },
  ) {
    const doctorId = await this.doctorId(userId);
    const where: Prisma.AppointmentWhereInput = { doctorId };
    if (query.status) where.status = query.status;
    if (query.branchId) where.branchId = query.branchId;
    if (query.from || query.to) {
      where.startAt = {};
      if (query.from) (where.startAt as Prisma.DateTimeFilter).gte = new Date(query.from);
      if (query.to) (where.startAt as Prisma.DateTimeFilter).lt = new Date(query.to);
    }
    return this.prisma.appointment.findMany({
      where,
      orderBy: { startAt: 'asc' },
      include: { patient: true, branch: true },
    });
  }

  async getOne(userId: string, id: string) {
    const doctorId = await this.doctorId(userId);
    const appt = await this.prisma.appointment.findFirst({
      where: { id, doctorId },
      include: { patient: true, branch: true },
    });
    if (!appt) throw new NotFoundException();
    return appt;
  }

  async create(userId: string, dto: CreateAppointmentDto) {
    const doctorId = await this.doctorId(userId);
    const start = new Date(dto.startAt);
    const end = new Date(dto.endAt);
    if (end <= start) throw new BadRequestException('وقت الانتهاء يجب أن يكون بعد وقت البداية');

    const conflict = await this.prisma.appointment.findFirst({
      where: {
        doctorId,
        NOT: { status: { in: ['CANCELLED', 'NO_SHOW', 'CLOSED'] } },
        AND: [{ startAt: { lt: end } }, { endAt: { gt: start } }],
      },
    });
    if (conflict && conflict.status !== 'AVAILABLE') {
      throw new BadRequestException('يوجد موعد آخر يتعارض مع هذا الوقت');
    }

    const data: Prisma.AppointmentCreateInput = {
      doctor: { connect: { id: doctorId } },
      startAt: start,
      endAt: end,
      status: dto.status ?? 'CONFIRMED',
      type: dto.type ?? 'CONSULTATION',
      reason: dto.reason,
      internalNotes: dto.internalNotes,
      isManual: true,
      ...(dto.patientId ? { patient: { connect: { id: dto.patientId } } } : {}),
      ...(dto.branchId ? { branch: { connect: { id: dto.branchId } } } : {}),
    };

    if (conflict && conflict.status === 'AVAILABLE') {
      // Replace the available slot
      return this.prisma.appointment.update({
        where: { id: conflict.id },
        data: {
          patientId: dto.patientId ?? null,
          branchId: dto.branchId ?? null,
          status: dto.status ?? 'CONFIRMED',
          type: dto.type ?? 'CONSULTATION',
          reason: dto.reason,
          internalNotes: dto.internalNotes,
          isManual: true,
        },
      });
    }

    const appt = await this.prisma.appointment.create({ data });
    await this.notifications.notifyDoctor(userId, {
      type: 'APPOINTMENT_CREATED',
      title: 'موعد جديد',
      body: 'تمت إضافة موعد جديد إلى جدولك',
      data: { appointmentId: appt.id },
    });
    return appt;
  }

  async update(userId: string, id: string, dto: UpdateAppointmentDto) {
    await this.getOne(userId, id);
    return this.prisma.appointment.update({
      where: { id },
      data: {
        ...dto,
        ...(dto.startAt ? { startAt: new Date(dto.startAt) } : {}),
        ...(dto.endAt ? { endAt: new Date(dto.endAt) } : {}),
      },
    });
  }

  async remove(userId: string, id: string) {
    await this.getOne(userId, id);
    await this.prisma.appointment.delete({ where: { id } });
    return { ok: true };
  }

  async changeStatus(userId: string, id: string, dto: ChangeStatusDto) {
    await this.getOne(userId, id);
    const updated = await this.prisma.appointment.update({
      where: { id },
      data: {
        status: dto.status,
        cancelledReason: dto.status === 'CANCELLED' ? dto.cancelledReason : null,
      },
    });

    const map: Record<AppointmentStatus, { title: string; body: string } | null> = {
      AVAILABLE: null,
      PENDING: null,
      CONFIRMED: { title: 'تأكيد موعد', body: 'تم تأكيد الموعد' },
      COMPLETED: { title: 'إكمال موعد', body: 'تم إكمال الموعد' },
      CANCELLED: { title: 'إلغاء موعد', body: 'تم إلغاء الموعد' },
      NO_SHOW: { title: 'عدم حضور', body: 'تم تسجيل عدم حضور المريض' },
      CLOSED: null,
    };
    const note = map[dto.status];
    if (note) {
      await this.notifications.notifyDoctor(userId, {
        type:
          dto.status === 'CANCELLED'
            ? 'APPOINTMENT_CANCELLED'
            : dto.status === 'CONFIRMED'
              ? 'APPOINTMENT_CONFIRMED'
              : 'SYSTEM',
        title: note.title,
        body: note.body,
        data: { appointmentId: id },
      });
    }
    return updated;
  }

  async reschedule(userId: string, id: string, dto: RescheduleDto) {
    await this.getOne(userId, id);
    const updated = await this.prisma.appointment.update({
      where: { id },
      data: { startAt: new Date(dto.startAt), endAt: new Date(dto.endAt) },
    });
    await this.notifications.notifyDoctor(userId, {
      type: 'APPOINTMENT_RESCHEDULED',
      title: 'إعادة جدولة موعد',
      body: 'تم تغيير وقت الموعد',
      data: { appointmentId: id },
    });
    return updated;
  }

  async generateSlots(userId: string, dto: GenerateSlotsDto) {
    const doctorId = await this.doctorId(userId);
    return this.slots.generate({
      doctorId,
      from: new Date(dto.from),
      to: new Date(dto.to),
      branchId: dto.branchId,
    });
  }
}
