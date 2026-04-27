import { Controller, Get } from '@nestjs/common';
import { ApiBearerAuth, ApiTags } from '@nestjs/swagger';
import { StatisticsService } from './statistics.service';
import { CurrentUser, AuthUser } from '../common/decorators';

@ApiTags('statistics')
@ApiBearerAuth()
@Controller('statistics')
export class StatisticsController {
  constructor(private readonly service: StatisticsService) {}

  @Get('overview')
  overview(@CurrentUser() user: AuthUser) {
    return this.service.overview(user.sub);
  }

  @Get('weekly')
  weekly(@CurrentUser() user: AuthUser) {
    return this.service.weekly(user.sub);
  }

  @Get('status-breakdown')
  status(@CurrentUser() user: AuthUser) {
    return this.service.statusBreakdown(user.sub);
  }
}
