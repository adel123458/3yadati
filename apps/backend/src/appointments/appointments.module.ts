import { Module } from '@nestjs/common';
import { AppointmentsController } from './appointments.controller';
import { AppointmentsService } from './appointments.service';
import { SlotsService } from './slots.service';
import { WorkingHoursModule } from '../working-hours/working-hours.module';
import { NotificationsModule } from '../notifications/notifications.module';

@Module({
  imports: [WorkingHoursModule, NotificationsModule],
  controllers: [AppointmentsController],
  providers: [AppointmentsService, SlotsService],
  exports: [AppointmentsService],
})
export class AppointmentsModule {}
