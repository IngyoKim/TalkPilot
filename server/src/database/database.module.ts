import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { DatabaseService } from './database.service';

@Module({
  providers: [DatabaseService],
  exports: [DatabaseService],
})
export class DatabaseModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
  }
}
