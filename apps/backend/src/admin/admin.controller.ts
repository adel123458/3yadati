import { Controller, Get, UseGuards } from '@nestjs/common';
import { UserRole } from '@prisma/client';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { RolesGuard } from '../auth/roles.guard';
import { Roles } from '../common/decorators';
import { AdminService } from './admin.service';

@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN)
@Controller('admin')
export class AdminController {
  constructor(private readonly service: AdminService) {}

  @Get('overview')
  overview() {
    return this.service.overview();
  }

  @Get('doctors')
  doctors() {
    return this.service.doctors();
  }

  @Get('appointments')
  appointments() {
    return this.service.appointments();
  }

  @Get('patients')
  patients() {
    return this.service.patients();
  }
}
