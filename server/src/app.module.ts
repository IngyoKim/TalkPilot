import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { UserModule } from './user/user.module';
import { SttModule } from './stt/stt.module';

import { FirebaseAuthMiddleware } from './auth/auth.middleware';

@Module({
  imports: [
    UserModule,
    SttModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(FirebaseAuthMiddleware)
      .forRoutes('me');
  }
}
