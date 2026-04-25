import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreatePatientDto, UpdatePatientDto } from './patients.dto';

@Injectable()
export class PatientsService {
  constructor(private readonly prisma: PrismaService) {}

  private async doctorId(userId: string) {
    const d = await this.prisma.doctor.findUnique({ where: { userId } });
    if (!d) throw new ForbiddenException();
    return d.id;
  }

  async list(userId: string, search?: string) {
    const doctorId = await this.doctorId(userId);
    const where: Prisma.DoctorPatientWhereInput = { doctorId };
    if (search) {
      where.patient = {
        OR: [
          { fullName: { contains: search, mode: 'insensitive' } },
          { phone: { contains: search } },
          { email: { contains: search, mode: 'insensitive' } },
        ],
      };
    }
    const links = await this.prisma.doctorPatient.findMany({
      where,
      include: { patient: true },
      orderBy: { lastVisit: 'desc' },
    });
    return links.map((l) => ({
      ...l.patient,
      firstVisit: l.firstVisit,
      lastVisit: l.lastVisit,
      privateNote: l.privateNote,
    }));
  }

  async create(userId: string, dto: CreatePatientDto) {
    const doctorId = await this.doctorId(userId);
    const patient = await this.prisma.patient.create({
      data: {
        ...dto,
        ...(dto.birthDate ? { birthDate: new Date(dto.birthDate) } : {}),
      },
    });
    await this.prisma.doctorPatient.create({ data: { doctorId, patientId: patient.id } });
    return patient;
  }

  async getOne(userId: string, id: string) {
    const doctorId = await this.doctorId(userId);
    const link = await this.prisma.doctorPatient.findUnique({
      where: { doctorId_patientId: { doctorId, patientId: id } },
      include: {
        patient: {
          include: {
            appointments: { where: { doctorId }, orderBy: { startAt: 'desc' } },
          },
        },
      },
    });
    if (!link) throw new NotFoundException();
    return { ...link.patient, privateNote: link.privateNote };
  }

  async update(userId: string, id: string, dto: UpdatePatientDto) {
    await this.getOne(userId, id);
    return this.prisma.patient.update({
      where: { id },
      data: {
        ...dto,
        ...(dto.birthDate ? { birthDate: new Date(dto.birthDate) } : {}),
      },
    });
  }
}
