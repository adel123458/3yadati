import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as argon2 from 'argon2';
import { UserRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto, LoginDto } from './auth.dto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  async register(dto: RegisterDto) {
    const existing = await this.prisma.user.findUnique({ where: { email: dto.email } });
    if (existing) throw new ConflictException('البريد الإلكتروني مستخدم بالفعل');

    const passwordHash = await argon2.hash(dto.password);

    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        phone: dto.phone,
        fullName: dto.fullName,
        passwordHash,
        role: dto.role || UserRole.DOCTOR,
        ...(dto.role === UserRole.DOCTOR || !dto.role
          ? {
              doctor: {
                create: {
                  isCenter: dto.isCenter || false,
                  centerName: dto.centerName,
                  specialtyId: dto.specialtyId,
                },
              },
            }
          : {}),
      },
      include: { doctor: true },
    });

    return this.issueToken(user);
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
      include: { doctor: true },
    });
    if (!user) throw new UnauthorizedException('بيانات الدخول غير صحيحة');
    const ok = await argon2.verify(user.passwordHash, dto.password);
    if (!ok) throw new UnauthorizedException('بيانات الدخول غير صحيحة');
    if (!user.isActive) throw new UnauthorizedException('الحساب غير مفعل');

    return this.issueToken(user);
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      include: { doctor: { include: { specialty: true, branches: true } } },
    });
    if (!user) throw new UnauthorizedException();
    const { passwordHash: _ph, ...rest } = user;
    return rest;
  }

  private async issueToken(user: { id: string; email: string; role: UserRole; doctor?: { id: string } | null; fullName: string }) {
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
      doctorId: user.doctor?.id,
    };
    const accessToken = await this.jwt.signAsync(payload);
    return {
      accessToken,
      user: {
        id: user.id,
        email: user.email,
        fullName: user.fullName,
        role: user.role,
        doctorId: user.doctor?.id,
      },
    };
  }
}
