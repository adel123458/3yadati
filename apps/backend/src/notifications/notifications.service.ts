import { Injectable } from '@nestjs/common';
import { NotificationType, Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async list(userId: string) {
    return this.prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  async markRead(userId: string, id: string) {
    await this.prisma.notification.updateMany({ where: { id, userId }, data: { read: true } });
    return { ok: true };
  }

  async markAllRead(userId: string) {
    await this.prisma.notification.updateMany({ where: { userId, read: false }, data: { read: true } });
    return { ok: true };
  }

  async unreadCount(userId: string) {
    return { count: await this.prisma.notification.count({ where: { userId, read: false } }) };
  }

  async notifyDoctor(
    userId: string,
    payload: { type: NotificationType; title: string; body: string; data?: Prisma.InputJsonValue },
  ) {
    return this.prisma.notification.create({
      data: { userId, ...payload },
    });
  }
}
