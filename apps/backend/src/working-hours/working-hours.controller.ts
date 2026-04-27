import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { WorkingHoursService } from './working-hours.service';
import {
  CreateHolidayDto,
  UpdateWorkingHourDto,
  UpsertWorkingHourDto,
} from './working-hours.dto';
import { CurrentUser, AuthUser } from '../common/decorators';

@ApiTags('working-hours')
@ApiBearerAuth()
@Controller()
export class WorkingHoursController {
  constructor(private readonly service: WorkingHoursService) {}

  @Get('working-hours')
  list(@CurrentUser() user: AuthUser) {
    return this.service.list(user.sub);
  }

  @Post('working-hours')
  create(@CurrentUser() user: AuthUser, @Body() dto: UpsertWorkingHourDto) {
    return this.service.create(user.sub, dto);
  }

  @Patch('working-hours/:id')
  update(@CurrentUser() user: AuthUser, @Param('id') id: string, @Body() dto: UpdateWorkingHourDto) {
    return this.service.update(user.sub, id, dto);
  }

  @Delete('working-hours/:id')
  remove(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.service.remove(user.sub, id);
  }

  @Get('holidays')
  listHolidays(@CurrentUser() user: AuthUser) {
    return this.service.listHolidays(user.sub);
  }

  @Post('holidays')
  addHoliday(@CurrentUser() user: AuthUser, @Body() dto: CreateHolidayDto) {
    return this.service.addHoliday(user.sub, dto);
  }

  @Delete('holidays/:id')
  removeHoliday(@CurrentUser() user: AuthUser, @Param('id') id: string) {
    return this.service.removeHoliday(user.sub, id);
  }
}
