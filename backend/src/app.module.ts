import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AdminApiModule } from './admin-api/admin-api.module';
import { ClientApiModule } from './client-api/client-api.module';
import { HealthModule } from './health/health.module';
import { PrismaModule } from './prisma/prisma.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: ['.env'],
    }),
    PrismaModule,
    HealthModule,
    ClientApiModule,
    AdminApiModule,
  ],
})
export class AppModule {}
