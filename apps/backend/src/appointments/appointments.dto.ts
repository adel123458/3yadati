import { IsEnum, IsISO8601, IsOptional, IsString } from 'class-validator';
import { AppointmentStatus, AppointmentType } from '@prisma/client';
import { PartialType } from '@nestjs/mapped-types';

export class CreateAppointmentDto {
  @IsISO8601() startAt!: string;
  @IsISO8601() endAt!: string;
  @IsOptional() @IsString() patientId?: string;
  @IsOptional() @IsString() branchId?: string;
  @IsOptional() @IsEnum(AppointmentType) type?: AppointmentType;
  @IsOptional() @IsString() reason?: string;
  @IsOptional() @IsString() internalNotes?: string;
  @IsOptional() @IsEnum(AppointmentStatus) status?: AppointmentStatus;
}

export class UpdateAppointmentDto extends PartialType(CreateAppointmentDto) {
  @IsOptional() @IsString() cancelledReason?: string;
}

export class ChangeStatusDto {
  @IsEnum(AppointmentStatus) status!: AppointmentStatus;
  @IsOptional() @IsString() cancelledReason?: string;
}

export class RescheduleDto {
  @IsISO8601() startAt!: string;
  @IsISO8601() endAt!: string;
}

export class GenerateSlotsDto {
  @IsISO8601() from!: string;
  @IsISO8601() to!: string;
  @IsOptional() @IsString() branchId?: string;
}
