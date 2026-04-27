import { IsEmail, IsEnum, IsISO8601, IsOptional, IsString } from 'class-validator';
import { Gender } from '@prisma/client';
import { PartialType } from '@nestjs/mapped-types';

export class CreatePatientDto {
  @IsString() fullName!: string;
  @IsOptional() @IsString() phone?: string;
  @IsOptional() @IsEmail() email?: string;
  @IsOptional() @IsISO8601() birthDate?: string;
  @IsOptional() @IsEnum(Gender) gender?: Gender;
  @IsOptional() @IsString() address?: string;
  @IsOptional() @IsString() notes?: string;
}

export class UpdatePatientDto extends PartialType(CreatePatientDto) {}
