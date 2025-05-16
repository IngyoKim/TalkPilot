import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { DatabaseController } from './database.controller';
import { DatabaseService } from './database.service';
import { AuthMiddleware } from '../auth/auth.middleware';

@Module({
  controllers: [DatabaseController],
  providers: [DatabaseService],
})
export class DatabaseModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(AuthMiddleware)
      .forRoutes(DatabaseController);
  }
}