import { MiddlewareConsumer, Module, NestModule, RequestMethod } from '@nestjs/common';
import { UserModule } from './user/user.module';
import { SttModule } from './stt/stt.module';
import { AuthMiddleware } from './auth/auth.middleware';
import { DatabaseModule } from './database/database.module';

@Module({
  imports: [
    UserModule,
    SttModule,
    DatabaseModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(AuthMiddleware)
      .forRoutes(
        { path: 'me', method: RequestMethod.ALL },
      );
  }
}
