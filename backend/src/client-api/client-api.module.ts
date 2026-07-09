import { Module } from '@nestjs/common';
import { ClientApiController } from './client-api.controller';
import { ClientApiService } from './client-api.service';

@Module({
  controllers: [ClientApiController],
  providers: [ClientApiService],
  exports: [ClientApiService],
})
export class ClientApiModule {}
