import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateDoctorDto } from './doctors.dto';

@Injectable()
export class DoctorsService {
  constructor(private readonly prisma: PrismaService) {}

  async listSpecialties() {
    return this.prisma.specialty.findMany({ orderBy: { nameAr: 'asc' } });
  }

  async getMine(userId: string) {
    const doctor = await this.prisma.doctor.findUnique({
      where: { userId },
      include: { specialty: true, branches: true, user: true },
    });
    if (!doctor) throw new NotFoundException('لا يوجد ملف طبيب لهذا المستخدم');
    const { user, ...rest } = doctor;
    const { passwordHash: _ph, ...userSafe } = user;
    return { ...rest, user: userSafe };
  }

  async updateMine(userId: string, dto: UpdateDoctorDto) {
    const doctor = await this.prisma.doctor.findUnique({ where: { userId } });
    if (!doctor) throw new NotFoundException('لا يوجد ملف طبيب لهذا المستخدم');

    if (dto.fullName || dto.avatarUrl) {
      await this.prisma.user.update({
        where: { id: userId },
        data: {
          ...(dto.fullName ? { fullName: dto.fullName } : {}),
          ...(dto.avatarUrl ? { avatarUrl: dto.avatarUrl } : {}),
        },
      });
    }

    return this.prisma.doctor.update({
      where: { id: doctor.id },
      data: {
        bio: dto.bio,
        yearsOfExperience: dto.yearsOfExperience,
        consultationPrice: dto.consultationPrice,
        currency: dto.currency,
        specialtyId: dto.specialtyId,
        isCenter: dto.isCenter,
        centerName: dto.centerName,
      },
      include: { specialty: true, branches: true, user: true },
    });
  }

  async getById(id: string) {
    const doctor = await this.prisma.doctor.findUnique({
      where: { id },
      include: { specialty: true, branches: true, user: true },
    });
    if (!doctor) throw new NotFoundException();
    const { passwordHash: _ph, ...userSafe } = doctor.user;
    return { ...doctor, user: userSafe };
  }
}
