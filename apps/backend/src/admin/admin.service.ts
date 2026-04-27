import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AdminService {
  constructor(private readonly prisma: PrismaService) {}

  async overview() {
    const [doctors, appointments, patients, branches] = await Promise.all([
      this.prisma.doctor.count(),
      this.prisma.appointment.count(),
      this.prisma.patient.count(),
      this.prisma.branch.count(),
    ]);
    return { doctors, appointments, patients, branches };
  }

  async doctors() {
    return this.prisma.doctor.findMany({
      include: {
        specialty: true,
        user: { select: { fullName: true, email: true, phone: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async appointments() {
    return this.prisma.appointment.findMany({
      take: 50,
      orderBy: { startAt: 'desc' },
      include: {
        patient: true,
        doctor: { include: { user: { select: { fullName: true } } } },
      },
    });
  }

  async patients() {
    return this.prisma.patient.findMany({ take: 100, orderBy: { createdAt: 'desc' } });
  }
}
