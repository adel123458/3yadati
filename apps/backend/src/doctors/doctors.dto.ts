import { IsOptional, IsString, IsNumber, IsBoolean } from 'class-validator';
import { Type } from 'class-transformer';

export class UpdateDoctorDto {
  @IsOptional() @IsString() bio?: string;
  @IsOptional() @Type(() => Number) @IsNumber() yearsOfExperience?: number;
  @IsOptional() @Type(() => Number) @IsNumber() consultationPrice?: number;
  @IsOptional() @IsString() currency?: string;
  @IsOptional() @IsString() specialtyId?: string;
  @IsOptional() @IsBoolean() isCenter?: boolean;
  @IsOptional() @IsString() centerName?: string;
  @IsOptional() @IsString() avatarUrl?: string;
  @IsOptional() @IsString() fullName?: string;
}
