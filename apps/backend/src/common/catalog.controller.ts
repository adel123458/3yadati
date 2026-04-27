import { Controller, Get } from '@nestjs/common';
import { Public } from './decorators';
import { PrismaService } from '../prisma/prisma.service';
import { WILAYAS } from './algeria-wilayas';

@Controller()
export class CatalogController {
  constructor(private readonly prisma: PrismaService) {}

  @Public()
  @Get('wilayas')
  wilayas() {
    return WILAYAS;
  }

  @Public()
  @Get('specialties')
  async specialties() {
    return this.prisma.specialty.findMany({
      orderBy: { nameAr: 'asc' },
    });
  }
}
