import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { DatabaseService } from './database.service';
import { AuthMiddleware } from '../auth/auth.middleware';

@Module({
  providers: [DatabaseService],
  exports: [DatabaseService],
})
export class DatabaseModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
  }
}
