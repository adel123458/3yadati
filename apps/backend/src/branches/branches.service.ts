import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBranchDto, UpdateBranchDto } from './branches.dto';

@Injectable()
export class BranchesService {
  constructor(private readonly prisma: PrismaService) {}

  private async resolveDoctorId(userId: string) {
    const d = await this.prisma.doctor.findUnique({ where: { userId } });
    if (!d) throw new ForbiddenException('لا يوجد ملف طبيب لهذا المستخدم');
    return d.id;
  }

  async list(userId: string) {
    const doctorId = await this.resolveDoctorId(userId);
    return this.prisma.branch.findMany({
      where: { doctorId },
      orderBy: [{ isPrimary: 'desc' }, { createdAt: 'asc' }],
    });
  }

  async create(userId: string, dto: CreateBranchDto) {
    const doctorId = await this.resolveDoctorId(userId);
    if (dto.isPrimary) {
      await this.prisma.branch.updateMany({ where: { doctorId, isPrimary: true }, data: { isPrimary: false } });
    }
    return this.prisma.branch.create({ data: { ...dto, doctorId } });
  }

  async update(userId: string, id: string, dto: UpdateBranchDto) {
    const doctorId = await this.resolveDoctorId(userId);
    const existing = await this.prisma.branch.findFirst({ where: { id, doctorId } });
    if (!existing) throw new NotFoundException('الفرع غير موجود');
    if (dto.isPrimary) {
      await this.prisma.branch.updateMany({
        where: { doctorId, isPrimary: true, NOT: { id } },
        data: { isPrimary: false },
      });
    }
    return this.prisma.branch.update({ where: { id }, data: dto });
  }

  async remove(userId: string, id: string) {
    const doctorId = await this.resolveDoctorId(userId);
    const existing = await this.prisma.branch.findFirst({ where: { id, doctorId } });
    if (!existing) throw new NotFoundException();
    await this.prisma.branch.delete({ where: { id } });
    return { ok: true };
  }
}
