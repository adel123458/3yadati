import { IsBoolean, IsEnum, IsInt, IsOptional, IsString, Matches } from 'class-validator';
import { Type } from 'class-transformer';
import { Weekday } from '@prisma/client';
import { PartialType } from '@nestjs/mapped-types';

const HHMM = /^([01]\d|2[0-3]):[0-5]\d$/;

export class UpsertWorkingHourDto {
  @IsEnum(Weekday) weekday!: Weekday;
  @Matches(HHMM, { message: 'startTime must be HH:mm' }) startTime!: string;
  @Matches(HHMM, { message: 'endTime must be HH:mm' }) endTime!: string;
  @IsOptional() @Type(() => Number) @IsInt() slotMinutes?: number;
  @IsOptional() @Matches(HHMM) breakStart?: string;
  @IsOptional() @Matches(HHMM) breakEnd?: string;
  @IsOptional() @IsBoolean() isClosed?: boolean;
  @IsOptional() @IsString() branchId?: string;
}

export class UpdateWorkingHourDto extends PartialType(UpsertWorkingHourDto) {}

export class CreateHolidayDto {
  @IsString() date!: string;
  @IsOptional() @IsString() reason?: string;
}
