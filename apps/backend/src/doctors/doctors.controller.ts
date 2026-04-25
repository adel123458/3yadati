import { Body, Controller, Get, Param, Patch } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { DoctorsService } from './doctors.service';
import { UpdateDoctorDto } from './doctors.dto';
import { CurrentUser, Public, AuthUser } from '../common/decorators';

@ApiTags('doctors')
@ApiBearerAuth()
@Controller('doctors')
export class DoctorsController {
  constructor(private readonly service: DoctorsService) {}

  @Public()
  @Get('specialties')
  specialties() {
    return this.service.listSpecialties();
  }

  @Get('me')
  me(@CurrentUser() user: AuthUser) {
    return this.service.getMine(user.sub);
  }

  @Patch('me')
  update(@CurrentUser() user: AuthUser, @Body() dto: UpdateDoctorDto) {
    return this.service.updateMine(user.sub, dto);
  }

  @Public()
  @Get(':id')
  byId(@Param('id') id: string) {
    return this.service.getById(id);
  }
}
