import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { AppointmentStatus } from '@prisma/client';
import { AppointmentsService } from './appointments.service';
import {
  ChangeStatusDto,
  CreateAppointmentDto,
  GenerateSlotsDto,
  RescheduleDto,
  UpdateAppointmentDto,
} from './appointments.dto';
import { CurrentUser, AuthUser } from '../common/decorators';

@ApiTags('appointments')
@ApiBearerAuth()
@Controller('appointments')
export class AppointmentsController {
  constructor(private readonly service: AppointmentsService) {}

  @Get()
  list(
    @CurrentUser() user: AuthUser,
    @Query('from') from?: string,
    @Query('to') to?: string,
    @Query('status') status?: AppointmentStatus,
    @Query('branchId') branchId?: string,
    @Query('view') view?: 'day' | 'week' | 'month',
  ) {
    return this.service.list(user.sub, { from, to, status, branchId, view });
  }

  @Post()
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateAppointmentDto) {
    return this.service.create(user.sub, dto);
  }

  @Post('generate-slots')
  generate(@CurrentUser() user: AuthUser, @Body() dto: GenerateSlotsDto) {
    return this.service.generateSlots(user.sub, dto);
  }

  @Get(':id')
  one(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.service.getOne(user.sub, id);
  }

  @Patch(':id')
  update(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: UpdateAppointmentDto) {
    return this.service.update(user.sub, id, dto);
  }

  @Patch(':id/status')
  status(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: ChangeStatusDto) {
    return this.service.changeStatus(user.sub, id, dto);
  }

  @Patch(':id/reschedule')
  reschedule(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: RescheduleDto) {
    return this.service.reschedule(user.sub, id, dto);
  }

  @Delete(':id')
  remove(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.service.remove(user.sub, id);
  }
}
